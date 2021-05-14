use crate::channels::Channel;
use crate::channels::ChannelData::{KrausDecomposition, Unitary};
use crate::common_matrices;
use crate::instrument::Instrument;
use crate::linalg::HasDagger;
use crate::states::State;
use crate::states::StateData::Mixed;
use crate::C64;
use num_traits::{One, Zero};

use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug)]
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
    pub z_meas: Instrument,
}

impl NoiseModel {
    pub fn ideal() -> NoiseModel {
        let i = Channel {
            n_qubits: 1,
            data: Unitary(common_matrices::i()),
        };
        let z = Channel {
            n_qubits: 1,
            data: Unitary(common_matrices::z()),
        };
        let z_meas = Instrument {
            effects: vec![
                Channel {
                    n_qubits: 1,
                    data: KrausDecomposition(array![[
                        [C64::one(), C64::zero()],
                        [C64::zero(), C64::zero()]
                    ]]),
                },
                Channel {
                    n_qubits: 1,
                    data: KrausDecomposition(array![[
                        [C64::zero(), C64::zero()],
                        [C64::zero(), C64::one()]
                    ]]),
                },
            ],
        };
        NoiseModel {
            initial_state: State {
                n_qubits: 1,
                data: Mixed((common_matrices::i() + common_matrices::z()) / 2.0),
            },
            i,
            x: Channel {
                n_qubits: 1,
                data: Unitary(common_matrices::x()),
            },
            y: Channel {
                n_qubits: 1,
                data: Unitary(common_matrices::y()),
            },
            z,
            h: Channel {
                n_qubits: 1,
                data: Unitary(common_matrices::h()),
            },
            t: Channel {
                n_qubits: 1,
                data: Unitary(common_matrices::t()),
            },
            t_adj: Channel {
                n_qubits: 1,
                data: Unitary(common_matrices::t().dag()),
            },
            s: Channel {
                n_qubits: 1,
                data: Unitary(common_matrices::s()),
            },
            s_adj: Channel {
                n_qubits: 1,
                data: Unitary(common_matrices::s().dag()),
            },
            cnot: Channel {
                n_qubits: 2,
                data: Unitary(common_matrices::cnot()),
            },
            z_meas,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn can_serialize_noise_model() {
        let noise_model = NoiseModel::ideal();
        let _json = serde_json::to_string(&noise_model);
    }
}
