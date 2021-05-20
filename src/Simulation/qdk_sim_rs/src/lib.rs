// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// The following two attributes include the README.md for this crate when
// the "doc" feature is turned on (requires +nightly).
// See https://github.com/rust-lang/rust/issues/82768#issuecomment-803935643
// for discussion.
#![cfg_attr(feature = "doc", feature(extended_key_value_attributes))]
#![cfg_attr(feature = "doc", cfg_attr(feature = "doc", doc = include_str!("../README.md")))]
#![cfg_attr(feature = "doc", deny(missing_docs))]
#![cfg_attr(feature = "doc", warn(missing_doc_code_examples))]

#[macro_use(array, s)]
extern crate ndarray;

extern crate derive_more;
extern crate serde;
use std::usize;

use linalg::Tensor;
use ndarray::Array2;
use serde::{Deserialize, Serialize};

pub mod c_api;
pub mod common_matrices;
mod instrument;
pub mod linalg;
mod noise_model;
mod processes;
mod states;
mod tableau;
mod utils;

pub use crate::instrument::*;
pub use crate::noise_model::NoiseModel;
pub use crate::processes::*;
pub use crate::states::{State, StateData};
pub use crate::tableau::Tableau;
pub use crate::utils::*;

#[cfg(feature = "python")]
mod python;

/// Represents that a given type has a size that can be measured in terms
/// of a number of qubits (e.g.: [`State`]).
#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct QubitSized<T> {
    n_qubits: usize,
    data: T,
}

impl<T> QubitSized<T> {
    /// Returns the number of qubits that this value relates to.
    pub fn get_n_qubits(&self) -> usize {
        self.n_qubits
    }
}

/// An element of the single-qubit Pauli group.
#[derive(Debug, Copy, Clone, Serialize, Deserialize)]
pub enum Pauli {
    /// The identity operator.
    I = 0,
    /// The Pauli $X$ operator.
    X = 1,
    /// The Pauli $Y$ operator.
    Y = 3,
    /// The Pauli $Z$ operator.
    Z = 2,
}

/// Types that can be converted to unitary matrices.
pub trait AsUnitary {
    /// Returns a representation as a unitary matrix.
    fn as_unitary(&self) -> Array2<C64>;
}

impl AsUnitary for Pauli {
    fn as_unitary(&self) -> Array2<C64> {
        match self {
            Pauli::I => common_matrices::nq_eye(1),
            Pauli::X => common_matrices::x(),
            Pauli::Y => common_matrices::y(),
            Pauli::Z => common_matrices::z(),
        }
    }
}

impl AsUnitary for Vec<Pauli> {
    fn as_unitary(&self) -> Array2<C64> {
        let sq_unitaries = self.iter().map(|p| p.as_unitary());
        let result = sq_unitaries.reduce(|p, q| p.tensor(&q));
        result.unwrap()
    }
}

/// Metadata about how this crate was built.
pub mod built_info {
    include!(concat!(env!("OUT_DIR"), "/built.rs"));
}
