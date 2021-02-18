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

pub fn test() {
    println!("Test!");
    let mut noise = NoiseModel::ideal();
    noise.h = noise.h * depolarizing_channel(0.025f64);
    match &noise.h.data {
        Unitary(u) => println!("{}", u),
        KrausDecomposition(ks) => println!("{}", ks)
    };
    let noise = noise;

    let mut rho = noise.initial_state.clone();
    // rho = rho.extend(1);
    // rho = noise.h.apply_to(&[0], &rho).unwrap();
    // rho = noise.h.apply_to(&[0], &rho).unwrap();
    // rho = noise.h.apply_to(&[0], &rho).unwrap();
    // rho = noise.h.apply_to(&[0], &rho).unwrap();
    // rho = noise.h.apply_to(&[0], &rho).unwrap();

    println!("{}", rho);

    let pi_0 = &noise.z_meas.effects[0];
    let rho_0 = pi_0.apply_to(&[0], &rho).unwrap();

    println!("{}", rho_0);

    println!("");
    println!("{}", rho.ideal_z_meas_pr(0));
    println!("{}", rho.ideal_z_meas_pr(1));

    println!("");
    println!("{:?}", depolarizing_channel(0.05f64));

    // println!("{}", X())
}
