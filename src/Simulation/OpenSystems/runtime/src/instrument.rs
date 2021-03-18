// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use crate::states::StateData::Mixed;
use crate::Channel;
use rand::Rng;
use std::iter::Iterator;

use crate::linalg::Trace;
use crate::State;

use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug)]
pub struct Instrument {
    pub effects: Vec<Channel>,
}

impl Instrument {
    pub fn sample(&self, idx_qubits: &[usize], state: &State) -> (usize, State) {
        let mut possible_outcomes = self
            .effects
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
                *acc = *acc + *pr;
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
}
