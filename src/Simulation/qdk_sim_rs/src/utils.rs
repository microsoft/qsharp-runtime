// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use num_complex::Complex;
use num_traits::Num;

pub type C64 = Complex<f64>;

pub const ONE_C: C64 = Complex::new(1f64, 0f64);
pub const ZERO_C: C64 = Complex::new(0f64, 0f64);
pub const I_C: C64 = Complex::new(0f64, 1f64);

fn c<T: Clone + Num>(re: T, im: T) -> Complex<T> {
    Complex::new(re, im)
}

#[cfg(feature = "web-sys-log")]
pub fn log_message(msg: &String) {
    web_sys::console::log_1(&msg.into());
}

#[cfg(not(feature = "web-sys-log"))]
pub fn log_message(msg: &String) {
    println!("{}", msg);
}

pub fn log_as_err<T>(msg: String) -> Result<T, String> {
    log_message(&msg);
    Err(msg)
}
