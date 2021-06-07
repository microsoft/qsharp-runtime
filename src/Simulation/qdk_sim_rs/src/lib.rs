// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// The following two attributes include the README.md for this crate when
// building docs (requires +nightly).
// See https://github.com/rust-lang/rust/issues/82768#issuecomment-803935643
// for discussion.
#![cfg_attr(doc, feature(extended_key_value_attributes))]
#![cfg_attr(doc, cfg_attr(doc, doc = include_str!("../README.md")))]
// Set linting rules for documentation. We will stop the build on missing docs,
// or docs with known broken links. We only enable this when all relevant
// features are enabled, otherwise the docs build will fail on links to
// features that are disabled for the current build.
#![cfg_attr(all(doc, feature = "python"), deny(rustdoc::broken_intra_doc_links))]
#![cfg_attr(doc, deny(missing_docs))]
#![cfg_attr(doc, warn(missing_doc_code_examples))]

#[macro_use(array, s)]
extern crate ndarray;

extern crate derive_more;
extern crate serde;
use serde::{Deserialize, Serialize};
use std::usize;

pub mod c_api;
mod chp_decompositions;
pub mod common_matrices;
mod instrument;
pub mod linalg;
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
