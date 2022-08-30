// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use ndarray::Array2;
use num_bigint::BigUint;
use num_complex::Complex64;
use num_traits::{One, ToPrimitive, Zero};
use rayon::prelude::*;
use rustc_hash::FxHashMap;

use super::simulator::{detail::QuantumSimImpl, parallel_chunk_size, OpBuffer, QuantumSim};

pub type SparseState = FxHashMap<BigUint, Complex64>;

/// Sparse quantum state simulation using a dictionary of states with non-zero amplitudes, based on <https://arxiv.org/pdf/2105.01533.pdf>.
/// This simulator is memory efficient for highly entangled states, allowing for the use of up to 128 qubits, but less performant
/// than full state simulation for dense quantum states.
pub(crate) type SparseStateQuantumSim = QuantumSim<SparseState>;

impl Default for QuantumSim<SparseState> {
    fn default() -> Self {
        Self::new()
    }
}

impl QuantumSim<SparseState> {
    /// Creates a new sparse state quantum simulator object with empty initial state (no qubits allocated, no operations buffered).
    #[must_use]
    pub fn new() -> Self {
        QuantumSim {
            state: FxHashMap::default(),

            id_map: FxHashMap::default(),

            op_buffer: OpBuffer {
                targets: vec![],
                ops: Array2::default((0, 0)),
            },
        }
    }
}

impl QuantumSimImpl for QuantumSim<SparseState> {
    /// Utility that extends the internal state to make room for a newly allocated qubit.
    /// # Panics
    ///
    /// This function will panic if the total number of allocated qubits would increase beyond 128.
    fn extend_state(&mut self) {
        if self.id_map.is_empty() {
            // Add the intial value for the zero state.
            self.state.insert(BigUint::zero(), Complex64::one());
        }
    }

    /// Utility function that will swap states of two qubits throughout the sparse state map.
    fn swap_qubits(&mut self, qubit1: usize, qubit2: usize) {
        if qubit1 == qubit2 {
            return;
        }

        let (q1, q2) = (qubit1 as u64, qubit2 as u64);

        // In parallel, swap entries in the sparse state to correspond to swapping of two qubits'
        // locations.
        let chunk_size = parallel_chunk_size(self.state.len());
        self.state = self
            .state
            .drain()
            .collect::<Vec<_>>()
            .par_chunks(chunk_size)
            .fold(FxHashMap::default, |mut accum, chunk| {
                for (k, v) in chunk {
                    if k.bit(q1) == k.bit(q2) {
                        accum.insert(k.clone(), *v);
                    } else {
                        let mut new_k = k.clone();
                        new_k.set_bit(q1, !k.bit(q1));
                        new_k.set_bit(q2, !k.bit(q2));
                        accum.insert(new_k, *v);
                    }
                }
                accum
            })
            .reduce(FxHashMap::default, |mut accum, mut chunk| {
                for (k, v) in chunk.drain() {
                    accum.insert(k, v);
                }
                accum
            });
    }

    /// Releases the given qubit, collapsing its state in the process. After release that identifier is
    /// no longer valid for use in other functions and will cause an error if used.
    /// # Panics
    ///
    /// The function will panic if the given id does not correpsond to an allocated qubit.
    fn cleanup_state(&mut self, res: bool) {
        if res {
            let qubit = self.id_map.len() as u64;
            let chunk_size = parallel_chunk_size(self.state.len());
            self.state = self
                .state
                .drain()
                .collect::<Vec<_>>()
                .par_chunks(chunk_size)
                .fold(FxHashMap::default, |mut accum, chunk| {
                    for (k, v) in chunk {
                        let mut new_k = k.clone();
                        new_k.set_bit(qubit, !k.bit(qubit));
                        accum.insert(new_k, *v);
                    }
                    accum
                })
                .reduce(FxHashMap::default, |mut accum, mut chunk| {
                    for (k, v) in chunk.drain() {
                        accum.insert(k, v);
                    }
                    accum
                });
        }
    }

    /// Utility function that performs the actual output of state (and optionally map) to screen. Can
    /// be called internally from other functions to aid in debugging and does not perform any modification
    /// of the internal structures.
    fn dump_impl(&self, print_id_map: bool) {
        if print_id_map {
            println!("MAP: {:?}", self.id_map);
        };
        print!("STATE: [ ");
        let mut sorted_keys = self.state.keys().collect::<Vec<_>>();
        sorted_keys.sort_unstable();
        for key in sorted_keys {
            print!(
                "|{}\u{27e9}: {}, ",
                key,
                self.state.get(key).map_or_else(Complex64::zero, |v| *v)
            );
        }
        println!("]");
    }

    /// Utility that actually performs the application of the buffered unitary to the targets within the
    /// sparse state.
    fn apply_impl(&mut self) {
        // let state_size = 1_usize << self.id_map.len();
        let chunk_size = parallel_chunk_size(self.state.len());
        let op_size = self.op_buffer.ops.nrows();
        self.state = self
            .state
            .drain()
            .collect::<Vec<_>>()
            .par_chunks(chunk_size)
            .fold(FxHashMap::default, |mut accum, chunk| {
                for (index, val) in chunk {
                    let i = index / op_size;
                    let l = (index % op_size)
                        .to_usize()
                        .expect("Cannot operate on more than 64 qubits at a time.");
                    for j in
                        (0..op_size).filter(|j| !self.op_buffer.ops.row(*j as usize)[l].is_zero())
                    {
                        let loc = (&i * op_size) + (j as u128);
                        if let Some(entry) = accum.get_mut(&loc) {
                            *entry += self.op_buffer.ops.row(j)[l] * val;
                        } else {
                            accum.insert((&i * op_size) + j, self.op_buffer.ops.row(j)[l] * val);
                        }
                        if accum
                            .get(&loc)
                            .map_or_else(Complex64::one, |entry| *entry)
                            .is_zero()
                        {
                            accum.remove(&loc);
                        }
                    }
                }
                accum
            })
            .reduce(FxHashMap::default, |mut accum, mut sparse_chunk| {
                for (k, v) in sparse_chunk.drain() {
                    if let Some(entry) = accum.get_mut(&k) {
                        *entry += v;
                    } else if !v.is_zero() {
                        accum.insert(k.clone(), v);
                    }
                    if accum
                        .get(&k)
                        .map_or_else(Complex64::one, |entry| *entry)
                        .is_zero()
                    {
                        accum.remove(&k);
                    }
                }
                accum
            });
    }

    /// Utility to get the sum of all probabilies where an odd number of the bits at the given locations
    /// are set. This corresponds to the probability of jointly measuring those qubits in the computational
    /// basis.
    fn check_joint_probability(&self, locs: &[usize]) -> f64 {
        let mask = locs.iter().fold(BigUint::zero(), |accum, loc| {
            accum | (BigUint::one() << loc)
        });
        (&self.state)
            .into_par_iter()
            .fold(
                || 0.0_f64,
                |accum, (index, val)| {
                    if (index & &mask).count_ones() & 1 > 0 {
                        accum + val.norm_sqr()
                    } else {
                        accum
                    }
                },
            )
            .sum()
    }

    /// Utility to perform the normalize of the state.
    fn normalize(&mut self) {
        let scale = 1.0
            / self
                .state
                .par_iter()
                .fold(|| 0.0_f64, |sum, (_, val)| sum + val.norm_sqr())
                .sum::<f64>()
                .sqrt();

        self.state.par_iter_mut().for_each(|(_, val)| *val *= scale);
    }

    /// Utility to collapse the probability at the given location based on the boolean value. This means
    /// that if the given value is 'true' then all keys in the sparse state where the given location
    /// has a zero bit will be reduced to zero and removed. Then the sparse state is normalized.
    fn collapse(&mut self, loc: usize, val: bool) {
        self.joint_collapse(&[loc], val);
    }

    /// Utility to collapse the joint probability of a particular set of locations in the sparse state.
    /// The entries that do not correspond to the given boolean value are removed, and then the whole
    /// state is normalized.
    fn joint_collapse(&mut self, locs: &[usize], val: bool) {
        let mask = locs.iter().fold(BigUint::zero(), |accum, loc| {
            accum | (BigUint::one() << loc)
        });

        let chunk_size = parallel_chunk_size(self.state.len());
        self.state = self
            .state
            .drain()
            .collect::<Vec<_>>()
            .par_chunks(chunk_size)
            .fold(FxHashMap::default, |mut accum, chunk| {
                for (k, v) in chunk
                    .iter()
                    .filter(|(index, _)| ((index & &mask).count_ones() & 1 > 0) == val)
                {
                    accum.insert(k.clone(), *v);
                }
                accum
            })
            .reduce(FxHashMap::default, |mut accum, mut chunk| {
                for (k, v) in chunk.drain() {
                    accum.insert(k, v);
                }
                accum
            });

        self.normalize();
    }
}
