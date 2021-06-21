// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

fn main() -> Result<(), String> {
    built::write_built_file().expect("Failed to acquire build-time information");

    Ok(())
}
