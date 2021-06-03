// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use crate::{states::StateData::Mixed, StateData};
use crate::{Process, ProcessData, C64};
use num_traits::{One, Zero};
use rand::Rng;
use std::iter::Iterator;

use crate::linalg::Trace;
use crate::State;

use serde::{Deserialize, Serialize};

// TODO[design]: Instrument works pretty differently from State and Process; should
//               likely refactor for consistency.

#[derive(Serialize, Deserialize, Debug)]
/// Represents a quantum instrument; that is, a process that accepts a quantum
/// state and returns the new state of a system and classical data extracted
/// from that system.
pub enum Instrument {
    /// The effects of the instrument, represented as completely positive
    /// trace non-increasing (CPTNI) processes.
    Effects(Vec<Process>),

    /// An instrument that measures a single qubit in the $Z$-basis, up to a
    /// readout error (probability of result being flipped).
    ///
    /// Primarily useful when working with stabilizer states or other
    /// subtheories.
    ZMeasurement {
        /// Probability with which a result is flipped.
        pr_readout_error: f64,
    },
}

impl Instrument {
    /// Samples from this instrument, returning the measurement result and
    /// the new state of the system conditioned on that measurement result.
    pub fn sample(&self, idx_qubits: &[usize], state: &State) -> (usize, State) {
        match self {
            Instrument::Effects(ref effects) => sample_effects(effects, idx_qubits, state),
            Instrument::ZMeasurement { pr_readout_error } => {
                if idx_qubits.len() != 1 {
                    panic!("Z-basis measurement instruments only supported for single qubits.");
                }
                let idx_target = idx_qubits[0];
                match state.data {
                    StateData::Pure(_) | StateData::Mixed(_) => {
                        // Get the ideal Z measurement instrument, apply it,
                        // and then assign a readout error.
                        // TODO[perf]: Cache this instrument as a lazy static.
                        let ideal_z_meas = Instrument::Effects(vec![
                            Process {
                                n_qubits: 1,
                                data: ProcessData::KrausDecomposition(array![[
                                    [C64::one(), C64::zero()],
                                    [C64::zero(), C64::zero()]
                                ]]),
                            },
                            Process {
                                n_qubits: 1,
                                data: ProcessData::KrausDecomposition(array![[
                                    [C64::zero(), C64::zero()],
                                    [C64::zero(), C64::one()]
                                ]]),
                            },
                        ]);
                        let (result, new_state) = ideal_z_meas.sample(idx_qubits, state);
                        let result = (result == 1) ^ rand::thread_rng().gen_bool(*pr_readout_error);
                        (if result { 1 } else { 0 }, new_state)
                    }
                    StateData::Stabilizer(ref tableau) => {
                        // TODO[perf]: allow instruments to sample in-place,
                        //             reducing copying.
                        let mut new_tableau = tableau.clone();
                        let result = new_tableau.meas_mut(idx_target)
                            ^ rand::thread_rng().gen_bool(*pr_readout_error);
                        (
                            if result { 1 } else { 0 },
                            State {
                                n_qubits: state.n_qubits,
                                data: StateData::Stabilizer(new_tableau),
                            },
                        )
                    }
                }
            }
        }
    }

    // TODO: Add more methods for making new instruments in convenient ways.
}

fn sample_effects(effects: &[Process], idx_qubits: &[usize], state: &State) -> (usize, State) {
    let mut possible_outcomes = effects
        .iter()
        .enumerate()
        .map(|(idx, effect)| {
            let output_state = effect.apply_to(idx_qubits, state).unwrap();
            let tr = (&output_state).trace();
            (idx, output_state, tr.re)
        })
        .collect::<Vec<_>>();
    let mut rng = rand::thread_rng();
    let random_sample: f64 = rng.gen();
    for (idx, cum_pr) in possible_outcomes
        .iter()
        .scan(0.0f64, |acc, (_idx, _, pr)| {
            *acc += *pr;
            Some(*acc)
        })
        .enumerate()
    {
        if random_sample < cum_pr {
            // In order to not have to copy the output state, we need
            // to be able to move it out from the vector. To do so,
            // we retain only the element of the vector whose index
            // is the one we want and then pop it, leaving an empty
            // vector (that is, a vector that owns no data).
            possible_outcomes.retain(|(i, _, _)| idx == *i);
            let (_, mut output_state, tr) = possible_outcomes.pop().unwrap();
            if tr.abs() >= 1e-10 {
                if let Mixed(ref rho) = output_state.data {
                    output_state.data = Mixed(rho * (1.0f64 / tr));
                } else {
                    panic!("Couldn't renormalize, expected mixed output from instrument.");
                }
            }
            return (idx, output_state);
        }
    }
    let (idx, output_state, _) = possible_outcomes.pop().unwrap();
    drop(possible_outcomes);
    (idx, output_state)
}
