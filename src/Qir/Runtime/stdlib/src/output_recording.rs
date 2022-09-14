// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
#![deny(clippy::all, clippy::pedantic)]

use std::{ffi::CString, os::raw::c_double};

#[no_mangle]
pub extern "C" fn __quantum__rt__array_start_record_output() {
    println!("RESULT\tARRAY_START");
}

#[no_mangle]
pub extern "C" fn __quantum__rt__array_end_record_output() {
    println!("RESULT\tARRAY_END");
}

#[no_mangle]
pub extern "C" fn __quantum__rt__tuple_start_record_output() {
    println!("RESULT\tTUPLE_START");
}

#[no_mangle]
pub extern "C" fn __quantum__rt__tuple_end_record_output() {
    println!("RESULT\tTUPLE_END");
}

#[no_mangle]
pub extern "C" fn __quantum__rt__int_record_output(val: i64) {
    println!("RESULT\t{}", val);
}

#[no_mangle]
pub extern "C" fn __quantum__rt__double_record_output(val: c_double) {
    println!(
        "RESULT\t{}",
        if (val.floor() - val.ceil()).abs() < c_double::EPSILON {
            // The value is a whole number, which by convention is displayed with one decimal point
            // to differentiate it from an integer value.
            format!("{:.1}", val)
        } else {
            format!("{}", val)
        }
    );
}

#[no_mangle]
pub extern "C" fn __quantum__rt__bool_record_output(val: bool) {
    println!("RESULT\t{}", val);
}

/// # Safety
///
/// This function should only be called with strings created by `__quantum__rt__string_*` functions.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__message_record_output(str: *const CString) {
    println!(
        "INFO\t{}",
        (*str)
            .to_str()
            .expect("Unable to convert input string")
            .escape_default()
    );
}
