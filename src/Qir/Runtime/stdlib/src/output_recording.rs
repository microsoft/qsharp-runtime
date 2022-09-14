// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
#![deny(clippy::all, clippy::pedantic)]

use std::os::raw::c_double;

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
