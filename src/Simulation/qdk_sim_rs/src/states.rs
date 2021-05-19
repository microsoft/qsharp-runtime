// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use crate::common_matrices;
use crate::linalg::Tensor;
use crate::linalg::Trace;
use crate::states::StateData::{Mixed, Pure, Stabilizer};
use crate::tableau::Tableau;
use crate::QubitSized;
use crate::C64;
use core::fmt::Display;
use ndarray::{Array1, Array2, Axis};
use num_traits::One;
use serde::{Deserialize, Serialize};
use std::convert::TryInto;

#[cfg(feature = "python")]
use pyo3::prelude::*;

#[derive(Clone, Debug, Serialize, Deserialize)]
pub enum StateData {
    /// A pure state, represented as a vector of complex numbers.
    Pure(Array1<C64>),

    /// A mixed state, represented as a density operator.
    Mixed(Array2<C64>),

    /// A stabilizer state, represented as a tableau.
    Stabilizer(Tableau),
}

/// The state of a quantum system.
pub type State = QubitSized<StateData>;

impl Display for State {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::result::Result<(), std::fmt::Error> {
        write!(
            f,
            "Register state on {} qubits ({} representation)\nData:\n{}",
            self.n_qubits,
            match self.data {
                Pure(_) => "state vector",
                Mixed(_) => "density operator",
                StateData::Stabilizer(_) => "stabilizer tableau",
            },
            self.data
        )
    }
}

impl Display for StateData {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::result::Result<(), std::fmt::Error> {
        match self {
            Pure(psi) => write!(f, "{}", psi),
            Mixed(rho) => write!(f, "{}", rho),
            StateData::Stabilizer(tableau) => write!(f, "{}", tableau),
        }
    }
}

impl State {
    /// Returns a new mixed state on a given number of qubits.
    /// By convention, new mixed states start off in the "all-zeros" state,
    /// $\rho = \ket{00\cdots 0}\bra{00\cdots 0}$.
    pub fn new_mixed(n_qubits: usize) -> State {
        let new_dim = 2usize.pow(n_qubits.try_into().unwrap());
        State {
            n_qubits,
            data: Mixed(common_matrices::elementary_matrix(
                (0, 0),
                (new_dim, new_dim),
            )),
        }
    }

    /// Returns a new stabilizer state on a given number of qubits.
    /// By convention, new stabilizer states start off in the "all-zeros" state,
    /// $\left\langle Z_0, Z_1, \dots, Z_{n - 1} \right\rangle$.
    pub fn new_stabilizer(n_qubits: usize) -> State {
        State {
            n_qubits,
            data: Stabilizer(Tableau::new(n_qubits)),
        }
    }

    /// Extends this state to be a state on `n_qubits` additional qubits.
    /// New qubits are added "to the right," e.g.: $\left|\psi\right\rangle$
    /// is extended to $\left|\psi 0\right\rangle$.
    ///
    /// # Example
    ///
    /// ```
    /// # use qdk_sim::State;
    /// let rho = State::new_mixed(2);
    /// assert_eq!(5, rho.extend(3).get_n_qubits());
    /// ```
    pub fn extend(&self, n_qubits: usize) -> State {
        let new_dim = 2usize.pow(n_qubits.try_into().unwrap());
        State {
            n_qubits: self.n_qubits + n_qubits,
            data: match &self.data {
                Pure(psi) => Pure(psi.tensor(&common_matrices::elementary_vec(0, new_dim))),
                Mixed(rho) => Mixed(rho.tensor(&common_matrices::elementary_matrix(
                    (0, 0),
                    (new_dim, new_dim),
                ))),
                _ => todo!(),
            },
        }
    }

    /// Returns a copy of this state, represented as a mixed state.
    pub fn to_mixed(&self) -> State {
        State {
            n_qubits: self.n_qubits,
            data: match &self.data {
                Mixed(rho) => Mixed(rho.clone()),
                Pure(psi) => Mixed({
                    // Take the outer product of psi with its complex conjugate
                    // by using insert_axis.
                    // Note that since we can't prove that this is a dim2 array,
                    // we can't use the HasDagger trait here yet; that's a possible
                    // improvement for the HasDagger trait itself.
                    let psi = psi.view().insert_axis(Axis(1));
                    psi.t().map(|e| e.conj()) * psi
                }),
                _ => todo!(),
            },
        }
    }

    /// If the given state can be represented by a stabilizer tableau, returns
    /// that tableau.
    pub fn get_tableau(&self) -> Option<&Tableau> {
        match self.data {
            Stabilizer(ref tableau) => Some(tableau),
            _ => None,
        }
    }
}

impl Trace for &State {
    type Output = C64;

    fn trace(self) -> Self::Output {
        match &self.data {
            Pure(_) | StateData::Stabilizer(_) => C64::one(),
            Mixed(ref rho) => (&rho).trace(),
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
            data: Pure(common_matrices::elementary_vec(0, 2)),
        };
        assert_eq!(pure.trace(), C64::one());
    }
}
