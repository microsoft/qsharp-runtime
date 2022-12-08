// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use std::path::PathBuf;
use std::{env, fs};

fn main() -> Result<(), String> {
    let include_dir = env::var_os("DEP_QIR_STDLIB_INCLUDE")
        .map(PathBuf::from)
        .ok_or_else(|| "Environment variable DEP_QIR-STDLIB_INCLUDE not defined.".to_string())?;

    let out_dir = env::var_os("OUT_DIR")
        .map(PathBuf::from)
        .ok_or_else(|| "Environment variable OUT_DIR not defined.".to_string())?;
    let include_dest_dir = out_dir.join("..").join("..").join("include");
    fs::create_dir_all(&include_dest_dir).map_err(|err| {
        format!(
            "Unable to create destination folder for include files: {}",
            err
        )
    })?;

    let include_files = fs::read_dir(include_dir)
        .map_err(|err| format!("Unable to read files in include directory: {}", err))?;
    for file in include_files {
        let file = file.unwrap();
        fs::copy(file.path(), include_dest_dir.join(file.file_name())).map_err(|err| {
            format!(
                "Failed to copy file '{}': {}",
                file.file_name().to_str().unwrap(),
                err
            )
        })?;
    }

    Ok(())
}
