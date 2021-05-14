// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// The following two attributes include the README.md for this crate when
// the "doc" feature is turned on (requires +nightly).
// See https://github.com/rust-lang/rust/issues/82768#issuecomment-803935643
// for discussion.
#![cfg_attr(feature = "doc", feature(extended_key_value_attributes))]
#![cfg_attr(feature = "doc", cfg_attr(feature = "doc", doc = include_str!("../README.md")))]

#[macro_use(array, s)]
extern crate ndarray;

extern crate derive_more;
extern crate serde;
use serde::{Deserialize, Serialize};

pub mod c_api;
mod channels;
pub mod common_matrices;
mod instrument;
pub mod linalg;
mod noise_model;
mod states;
mod utils;

pub use crate::channels::*;
pub use crate::instrument::*;
pub use crate::noise_model::NoiseModel;
pub use crate::states::State;
pub use crate::utils::*;

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct QubitSized<T> {
    n_qubits: usize,
    data: T,
}
