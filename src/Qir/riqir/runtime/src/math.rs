// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
#![deny(clippy::all, clippy::pedantic)]

// TODO: transition math functions to `__quantum__rt` once compiler support is ready.

use rand::Rng;
use std::os::raw::c_double;

use crate::{__quantum__rt__fail, strings::convert};

#[no_mangle]
pub extern "C" fn __quantum__qis__nan__body() -> c_double {
    c_double::NAN
}

#[no_mangle]
pub extern "C" fn __quantum__qis__isnan__body(val: c_double) -> bool {
    val.is_nan()
}

#[no_mangle]
pub extern "C" fn __quantum__qis__infinity__body() -> c_double {
    c_double::INFINITY
}

#[no_mangle]
pub extern "C" fn __quantum__qis__isinf__body(val: c_double) -> bool {
    val.is_infinite() && val.is_sign_positive()
}

#[no_mangle]
pub extern "C" fn __quantum__qis__isnegativeinfinity__body(val: c_double) -> bool {
    val.is_infinite() && val.is_sign_negative()
}

#[no_mangle]
pub extern "C" fn __quantum__qis__sin__body(val: c_double) -> c_double {
    val.sin()
}

#[no_mangle]
pub extern "C" fn __quantum__qis__cos__body(val: c_double) -> c_double {
    val.cos()
}
#[no_mangle]
pub extern "C" fn __quantum__qis__tan__body(val: c_double) -> c_double {
    val.tan()
}

#[no_mangle]
pub extern "C" fn __quantum__qis__arctan2__body(y: c_double, x: c_double) -> c_double {
    y.atan2(x)
}

#[no_mangle]
pub extern "C" fn __quantum__qis__sinh__body(val: c_double) -> c_double {
    val.sinh()
}

#[no_mangle]
pub extern "C" fn __quantum__qis__cosh__body(val: c_double) -> c_double {
    val.cosh()
}

#[no_mangle]
pub extern "C" fn __quantum__qis__tanh__body(val: c_double) -> c_double {
    val.tanh()
}

#[no_mangle]
pub extern "C" fn __quantum__qis__arcsin__body(val: c_double) -> c_double {
    val.asin()
}

#[no_mangle]
pub extern "C" fn __quantum__qis__arccos__body(val: c_double) -> c_double {
    val.acos()
}

#[no_mangle]
pub extern "C" fn __quantum__qis__arctan__body(val: c_double) -> c_double {
    val.atan()
}

#[no_mangle]
pub extern "C" fn __quantum__qis__sqrt__body(val: c_double) -> c_double {
    val.sqrt()
}

#[no_mangle]
pub extern "C" fn __quantum__qis__log__body(val: c_double) -> c_double {
    val.ln()
}

#[no_mangle]
pub extern "C" fn __quantum__qis__ieeeremainder__body(x: c_double, y: c_double) -> c_double {
    x - y * (x / y).round()
}

#[no_mangle]
pub extern "C" fn __quantum__qis__drawrandomint__body(min: i64, max: i64) -> i64 {
    if min > max {
        unsafe {
            __quantum__rt__fail(convert(&"Invalid Argument: minimum > maximum".to_string()));
        }
    }
    rand::thread_rng().gen_range(min..=max)
}

#[no_mangle]
pub extern "C" fn __quantum__qis__drawrandomdouble__body(min: c_double, max: c_double) -> f64 {
    if min > max {
        unsafe {
            __quantum__rt__fail(convert(&"Invalid Argument: minimum > maximum".to_string()));
        }
    }
    rand::thread_rng().gen_range(min..=max)
}
