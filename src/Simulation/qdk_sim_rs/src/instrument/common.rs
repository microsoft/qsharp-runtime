// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use cauchy::c64;
use num_traits::{One, Zero};

use crate::{Instrument, Process, ProcessData};

impl Instrument {
    /// Returns an ideal single-qubit measurement instrument with two effects,
    /// projecting onto the $\ket{0}$ and $\ket{1}$ states.
    pub fn ideal_z_meas() -> Self {
        Instrument::Effects(vec![
            Process {
                n_qubits: 1,
                data: ProcessData::KrausDecomposition(array![[
                    [c64::one(), c64::zero()],
                    [c64::zero(), c64::zero()]
                ]]),
            },
            Process {
                n_qubits: 1,
                data: ProcessData::KrausDecomposition(array![[
                    [c64::zero(), c64::zero()],
                    [c64::zero(), c64::one()]
                ]]),
            },
        ])
    }

    // TODO: Add more methods for making new instruments in convenient ways.
}
