// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use ndarray::Array2;
use serde::{Deserialize, Serialize};

use crate::{common_matrices, linalg::Tensor, C64};

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
