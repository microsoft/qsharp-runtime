// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#[macro_use(array, s)]
extern crate ndarray;

extern crate derive_more;
extern crate serde;

pub mod c_api;
mod channels;
pub mod common_matrices;
mod instrument;
pub mod linalg;
mod noise_model;
mod states;
mod utils;

pub use crate::channels::Channel;
pub use crate::channels::ChannelData::KrausDecomposition;
pub use crate::channels::ChannelData::Unitary;
pub use crate::channels::{amplitude_damping_channel, depolarizing_channel};
pub use crate::common_matrices::*;
pub use crate::linalg::zeros_like;
pub use crate::noise_model::NoiseModel;
pub use crate::states::State;
pub use crate::utils::*;

use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct QubitSized<T> {
    n_qubits: usize,
    data: T,
}
