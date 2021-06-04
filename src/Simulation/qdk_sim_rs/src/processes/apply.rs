// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

//! Public implementations and crate-private functions for applying processes
//! in each different representation.

use itertools::Itertools;
use ndarray::{Array, Array2, Array3, ArrayView2, Axis};
use rand::{distributions::WeightedIndex, prelude::Distribution, thread_rng};

use crate::{linalg::ConjBy, log, log_as_err, Pauli, Process, State, StateData::*, C64};

use super::promote_pauli_channel;

impl Process {
    /// Applies this process to the given qubits in a register with a given
    /// state, returning the new state of that register.
    pub fn apply_to(&self, idx_qubits: &[usize], state: &State) -> Result<State, String> {
        // Fail if there's not enough qubits.
        if state.n_qubits < self.n_qubits {
            return log_as_err(format!(
                "Channel acts on {} qubits, but a state on only {} qubits was given.",
                self.n_qubits, state.n_qubits
            ));
        }

        // Fail if any indices are repeated.
        if idx_qubits.iter().unique().count() < idx_qubits.len() {
            return log_as_err(format!(
                "List of qubit indices {:?} contained repeated elements.",
                idx_qubits
            ));
        }

        // Make sure that there are only as many indices as qubits that this
        // channel acts upon.
        if idx_qubits.len() != self.n_qubits {
            return log_as_err(format!(
                "Qubit indices were specified as {:?}, but this channel only acts on {} qubits.",
                idx_qubits, self.n_qubits
            ));
        }

        // At this point we know that idx_qubits has self.n_qubits many unique
        // indices in ascending order, so we can proceed to make a new channel
        // that expands this channel to act on the full register and then use
        // the ordinary apply method.
        // TODO[perf]: For larger systems, this could be improved by using
        //             matrix multiplication kernels to avoid extending
        //             channels to larger Hilbert spaces.
        //             For smaller systems, extending channels and possibly
        //             caching them is likely to be more performant; need to
        //             tune to find crossover point.
        match self.n_qubits {
            1 => {
                if state.n_qubits == 1 {
                    self.apply(state)
                } else {
                    self.extend_one_to_n(idx_qubits[0], state.n_qubits)
                        .apply(state)
                }
            }
            // TODO[perf]: If the size of the register matches the size of the
            //             channel, permute rather than expanding.
            2 => self
                .extend_two_to_n(idx_qubits[0], idx_qubits[1], state.n_qubits)
                .apply(state),
            _ => {
                log(&format!(
                    "Expanding {}-qubit channels is not yet implemented.",
                    self.n_qubits
                ));
                unimplemented!("");
            }
        }
    }
}

pub(crate) fn apply_unitary(u: &Array2<C64>, state: &State) -> Result<State, String> {
    Ok(State {
        n_qubits: state.n_qubits,
        data: match &state.data {
            Pure(psi) => Pure(u.dot(psi)),
            Mixed(rho) => Mixed(rho.conjugate_by(&u.into())),
            Stabilizer(_tableau) => {
                return Err(
                    "TODO: Promote stabilizer state to state vector and recurse.".to_string(),
                )
            }
        },
    })
}

pub(crate) fn apply_kraus_decomposition(ks: &Array3<C64>, state: &State) -> Result<State, String> {
    Ok(State {
        n_qubits: state.n_qubits,
        data: match &state.data {
            Pure(psi) => {
                // We can't apply a channel with more than one Kraus operator (Choi rank > 1) to a
                // pure state directly, so if the Choi rank is bigger than 1, promote to
                // Mixed and recurse.
                if ks.shape()[0] == 1 {
                    Pure({
                        let k: ArrayView2<C64> = ks.slice(s![0, .., ..]);
                        k.dot(psi)
                    })
                } else {
                    apply_kraus_decomposition(ks, &state.to_mixed())?.data
                }
            }
            Mixed(rho) => Mixed({
                let mut sum: Array2<C64> = Array::zeros((rho.shape()[0], rho.shape()[1]));
                for k in ks.axis_iter(Axis(0)) {
                    sum = sum + rho.conjugate_by(&k);
                }
                sum
            }),
            Stabilizer(_tableau) => {
                return Err(
                    "TODO: Promote stabilizer state to state vector and recurse.".to_string(),
                )
            }
        },
    })
}

pub(crate) fn apply_pauli_channel(
    paulis: &[(f64, Vec<Pauli>)],
    state: &State,
) -> Result<State, String> {
    Ok(State {
        n_qubits: state.n_qubits,
        data: match &state.data {
            Pure(_) | Mixed(_) => {
                // Promote and recurse.
                let promoted = promote_pauli_channel(paulis);
                return promoted.apply(state);
            }
            Stabilizer(tableau) => {
                // TODO[perf]: Introduce an apply_mut method to
                //             avoid extraneous cloning.
                let mut new_tableau = tableau.clone();
                // Sample a Pauli and apply it.
                let weighted = WeightedIndex::new(paulis.iter().map(|(pr, _)| pr)).unwrap();
                let idx = weighted.sample(&mut thread_rng());
                let pauli = &(&paulis)[idx].1;
                // TODO: Consider moving the following to a method
                //       on Tableau itself.
                for (idx_qubit, p) in pauli.iter().enumerate() {
                    match p {
                        Pauli::I => (),
                        Pauli::X => new_tableau.apply_x_mut(idx_qubit),
                        Pauli::Y => new_tableau.apply_y_mut(idx_qubit),
                        Pauli::Z => new_tableau.apply_z_mut(idx_qubit),
                    }
                }
                Stabilizer(new_tableau)
            }
        },
    })
}
