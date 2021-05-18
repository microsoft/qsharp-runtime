// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use ndarray::{s, Array1, Array2, ArrayView1};
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
pub fn log(msg: &str) {
    log_message(msg);
}

/// Given two columns in a two-dimensional array, swaps them in-place.
pub fn swap_columns<T: Clone>(data: &mut Array2<T>, idxs: (usize, usize)) {
    // FIXME[perf]: can be accelerated for bool by using three XORs.
    // FIXME[perf]: should be possible with one tmp instead of two
    let tmp_a = data.slice(s![.., idxs.0]).to_owned();
    let tmp_b = data.slice(s![.., idxs.1]).to_owned();
    data.slice_mut(s![.., idxs.0]).assign(&tmp_b);
    data.slice_mut(s![.., idxs.1]).assign(&tmp_a);
}

/// Given a one-dimensional array, updates it to be the row-sum of that vector
/// and the given row of a matrix, taking into account the phase product
/// introduced by the binary symplectic product.
pub fn set_vec_to_row_sum(data: &mut Array1<bool>, matrix: &Array2<bool>, idx_source: usize) {
    // FIXME[perf]: change to ndarray broadcast op.
    // NB: we use - 1 in the range here, so that we don't also iterate over phases.
    for idx_col in 0..matrix.shape()[1] - 1 {
        data[idx_col] ^= matrix[(idx_source, idx_col)];
    }

    let idx_phase = data.shape()[0] - 1;
    data[idx_phase] = phase_product(&data.slice(s![..]), &matrix.slice(s![idx_source, ..]));
}

/// Given a two-dimensional array, updates a row of that matrix to be the
/// row-sum of that row and the given row of another matrix, taking into
/// account the phase product introduced by the binary symplectic product.
pub fn set_row_to_row_sum(data: &mut Array2<bool>, idx_source: usize, idx_target: usize) {
    // FIXME[perf]: change to ndarray broadcast op.
    // NB: we use - 1 in the range here, so that we don't also iterate over phases.
    for idx_col in 0..data.shape()[1] - 1 {
        data[(idx_target, idx_col)] ^= data[(idx_source, idx_col)];
    }

    let idx_phase = data.shape()[1] - 1;
    data[(idx_target, idx_phase)] = phase_product(
        &data.slice(s![idx_target, ..]),
        &data.slice(s![idx_source, ..]),
    );
}

fn g(x1: bool, z1: bool, x2: bool, z2: bool) -> i32 {
    match (x1, z1) {
        (false, false) => 0,
        (true, true) => (if z2 { 1 } else { 0 }) - (if x2 { 1 } else { 0 }),
        (true, false) => (if z2 { 1 } else { 0 }) * (if x2 { 1 } else { -1 }),
        (false, true) => (if x2 { 1 } else { 0 }) * (if z2 { 1 } else { -1 }),
    }
}

/// Given a row of a binary symplectic matrix augmented with phase information,
/// returns its $X$, $Z$, and phase parts.
pub fn split_row(row: &ArrayView1<bool>) -> (Array1<bool>, Array1<bool>, bool) {
    let n_qubits = (row.shape()[0] - 1) / 2;
    // FIXME[perf]: relax to_owned call here.
    (
        row.slice(s![0..n_qubits]).to_owned(),
        row.slice(s![n_qubits..]).to_owned(),
        row[2 * n_qubits],
    )
}

/// Returns the phase introduced by the binary symplectic product of two rows.
pub fn phase_product(row1: &ArrayView1<bool>, row2: &ArrayView1<bool>) -> bool {
    let mut acc = 0i32;
    let (xs1, zs1, r1) = split_row(row1);
    let (xs2, zs2, r2) = split_row(row2);

    for idx_col in 0..xs1.shape()[0] {
        acc += g(xs1[idx_col], zs1[idx_col], xs2[idx_col], zs2[idx_col]);
    }

    ((if r1 { 2 } else { 0 }) + (if r2 { 2 } else { 0 }) + acc) % 4 == 2
}
