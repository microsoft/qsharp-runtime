// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

extern crate cbindgen;

use std::env;

fn main() -> Result<(), String> {
    built::write_built_file().expect("Failed to acquire build-time information");

    let crate_dir = env::var("CARGO_MANIFEST_DIR").unwrap();

    cbindgen::generate_with_config(
        &crate_dir,
        cbindgen::Config {
            language: cbindgen::Language::C,
            ..Default::default()
        },
    )
    .map_err(|e| e.to_string())?
    .write_to_file("include/qdk_sim.h");

    cbindgen::generate_with_config(
        &crate_dir,
        cbindgen::Config {
            ..Default::default()
        },
    )
    .map_err(|e| e.to_string())?
    .write_to_file("include/qdk_sim.hpp");

    Ok(())
}
