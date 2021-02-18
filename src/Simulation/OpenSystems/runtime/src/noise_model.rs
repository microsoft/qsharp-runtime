use num_traits::{ Zero, One };
use crate::C64;
use crate::common_matrices;
use crate::states::StateData::Mixed;
use crate::states::State;
use crate::channels::Channel;
use crate::channels::ChannelData::{ Unitary, KrausDecomposition };
use crate::instrument::Instrument;
use crate::linalg::HasDagger;

use serde::{Serialize, Deserialize};

#[derive(Serialize, Deserialize)]
pub struct NoiseModel {
    pub initial_state: State,
    pub i: Channel,
    pub x: Channel,
    pub y: Channel,
    pub z: Channel,
    pub h: Channel,
    pub s: Channel,
    pub s_adj: Channel,
    pub t: Channel,
    pub t_adj: Channel,
    pub cnot: Channel,
    pub z_meas: Instrument
}

impl NoiseModel {
    pub fn ideal() -> NoiseModel {
        let i = Channel {
            n_qubits: 1,
            data: Unitary(common_matrices::i())
        };
        let z = Channel {
            n_qubits: 1,
            data: Unitary(common_matrices::z())
        };
        let z_meas = Instrument {
            effects: vec![
                Channel {
                    n_qubits: 1,
                    data: KrausDecomposition(array![
                        [
                            [C64::one(), C64::zero()],
                            [C64::zero(), C64::zero()]
                        ]
                    ])
                },
                Channel {
                    n_qubits: 1,
                    data: KrausDecomposition(array![
                        [
                            [C64::zero(), C64::zero()],
                            [C64::zero(), C64::one()]
                        ]
                    ])
                },
            ]
        };
        NoiseModel {
            initial_state: State {
                n_qubits: 1,
                data: Mixed((common_matrices::i() + common_matrices::z()) / 2.0)
            },
            i: i,
            x: Channel {
                n_qubits: 1,
                data: Unitary(common_matrices::x())
            },
            y: Channel {
                n_qubits: 1,
                data: Unitary(common_matrices::y())
            },
            z: z,
            h: Channel {
                n_qubits: 1,
                data: Unitary(common_matrices::h())
            },
            t: Channel {
                n_qubits: 1,
                data: Unitary(common_matrices::t())
            },
            t_adj: Channel {
                n_qubits: 1,
                data: Unitary(common_matrices::t().dag())
            },
            s: Channel {
                n_qubits: 1,
                data: Unitary(common_matrices::s())
            },
            s_adj: Channel {
                n_qubits: 1,
                data: Unitary(common_matrices::s().dag())
            },
            cnot: Channel {
                n_qubits: 2,
                data: Unitary(common_matrices::cnot())
            },
            z_meas: z_meas
        }
    }
}
