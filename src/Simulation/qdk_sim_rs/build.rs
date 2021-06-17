// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use std::env;
use std::path::Path;

fn main() -> Result<(), String> {
    built::write_built_file().expect("Failed to acquire build-time information");

    Ok(())
}
