// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#![cfg_attr(all(), doc = include_str!("../README.md"))]
#![cfg_attr(
    feature = "document-features",
    cfg_attr(doc, doc = ::document_features::document_features!())
)]
// Set linting rules for documentation. We will stop the build on missing docs,
// or docs with known broken links. We only enable this when all relevant
// features are enabled, otherwise the docs build will fail on links to
// features that are disabled for the current build.
#![cfg_attr(all(doc, feature = "python"), deny(rustdoc::broken_intra_doc_links))]
#![cfg_attr(doc, deny(missing_docs))]
// This linting rule raises a warning on any documentation comments
// that are missing an `# Example` section. Currently, that raises a lot of
// warnings when building docs, but ideally we should make sure to address
// warnings going forward by adding relevant examples.
#![cfg_attr(doc, warn(rustdoc::missing_doc_code_examples))]
#![feature(backtrace)]

#[macro_use(array, s)]
extern crate ndarray;

extern crate derive_more;
extern crate serde;
use serde::{Deserialize, Serialize};
use std::usize;

pub mod c_api;
mod chp_decompositions;
pub mod common_matrices;
pub mod error;
mod instrument;
pub mod linalg;
pub mod math;
mod noise_model;
mod paulis;
mod processes;
mod states;
mod tableau;
mod utils;

pub use crate::instrument::*;
pub use crate::noise_model::NoiseModel;
pub use crate::paulis::*;
pub use crate::processes::*;
pub use crate::states::{State, StateData};
pub use crate::tableau::Tableau;
pub use crate::utils::*;

// When documenting, we want to make sure to expose the Python module as
// public so that rustdoc can see its documentation. When the "python" crate
// feature is off, the module shouldn't even be private.
#[cfg(all(not(doc), feature = "python"))]
mod python;
#[cfg(all(doc, feature = "python"))]
pub mod python;

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

/// Metadata about how this crate was built.
pub mod built_info {
    include!(concat!(env!("OUT_DIR"), "/built.rs"));
}
