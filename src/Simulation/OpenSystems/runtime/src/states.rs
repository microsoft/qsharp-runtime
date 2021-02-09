
use crate::Z;
use crate::linalg::extend_one_to_n;
use core::fmt::Display;
use num_traits::One;
use num_traits::Zero;
use crate::states::StateData::Mixed;
use crate::states::StateData::Pure;
use crate::QubitSized;
use crate::ONE_C;
use crate::linalg::Trace;
use ndarray::Array;
use crate::C64;
use ndarray::{ Array1, Array2 };
use derive_more::{Display};
use std::convert::TryInto;
use crate::linalg::{ HasDagger, Tensor };
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

fn elementary_vec<T: Zero + One>(idx: usize, n: usize) -> Array1<T> {
    Array::from_shape_fn(n, |i| if i == idx {T::one()} else {T::zero()})
}

fn elementary_matrix<T: Zero + One>((idx0, idx1): (usize, usize), (n, m): (usize, usize)) -> Array2<T> {
    Array::from_shape_fn((n, m), |(i, j)| if i == idx0 && j == idx1 {
        T::one()
    } else {
        T::zero()
    })
}

impl State {
    pub fn extend(self: &Self, n_qubits: usize) -> State {
        let new_dim = 2usize.pow(n_qubits.try_into().unwrap());
        State {
            n_qubits: self.n_qubits + n_qubits,
            data: match &self.data {
                Pure(psi) => Pure(psi.tensor(&elementary_vec(0, new_dim))),
                Mixed(rho) => Mixed(rho.tensor(&elementary_matrix((0, 0), (new_dim, new_dim))))
            }
        }
    }

    pub fn new_mixed(n_qubits: usize) -> State {
        let new_dim = 2usize.pow(n_qubits.try_into().unwrap());
        State {
            n_qubits: n_qubits,
            data: Mixed(elementary_matrix((0, 0), (new_dim, new_dim)))
        }
    }

    // TODO: deprecate this in favor of relying on the measurement probabilities
    //       returned by an instrument.
    pub fn ideal_z_meas_pr(&self, idx_qubit: usize) -> f64 {
        match &self.data {
            Pure(psi) => todo!(),
            Mixed(rho) => {
                let meas_op = extend_one_to_n(&Z(), idx_qubit, self.n_qubits);
                let expectation: C64 = rho.dot(&meas_op).trace();
                (1.0 + expectation.re) / 2.0
            }
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

// impl DensityOperator {
//     fn new(n_qubits: usize) -> Self {
//         let dim = 2usize.pow(n_qubits.try_into().unwrap());
//         let mut data = Array::zeros((dim, dim));
//         data[(0, 0)] = ONE_C;
//         DensityOperator {
//             n_qubits: n_qubits,
//             data: data
//         }
//     }
// }
