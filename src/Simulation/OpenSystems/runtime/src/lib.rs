// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#[macro_use(array)]

extern crate ndarray;
extern crate derive_more;
extern crate serde;

pub mod c_api;
mod utils;
mod common_matrices;
mod states;
mod linalg;
mod channels;
mod noise_model;
mod instrument;

pub use crate::channels::depolarizing_channel;
pub use crate::noise_model::NoiseModel;
pub use crate::utils::*;
pub use crate::common_matrices::*;
pub use crate::linalg::zeros_like;
pub use crate::states::State;
pub use crate::channels::Channel;
pub use crate::channels::ChannelData::KrausDecomposition;
pub use crate::channels::ChannelData::Unitary;

use serde::{ Serialize, Deserialize };

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct QubitSized<T> {
    n_qubits: usize,
    data: T
}
