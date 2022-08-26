// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use super::common_matrices;

use ndarray::Array2;
use num_complex::Complex64;
use rand::Rng;
use rayon::current_num_threads;
use rustc_hash::FxHashMap;
use std::convert::TryInto;
use std::mem::MaybeUninit;
use std::ops::ControlFlow;

/// Limit that is checked to determine whether the operations buffer should be flushed before adding
/// more operations. Note that this is not a hard limit such that the buffer will never exceed this value,
/// just the value used to determine whether the buffer should accept the current incoming operation.
const BUFFER_LIMIT: usize = 4;

/// Get the chunk size we want to use in parallel for the given number of items based on the threads available in the
/// thread pool.
pub(crate) fn parallel_chunk_size(total_size: usize) -> usize {
    // Chunk count needs to be a power of two to work with the state vector math.
    let mut chunk_count = 1_usize;
    while chunk_count << 1 <= current_num_threads() {
        chunk_count <<= 1;
    }
    if total_size > chunk_count {
        total_size / chunk_count
    } else {
        // Try some well known sizes.
        if total_size > 8 {
            total_size / 8
        } else if total_size > 4 {
            total_size / 4
        } else if total_size > 2 {
            total_size / 2
        } else {
            // Treat as a single chunk.
            total_size
        }
    }
}

pub(crate) struct OpBuffer {
    pub targets: Vec<usize>,
    pub ops: Array2<Complex64>,
}

/// The `QuantumSim` struct contains the necessary state for tracking the simulation. Each instance of a
/// `QuantumSim` represents an independant simulation.
pub(crate) struct QuantumSim<T> {
    /// The structure that describes the current quantum state.
    pub state: T,

    /// The mapping from qubit identifiers to internal state locations.
    pub id_map: FxHashMap<usize, usize>,

    /// The ordered buffer containing queued quantum operations that have not yet been applied to the
    /// state.
    pub op_buffer: OpBuffer,
}

pub(crate) mod detail {
    pub trait QuantumSimImpl {
        fn extend_state(&mut self);
        fn swap_qubits(&mut self, qubit1: usize, qubit2: usize);
        fn cleanup_state(&mut self, res: bool);
        fn dump_impl(&self, print_id_map: bool);
        fn apply_impl(&mut self);
        fn check_joint_probability(&self, locs: &[usize]) -> f64;
        fn collapse(&mut self, loc: usize, val: bool);
        fn joint_collapse(&mut self, locs: &[usize], val: bool);
        fn normalize(&mut self);
    }
}
use detail::QuantumSimImpl;

/// Provides the common set of functionality across all quantum simulation types.
impl<T> QuantumSim<T>
where
    Self: detail::QuantumSimImpl,
{
    /// Allocates a fresh qubit, returning its identifier. Note that this will use the lowest available
    /// identifier, and may result in qubits being allocated "in the middle" of an existing register
    /// if those identifiers are available.
    #[must_use]
    pub(crate) fn allocate(&mut self) -> usize {
        self.extend_state();
        self.allocate_next_id()
    }

    /// Utility that finds and reserves the next available qubit id in the map, returning the reserved
    /// id.
    fn allocate_next_id(&mut self) -> usize {
        // Add the new entry into the FxHashMap at the first available sequential ID.
        let mut sorted_keys: Vec<&usize> = self.id_map.keys().collect();
        sorted_keys.sort();
        let n_qubits = sorted_keys.len();
        let new_key = sorted_keys
            .iter()
            .enumerate()
            .take_while(|(index, key)| index == **key)
            .last()
            .map_or(0_usize, |(_, &&key)| key + 1);
        self.id_map.insert(new_key, n_qubits);

        // Return the new ID that was used.
        new_key
    }

    /// Releases the given qubit, collapsing its state in the process. After release that identifier is
    /// no longer valid for use in other functions and will cause an error if used.
    /// # Panics
    ///
    /// The function will panic if the given id does not correpsond to an allocated qubit.
    pub(crate) fn release(&mut self, id: usize) {
        self.flush();

        // Since it is easier to release a contiguous half of the state, find the qubit
        // with the last location and swap that with the qubit to be released.
        let n_qubits = self.id_map.len();
        let loc = *self
            .id_map
            .get(&id)
            .unwrap_or_else(|| panic!("Unable to find qubit with id {}.", id));
        let last_loc = n_qubits - 1;
        if last_loc != loc {
            let last_id = *self
                .id_map
                .iter()
                .find(|(_, &value)| value == last_loc)
                .unwrap()
                .0;
            self.swap_qubits(loc, last_loc);
            *(self.id_map.get_mut(&last_id).unwrap()) = loc;
            *(self.id_map.get_mut(&id).unwrap()) = last_loc;
        };

        // Measure and collapse the state for this qubit.
        let res = self.measure_impl(last_loc);

        // Remove the released ID from the mapping and cleanup the unused part of the state.
        self.id_map.remove(&id);
        self.cleanup_state(res);
    }

    /// Flushes the current operations buffer and updates the resulting state, clearing the buffer
    /// in the process.
    /// # Panics
    ///
    /// This function will panic if the given ids that do not correspond to allocated qubits.
    fn flush(&mut self) {
        if !self.op_buffer.targets.is_empty() {
            // Swap each of the target qubits to the right-most entries in the state, in order.
            self.op_buffer
                .targets
                .clone()
                .iter()
                .rev()
                .enumerate()
                .for_each(|(target_loc, target)| {
                    let loc = *self
                        .id_map
                        .get(target)
                        .unwrap_or_else(|| panic!("Unable to find qubit with id {}", target));
                    let swap_id = *self
                        .id_map
                        .iter()
                        .find(|(_, &value)| value == target_loc)
                        .unwrap()
                        .0;
                    self.swap_qubits(loc, target_loc);
                    *(self.id_map.get_mut(&swap_id).unwrap()) = loc;
                    *(self.id_map.get_mut(target).unwrap()) = target_loc;
                });

            self.apply_impl();

            self.op_buffer = OpBuffer {
                targets: vec![],
                ops: Array2::default((0, 0)),
            };
        }
    }

    /// Prints the current state vector to standard output with integer labels for the states, skipping any
    /// states with zero amplitude.
    /// # Panics
    ///
    /// This function panics if it is unable sort the state into qubit id order.
    pub(crate) fn dump(&mut self) {
        self.flush();

        // Swap all the entries in the state to be ordered by qubit identifier. This makes
        // interpreting the state easier for external consumers that don't have access to the id map.
        let mut sorted_keys: Vec<usize> = self.id_map.keys().copied().collect();
        sorted_keys.sort_unstable();
        sorted_keys.iter().enumerate().for_each(|(index, &key)| {
            if index != self.id_map[&key] {
                self.swap_qubits(self.id_map[&key], index);
                let swapped_key = *self
                    .id_map
                    .iter()
                    .find(|(_, &value)| value == index)
                    .unwrap()
                    .0;
                *(self.id_map.get_mut(&swapped_key).unwrap()) = self.id_map[&key];
                *(self.id_map.get_mut(&key).unwrap()) = index;
            }
        });

        self.dump_impl(false);
    }

    /// Applies the given unitary to the given targets, extending the unitary to accomodate controls if any.
    /// # Panics
    ///
    /// This function will panic if given ids in either targets or optional controls that do not correspond to allocated
    /// qubits, or if there is a duplicate id in targets or controls.
    /// This funciton will panic if the given unitary matrix does not match the number of targets provided.
    /// This function will panic if the given unitary is not square.
    /// This function will panic if the total number of targets and controls too large for a `u32`.
    pub(crate) fn apply(
        &mut self,
        unitary: &Array2<Complex64>,
        targets: &[usize],
        controls: Option<&[usize]>,
    ) {
        let mut targets = targets.to_vec();
        let mut unitary = unitary.clone();

        assert!(
            unitary.ncols() == unitary.nrows(),
            "Application given non-square matrix."
        );

        assert!(
            targets.len() == unitary.ncols() / 2,
            "Application given incorrect number of targets; expected {}, given {}.",
            unitary.ncols() / 2,
            targets.len()
        );

        if let Some(ctrls) = controls {
            // Add controls in order as targets.
            ctrls
                .iter()
                .enumerate()
                .for_each(|(index, &element)| targets.insert(index, element));

            // Extend the provided unitary by inserting it into an identity matrix.
            unitary = common_matrices::controlled(&unitary, ctrls.len().try_into().unwrap());
        }

        let mut sorted_targets = targets.clone();
        sorted_targets.sort_unstable();
        if let ControlFlow::Break(Some(duplicate)) =
            sorted_targets.iter().try_fold(None, |last, current| {
                last.map_or_else(
                    || ControlFlow::Continue(Some(current)),
                    |last| {
                        if last == current {
                            ControlFlow::Break(Some(current))
                        } else {
                            ControlFlow::Continue(Some(current))
                        }
                    },
                )
            })
        {
            panic!("Duplicate qubit id '{}' found in application.", duplicate);
        }

        // If the new operation would be too big for the buffer limit or if any target qubits are already
        // targets of the buffered operations, flush the buffer first before adding the currently
        // requested operation.
        if self.op_buffer.targets.len() + targets.len() > BUFFER_LIMIT
            || self.op_buffer.targets.iter().any(|q| targets.contains(q))
        {
            self.flush();
        }
        self.op_buffer.targets.append(&mut targets.clone());
        if self.op_buffer.targets.len() > targets.len() {
            // Add the new unitary to the buffered operation by performing the Kronecker product. Note
            // this means tthe order of targets must be maintained to match the combined matrix.
            self.op_buffer.ops = QuantumSim::kron(&self.op_buffer.ops, &unitary);
        } else {
            // This is the only operation in an empty buffer, so just copy it.
            self.op_buffer.ops = unitary;
        }
    }

    /// Parallelized Kronecker product implementation, copied from `ndarray::linalg::kron`.
    fn kron(alpha: &Array2<Complex64>, beta: &Array2<Complex64>) -> Array2<Complex64> {
        let dim_alpha_rows = alpha.shape()[0];
        let dim_alpha_cols = alpha.shape()[1];
        let dim_beta_rows = beta.shape()[0];
        let dim_beta_cols = beta.shape()[1];
        let mut out: Array2<MaybeUninit<Complex64>> = Array2::uninit((
            dim_alpha_rows
                .checked_mul(dim_beta_rows)
                .expect("Dimensions of kronecker product output array overflows usize."),
            dim_alpha_cols
                .checked_mul(dim_beta_cols)
                .expect("Dimensions of kronecker product output array overflows usize."),
        ));
        ndarray::Zip::from(out.exact_chunks_mut((dim_beta_rows, dim_beta_cols)))
            .and(alpha)
            .par_for_each(|out, &a| {
                ndarray::Zip::from(out).and(beta).for_each(|out, &b| {
                    *out = MaybeUninit::new(a * b);
                });
            });
        unsafe { out.assume_init() }
    }

    /// Checks the probability of parity measurement in the computational basis for the given set of
    /// qubits.
    /// # Panics
    ///
    /// This function will panic if the given ids do not all correspond to allocated qubits.
    /// This function will panic if there are duplicate ids in the given list.
    #[must_use]
    pub(crate) fn joint_probability(&mut self, ids: &[usize]) -> f64 {
        let mut sorted_targets = ids.to_vec();
        sorted_targets.sort_unstable();
        if let ControlFlow::Break(Some(duplicate)) =
            sorted_targets.iter().try_fold(None, |last, current| {
                last.map_or_else(
                    || ControlFlow::Continue(Some(current)),
                    |last| {
                        if last == current {
                            ControlFlow::Break(Some(current))
                        } else {
                            ControlFlow::Continue(Some(current))
                        }
                    },
                )
            })
        {
            panic!("Duplicate qubit id '{}' found in application.", duplicate);
        }

        // Flush the buffered operations to update the state.
        self.flush();

        let locs: Vec<usize> = ids
            .iter()
            .map(|id| {
                *self
                    .id_map
                    .get(id)
                    .unwrap_or_else(|| panic!("Unable to find qubit with id {}", id))
            })
            .collect();

        self.check_joint_probability(&locs)
    }

    /// Utility that performs the actual measurement and collapse of the state for the given
    /// location.
    fn measure_impl(&mut self, loc: usize) -> bool {
        let mut rng = rand::thread_rng();
        let random_sample: f64 = rng.gen();
        let res = random_sample < self.check_joint_probability(&[loc]);
        self.collapse(loc, res);
        res
    }

    /// Measures the qubit with the given id, collapsing the state based on the measured result.
    /// # Panics
    ///
    /// This funciton will panic if the given identifier does not correspond to an allocated qubit.
    #[must_use]
    pub(crate) fn measure(&mut self, id: usize) -> bool {
        // Flush the buffered operations and update the state.
        self.flush();

        self.measure_impl(
            *self
                .id_map
                .get(&id)
                .unwrap_or_else(|| panic!("Unable to find qubit with id {}", id)),
        )
    }

    /// Performs a joint measurement to get the parity of the given qubits, collapsing the state
    /// based on the measured result.
    /// # Panics
    ///
    /// This function will panic if any of the given identifiers do not correspond to an allocated qubit.
    /// This function will panic if any of the given identifiers are duplicates.
    #[must_use]
    pub(crate) fn joint_measure(&mut self, ids: &[usize]) -> bool {
        let mut sorted_targets = ids.to_vec();
        sorted_targets.sort_unstable();
        if let ControlFlow::Break(Some(duplicate)) =
            sorted_targets.iter().try_fold(None, |last, current| {
                last.map_or_else(
                    || ControlFlow::Continue(Some(current)),
                    |last| {
                        if last == current {
                            ControlFlow::Break(Some(current))
                        } else {
                            ControlFlow::Continue(Some(current))
                        }
                    },
                )
            })
        {
            panic!("Duplicate qubit id '{}' found in application.", duplicate);
        }

        // Flush the buffered operations and update the state.
        self.flush();

        let locs: Vec<usize> = ids
            .iter()
            .map(|id| {
                *self
                    .id_map
                    .get(id)
                    .unwrap_or_else(|| panic!("Unable to find qubit with id {}", id))
            })
            .collect();

        let mut rng = rand::thread_rng();
        let random_sample: f64 = rng.gen();
        let res = random_sample < self.check_joint_probability(&locs);
        self.joint_collapse(&locs, res);
        res
    }
}

#[cfg(test)]
mod tests {
    use super::{
        common_matrices::{adjoint, controlled, h, s, x},
        *,
    };
    use crate::sim::sparsestate::SparseStateQuantumSim;
    use ndarray::array;
    use num_traits::{One, Zero};

    fn almost_equal(a: f64, b: f64) -> bool {
        a.max(b) - b.min(a) <= 1e-10
    }

    // Test that basic allocation and release of qubits doesn't fail.
    #[test]
    fn test_alloc_release() {
        let sim = &mut SparseStateQuantumSim::default();
        for i in 0..16 {
            assert_eq!(sim.allocate(), i);
        }
        sim.release(4);
        sim.release(7);
        sim.release(12);
        assert_eq!(sim.allocate(), 4);
        for i in 0..7 {
            sim.release(i);
        }
        for i in 8..12 {
            sim.release(i);
        }
        for i in 13..16 {
            sim.release(i);
        }
    }

    /// Test basic appliation of gate matrices doesn't fail. Note that this does not verify the contents
    /// of the state.
    #[test]
    fn test_apply1() {
        let mut sim = SparseStateQuantumSim::default();
        for i in 0..6 {
            assert_eq!(sim.allocate(), i);
        }
        sim.apply(&x(), &[2], None);
        sim.apply(&x(), &[4], None);
        sim.apply(&x(), &[5], None);
        sim.release(5);
        sim.apply(&ndarray::linalg::kron(&h(), &x()), &[1, 4], None);
        sim.apply(&x(), &[2], None);
        sim.apply(&h(), &[1], None);
        for i in 0..5 {
            sim.release(i);
        }
    }

    /// Test appliction of gates that result in entanglement. Note that this does not verify the contents
    /// of the state.
    #[test]
    fn test_apply2() {
        let mut sim = SparseStateQuantumSim::default();
        let q0 = sim.allocate();
        let q1 = sim.allocate();
        let q2 = sim.allocate();
        sim.apply(&h(), &[q0], None);
        sim.apply(&controlled(&x(), 1), &[q0, q1], None);
        sim.apply(&controlled(&x(), 1), &[q0, q2], None);
        sim.apply(&controlled(&x(), 1), &[q1, q0], None);
        sim.apply(&controlled(&x(), 1), &[q1, q2], None);
        sim.apply(&h(), &[q1], None);
        sim.release(q0);
        sim.release(q1);
        sim.release(q2);
    }

    /// Verifies that application of gates to a qubit results in the correct probabilities.
    #[test]
    fn test_probability() {
        let mut sim = SparseStateQuantumSim::default();
        let q = sim.allocate();
        let extra = sim.allocate();
        assert!(almost_equal(0.0, sim.joint_probability(&[q])));
        sim.apply(&x(), &[q], None);
        assert!(almost_equal(1.0, sim.joint_probability(&[q])));
        sim.apply(&x(), &[q], None);
        assert!(almost_equal(0.0, sim.joint_probability(&[q])));
        sim.apply(&h(), &[q], None);
        assert!(almost_equal(0.5, sim.joint_probability(&[q])));
        sim.apply(&h(), &[q], None);
        assert!(almost_equal(0.0, sim.joint_probability(&[q])));
        sim.apply(&x(), &[q], None);
        sim.apply(&h(), &[q], None);
        sim.apply(&s(), &[q], None);
        assert!(almost_equal(0.5, sim.joint_probability(&[q])));
        sim.apply(&adjoint(&s()), &[q], None);
        sim.apply(&h(), &[q], None);
        sim.apply(&x(), &[q], None);
        assert!(almost_equal(0.0, sim.joint_probability(&[q])));
        sim.release(extra);
        sim.release(q);
    }

    /// Verify that a qubit in superposition has probability corresponding the measured value and
    /// can be operationally reset back into the ground state.
    #[test]
    fn test_measure() {
        let mut sim = SparseStateQuantumSim::default();
        let q = sim.allocate();
        let extra = sim.allocate();
        assert!(!sim.measure(q));
        sim.apply(&x(), &[q], None);
        assert!(sim.measure(q));
        let mut res = false;
        while !res {
            sim.apply(&h(), &[q], None);
            res = sim.measure(q);
            assert!(almost_equal(
                sim.joint_probability(&[q]),
                if res { 1.0 } else { 0.0 }
            ));
            if res {
                sim.apply(&x(), &[q], None);
            }
        }
        assert!(almost_equal(sim.joint_probability(&[q]), 0.0));
        sim.release(extra);
        sim.release(q);
    }

    /// Verify joint probability works as expected, namely that it corresponds to the parity of the
    /// qubits.
    #[test]
    fn test_joint_probability() {
        let mut sim = SparseStateQuantumSim::default();
        let q0 = sim.allocate();
        let q1 = sim.allocate();
        assert!(almost_equal(0.0, sim.joint_probability(&[q0, q1])));
        sim.apply(&x(), &[q0], None);
        assert!(almost_equal(1.0, sim.joint_probability(&[q0, q1])));
        sim.apply(&x(), &[q1], None);
        assert!(almost_equal(0.0, sim.joint_probability(&[q0, q1])));
        assert!(almost_equal(1.0, sim.joint_probability(&[q0])));
        assert!(almost_equal(1.0, sim.joint_probability(&[q1])));
        sim.apply(&h(), &[q0], None);
        assert!(almost_equal(0.5, sim.joint_probability(&[q0, q1])));
        sim.release(q1);
        sim.release(q0);
    }

    /// Verify joint measurement works as expected, namely that it corresponds to the parity of the
    /// qubits.
    #[test]
    fn test_joint_measurement() {
        let mut sim = SparseStateQuantumSim::default();
        let q0 = sim.allocate();
        let q1 = sim.allocate();
        assert!(!sim.joint_measure(&[q0, q1]));
        sim.apply(&x(), &[q0], None);
        assert!(sim.joint_measure(&[q0, q1]));
        sim.apply(&x(), &[q1], None);
        assert!(!sim.joint_measure(&[q0, q1]));
        assert!(sim.joint_measure(&[q0]));
        assert!(sim.joint_measure(&[q1]));
        sim.apply(&h(), &[q0], None);
        let res = sim.joint_measure(&[q0, q1]);
        assert!(almost_equal(
            if res { 1.0 } else { 0.0 },
            sim.joint_probability(&[q0, q1])
        ));
        sim.release(q1);
        sim.release(q0);
    }

    /// Test arbitrary controls, which should extend the applied unitary matrix.
    #[test]
    fn test_arbitrary_controls() {
        let mut sim = SparseStateQuantumSim::default();
        let q0 = sim.allocate();
        let q1 = sim.allocate();
        let q2 = sim.allocate();
        assert!(almost_equal(0.0, sim.joint_probability(&[q0])));
        sim.apply(&h(), &[q0], None);
        assert!(almost_equal(0.5, sim.joint_probability(&[q0])));
        sim.apply(&h(), &[q0], None);
        assert!(almost_equal(0.0, sim.joint_probability(&[q0])));
        sim.apply(&h(), &[q0], Some(&[q1]));
        assert!(almost_equal(0.0, sim.joint_probability(&[q0])));
        sim.apply(&x(), &[q1], None);
        sim.apply(&h(), &[q0], Some(&[q1]));
        assert!(almost_equal(0.5, sim.joint_probability(&[q0])));
        sim.apply(&h(), &[q0], Some(&[q2, q1]));
        assert!(almost_equal(0.5, sim.joint_probability(&[q0])));
        sim.apply(&x(), &[q2], None);
        sim.apply(&h(), &[q0], Some(&[q2, q1]));
        assert!(almost_equal(0.0, sim.joint_probability(&[q0])));
        sim.apply(&x(), &[q1], None);
        sim.apply(&x(), &[q2], None);
        sim.release(q2);
        sim.release(q1);
        sim.release(q0);
    }

    /// Verify that targets cannot be duplicated.
    #[test]
    #[should_panic(expected = "Duplicate qubit id '0' found in application.")]
    fn test_duplicate_target() {
        let mut sim = SparseStateQuantumSim::new();
        let q = sim.allocate();
        sim.apply(&controlled(&x(), 1), &[q, q], None);
    }

    /// Verify that controls cannot be duplicated.
    #[test]
    #[should_panic(expected = "Duplicate qubit id '1' found in application.")]
    fn test_duplicate_control() {
        let mut sim = SparseStateQuantumSim::new();
        let q = sim.allocate();
        let c = sim.allocate();
        sim.apply(&x(), &[q], Some(&[c, c]));
    }

    /// Verify that targets aren't in controls.
    #[test]
    #[should_panic(expected = "Duplicate qubit id '0' found in application.")]
    fn test_target_in_control() {
        let mut sim = SparseStateQuantumSim::new();
        let q = sim.allocate();
        let c = sim.allocate();
        sim.apply(&x(), &[q], Some(&[c, q]));
    }

    /// Verify target count logic, which should reject any application where the given targets does
    /// not match the size of the given unitary.
    #[test]
    #[should_panic(
        expected = "Application given incorrect number of targets; expected 2, given 1."
    )]
    fn test_target_count() {
        let mut sim = SparseStateQuantumSim::new();
        let q = sim.allocate();
        sim.apply(&controlled(&x(), 1), &[q], None);
    }

    /// Verify that non-square matrices are rejected.
    #[test]
    #[should_panic(expected = "Application given non-square matrix.")]
    fn test_nonsquare() {
        let mut sim = SparseStateQuantumSim::new();
        let q = sim.allocate();
        sim.apply(&array![[Complex64::zero()], [Complex64::one()]], &[q], None);
    }
}
