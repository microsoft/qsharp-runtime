// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use std::{ffi::CString, os::raw::c_double};

use crate::strings::double_to_string;

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
    println!("RESULT\t{}", double_to_string(val));
}

#[no_mangle]
pub extern "C" fn __quantum__rt__bool_record_output(val: bool) {
    println!("RESULT\t{}", val);
}

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
