// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use crate::common_matrices;
use core::fmt::Display;
use num_traits::One;
use crate::states::StateData::Mixed;
use crate::states::StateData::Pure;
use crate::QubitSized;
use crate::linalg::Trace;
use crate::C64;
use ndarray::{ Array1, Array2 };
use std::convert::TryInto;
use crate::linalg::{ Tensor };
use serde::{ Serialize, Deserialize };

#[derive(Clone, Debug, Serialize, Deserialize)]
pub enum StateData {
    Pure(Array1<C64>),
    Mixed(Array2<C64>)
}

pub type State = QubitSized<StateData>;

impl Display for State {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::result::Result<(), std::fmt::Error> {
        write!(
            f,
            "Register state on {} qubits ({} representation)\nData:\n{}",
            self.n_qubits,
            match self.data {
                Pure(_) => "state vector",
                Mixed(_) => "density operator"
            },
            self.data
        )
    }
}

impl Display for StateData {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::result::Result<(), std::fmt::Error> {
        match self {
            Pure(psi) => write!(f, "{}", psi),
            Mixed(rho) => write!(f, "{}", rho)
        }
    }
}




impl State {
    pub fn extend(self: &Self, n_qubits: usize) -> State {
        let new_dim = 2usize.pow(n_qubits.try_into().unwrap());
        State {
            n_qubits: self.n_qubits + n_qubits,
            data: match &self.data {
                Pure(psi) => Pure(psi.tensor(&common_matrices::elementary_vec(0, new_dim))),
                Mixed(rho) => Mixed(rho.tensor(&common_matrices::elementary_matrix((0, 0), (new_dim, new_dim))))
            }
        }
    }

    pub fn new_mixed(n_qubits: usize) -> State {
        let new_dim = 2usize.pow(n_qubits.try_into().unwrap());
        State {
            n_qubits: n_qubits,
            data: Mixed(common_matrices::elementary_matrix((0, 0), (new_dim, new_dim)))
        }
    }
}

impl Trace for &State {
    type Output = C64;

    fn trace(self) -> Self::Output {
        match &self.data {
            Pure(_) => C64::one(),
            Mixed(ref rho) => (&rho).trace()
        }
    }
}


#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn trace_pure_is_one() {
        let pure = State {
            n_qubits: 1usize,
            data: Pure(common_matrices::elementary_vec(0, 2))
        };
        assert_eq!(pure.trace(), C64::one());
    }
}
