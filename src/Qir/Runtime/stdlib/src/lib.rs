// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// This module simply wraps and reexports the API available from the qir-stdlib. See the Cargo.toml
// for the source of the library implementation.
pub use qir_stdlib::{
    arrays::*, bigints::*, callables::*, math::*, output_recording::*, range_support::*,
    strings::*, tuples::*, *,
};
