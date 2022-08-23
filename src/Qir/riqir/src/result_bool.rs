// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
#![deny(clippy::all, clippy::pedantic)]

use std::ffi::c_void;

#[no_mangle]
pub extern "C" fn __quantum__rt__result_get_zero() -> *mut c_void {
    std::ptr::null_mut()
}

#[no_mangle]
pub extern "C" fn __quantum__rt__result_get_one() -> *mut c_void {
    1 as *mut c_void
}

#[no_mangle]
pub extern "C" fn __quantum__rt__result_equal(r1: *mut c_void, r2: *mut c_void) -> bool {
    r1 == r2
}

#[no_mangle]
pub extern "C" fn __quantum__rt__result_update_reference_count(_res: *mut c_void, _update: i32) {
    // no-op
}
