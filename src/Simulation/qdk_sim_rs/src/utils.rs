// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use num_complex::Complex;

pub type C64 = Complex<f64>;

pub const ONE_C: C64 = Complex::new(1f64, 0f64);
pub const ZERO_C: C64 = Complex::new(0f64, 0f64);
pub const I_C: C64 = Complex::new(0f64, 1f64);

#[cfg(feature = "web-sys-log")]
pub fn log_message(msg: &str) {
    web_sys::console::log_1(&msg.into());
}

#[cfg(not(feature = "web-sys-log"))]
pub fn log_message(msg: &str) {
    println!("{}", msg);
}

pub fn log_as_err<T>(msg: String) -> Result<T, String> {
    log_message(&msg.as_str());
    Err(msg)
}
