// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

//! Module defining common errors that can occur during quantum simulations.

use miette::Diagnostic;
use thiserror::Error;

/// Represents errors that can occur during linear algebra operations.
#[derive(Debug, Diagnostic, Error)]
pub enum QdkSimError {
    /// Raised when a matrix is singular, and thus does not have an inverse.
    #[error("expected invertible matrix, but got a singular or very poorly conditioned matrix (det = {det})")]
    #[diagnostic(code(qdk_sim::linalg::singular))]
    Singular {
        /// Actual determinant of the matrix which caused this error.
        det: f64,
    },

    /// Raised when an algorithm requires a matrix to be square, but a
    /// rectangular matrix was passed instead.
    #[error("expected square matrix, but got shape `{0}` × `{1}")]
    #[diagnostic(code(qdk_sim::linalg::not_square))]
    NotSquare(usize, usize),

    /// Raised when an algorithm needs to convert an element between two
    /// different scalar types, but no such conversion exists for those types.
    #[error("could not convert value of type `{0}` into element type `{1}`")]
    #[diagnostic(code(qdk_sim::linalg::cannot_convert_element))]
    CannotConvertElement(String, String),
}
