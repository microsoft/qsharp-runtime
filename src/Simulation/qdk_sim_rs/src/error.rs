// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

//! Module defining common errors that can occur during quantum simulations.

use std::str::Utf8Error;

use miette::Diagnostic;
use ndarray::ShapeError;
use thiserror::Error;

/// Represents errors that can occur during linear algebra operations.
#[derive(Debug, Diagnostic, Error)]
pub enum QdkSimError {
    // NB: As a design note, please consider if a more specific error is better
    //     suited for your usecase before returning `MiscError`.
    /// Raised on miscellaneous errors.
    #[error("{0}")]
    #[diagnostic(code(qdk_sim::other))]
    MiscError(String),

    /// Raised when functionality that has not yet been implemented is called.
    #[error("Not yet implemented: {0}")]
    #[diagnostic(code(qdk_sim::not_yet_implemented))]
    NotYetImplemented(String),

    /// Raised when the wrong number of qubits is provided for a quantum
    /// process.
    #[error("Channel acts on {expected} qubits, but was applied to an {actual}-qubit state.")]
    #[diagnostic(code(qdk_sim::process::wrong_n_qubits))]
    WrongNumberOfQubits {
        /// The number of qubits that was expected, as given by the size of the
        /// channel to be applied.
        expected: usize,
        /// The actual number of qubits for the given state.
        actual: usize,
    },

    /// Raised when a channel cannot be applied to a given state due to a
    /// mismatch between channel and state kinds.
    #[error("Unsupported quantum process variant {channel_variant} for applying to state variant {state_variant}.")]
    #[diagnostic(code(qdk_sim::process::unsupported_apply))]
    UnsupportedApply {
        /// The enum variant of the channel to be applied.
        channel_variant: &'static str,
        /// The enum variant of the state that the channel is to be applied to.
        state_variant: &'static str,
    },

    /// Raised when a matrix is singular, and thus does not have an inverse.
    #[error("expected invertible matrix, but got a singular or very poorly conditioned matrix (det = {det})")]
    #[diagnostic(code(qdk_sim::linalg::singular))]
    Singular {
        /// Actual determinant of the matrix which caused this error.
        det: f64,
    },

    /// Raised when a shape error occurs internally to [`qdk_sim`].
    #[error(transparent)]
    #[diagnostic(code(qdk_sim::linalg::internal_shape))]
    InternalShapeError(ShapeError),

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

    /// Raised when no noise model exists for a given name.
    #[error("{0} is not the name of any valid noise model")]
    #[diagnostic(code(qdk_sim::noise_model::invalid_repr))]
    InvalidNoiseModel(String),

    /// Raised when an initial state representation is invalid.
    #[error("C API error: {0} is not a valid initial state representation")]
    #[diagnostic(code(qdk_sim::c_api::invalid_repr))]
    InvalidRepresentation(String),

    /// Raised when a null pointer is passed through the C API.
    #[error("C API error: {0} was null")]
    #[diagnostic(code(qdk_sim::c_api::nullptr))]
    NullPointer(String),

    /// Raised when an invalid simulator ID is passed to the C API.
    #[error("C API error: No simulator with ID {invalid_id} exists. Expected: {expected:?}.")]
    #[diagnostic(code(qdk_sim::c_api::invalid_sim))]
    NoSuchSimulator {
        /// The invalid simulator id which caused this error.
        invalid_id: usize,
        /// A list of valid simulator ids at the point when this error occured.
        expected: Vec<usize>,
    },

    /// Raised when a string passed to the C API contains could not be decoded
    /// as a UTF-8 string.
    #[error("C API error: UTF-8 error decoding {arg_name} argument: {source}")]
    #[diagnostic(code(qdk_sim::c_api::utf8))]
    InvalidUtf8InArgument {
        /// The name of the argument containing invalid UTF-8 data.
        arg_name: String,

        /// The underlying UTF-8 error that caused this error.
        #[source]
        source: Utf8Error,
    },

    /// Raised when a JSON serialization error occurs during a C API call.
    #[error(transparent)]
    #[diagnostic(code(qdk_sim::c_api::json_deser))]
    JsonDeserializationError(#[from] serde_json::Error),

    /// Raised when an unanticipated error occurs during a C API call.
    #[error(transparent)]
    #[diagnostic(code(qdk_sim::c_api::unanticipated))]
    UnanticipatedCApiError(#[from] anyhow::Error),
}
