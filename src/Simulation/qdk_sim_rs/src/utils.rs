// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use num_complex::Complex;

/// A complex number with two 64-bit floating point fields.
/// That is, the analogy of [`f64`] to complex values.
pub type C64 = Complex<f64>;

/// The real unit 1, represented as a complex number with two 64-bit floating
/// point fields.
pub const ONE_C: C64 = Complex::new(1f64, 0f64);

/// The number zero, represented as a complex number with two 64-bit floating
/// point fields.
pub const ZERO_C: C64 = Complex::new(0f64, 0f64);

/// The imaginary unit $i$, represented as a complex number with two 64-bit
/// floating point fields.
pub const I_C: C64 = Complex::new(0f64, 1f64);

#[cfg(feature = "web-sys-log")]
fn log_message(msg: &str) {
    web_sys::console::log_1(&msg.into());
}

#[cfg(not(feature = "web-sys-log"))]
fn log_message(msg: &str) {
    println!("{}", msg);
}

/// Prints a message as an error, and returns it as a [`Result`].
pub fn log_as_err<T>(msg: String) -> Result<T, String> {
    log(&msg);
    Err(msg)
}

/// Prints a message as an error.
pub fn log(msg: &String) -> () {
    log_message(msg.as_str());
}
