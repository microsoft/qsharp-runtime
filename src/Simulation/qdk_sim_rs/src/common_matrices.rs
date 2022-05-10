// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

//! Definitions for commonly used vectors and matrices, such as the Pauli
//! matrices, common Clifford operators, and elementary matrices.

use core::f64::consts::FRAC_1_SQRT_2;
use std::convert::TryInto;

use ndarray::{Array, Array1, Array2};
use num_traits::{One, Zero};

use crate::utils::*;

/// Returns a copy of the single-qubit identity matrix.
pub fn i() -> Array2<C64> {
    array![[ONE_C, ZERO_C], [ZERO_C, ONE_C]]
}

/// Returns a unitary matrix representing the `X` operation.
pub fn x() -> Array2<C64> {
    array![[ZERO_C, ONE_C], [ONE_C, ZERO_C]]
}

/// Returns a unitary matrix representing the `Y` operation.
pub fn y() -> Array2<C64> {
    array![[ZERO_C, -I_C], [I_C, ZERO_C]]
}

/// Returns a unitary matrix representing the `Z` operation.
pub fn z() -> Array2<C64> {
    array![[ONE_C, ZERO_C], [ZERO_C, -ONE_C]]
}

/// Returns a unitary matrix representing the single-qubit Hadamard transformation.
pub fn h() -> Array2<C64> {
    array![[ONE_C, ONE_C], [ONE_C, -ONE_C]] * FRAC_1_SQRT_2
}

/// Returns a unitary matrix representing the `T` operation.
pub fn t() -> Array2<C64> {
    array![
        [ONE_C, ZERO_C],
        [ZERO_C, C64::new(FRAC_1_SQRT_2, FRAC_1_SQRT_2)]
    ]
}

/// Returns a unitary matrix representing the `S` operation.
pub fn s() -> Array2<C64> {
    array![[ONE_C, ZERO_C], [ZERO_C, C64::new(0.0_f64, 1.0_f64)]]
}

/// Returns a unitary matrix representing the `CNOT` operation.
pub fn cnot() -> Array2<C64> {
    array![
        [ONE_C, ZERO_C, ZERO_C, ZERO_C],
        [ZERO_C, ONE_C, ZERO_C, ZERO_C],
        [ZERO_C, ZERO_C, ZERO_C, ONE_C],
        [ZERO_C, ZERO_C, ONE_C, ZERO_C]
    ]
}

/// Returns an elementary vector; that is, a vector with a one at a given
/// index and zeros everywhere else.
///
/// # Examples
/// The following are equivalent:
/// ```
/// # #[macro_use] extern crate ndarray;
/// # use qdk_sim::common_matrices::elementary_vec;
/// let vec = elementary_vec::<i64>(2, 4);
/// ```
/// and:
/// ```
/// # #[macro_use] extern crate ndarray;
/// let vec = array![0i64, 0i64, 1i64, 0i64];
/// ```
pub fn elementary_vec<T: Zero + One>(idx: usize, n: usize) -> Array1<T> {
    Array::from_shape_fn(n, |i| if i == idx { T::one() } else { T::zero() })
}

/// Returns an elementary matrix; that is, a matrix with a one at a given index
/// and zeros everywhere else.
pub fn elementary_matrix<T: Zero + One>(
    (idx0, idx1): (usize, usize),
    (n, m): (usize, usize),
) -> Array2<T> {
    Array::from_shape_fn((n, m), |(i, j)| {
        if i == idx0 && j == idx1 {
            T::one()
        } else {
            T::zero()
        }
    })
}

/// Returns an identity matrix that acts on state vectors of registers of
/// qubits with a given size.
///
/// # Example
/// The following snippet defines a two-qubit identity matrix:
/// ```
/// # #[macro_use] extern crate ndarray;
/// # use qdk_sim::common_matrices::nq_eye;
/// use num_complex::Complex;
/// let eye = nq_eye(2usize);
/// assert_eq!(eye, array![
///     [Complex::new(1f64, 0f64), Complex::new(0f64, 0f64), Complex::new(0f64, 0f64), Complex::new(0f64, 0f64)],
///     [Complex::new(0f64, 0f64), Complex::new(1f64, 0f64), Complex::new(0f64, 0f64), Complex::new(0f64, 0f64)],
///     [Complex::new(0f64, 0f64), Complex::new(0f64, 0f64), Complex::new(1f64, 0f64), Complex::new(0f64, 0f64)],
///     [Complex::new(0f64, 0f64), Complex::new(0f64, 0f64), Complex::new(0f64, 0f64), Complex::new(1f64, 0f64)],
/// ]);
/// ```
pub fn nq_eye(nq: usize) -> Array2<C64> {
    Array2::eye(2usize.pow(nq.try_into().unwrap()))
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::linalg::HasDagger;

    fn is_self_adjoint(arr: Array2<C64>) -> bool {
        arr == arr.dag()
    }

    fn are_equal_to_precision(actual: Array2<C64>, expected: Array2<C64>) -> bool {
        // If we use assert_eq here, we'll get bitten by finite precision.
        // We also can't use LAPACK, since that greatly complicates bindings,
        // so we do an ad hoc implementation here.
        (actual - expected).map(|x| x.norm()).sum() <= 1e-10
    }

    #[test]
    fn h_is_self_adjoint() {
        assert!(is_self_adjoint(h()));
    }

    #[test]
    fn x_is_self_adjoint() {
        assert!(is_self_adjoint(x()));
    }

    #[test]
    fn y_is_self_adjoint() {
        assert!(is_self_adjoint(y()));
    }

    #[test]
    fn z_is_self_adjoint() {
        assert!(is_self_adjoint(z()));
    }

    #[test]
    fn cnot_is_self_adjoint() {
        assert!(is_self_adjoint(cnot()));
    }

    #[test]
    fn s_squares_to_z() {
        assert_eq!(s().dot(&s()), z());
    }

    #[test]
    fn t_squares_to_s() {
        assert!(are_equal_to_precision(t().dot(&t()), s()));
    }

    #[test]
    fn elementary_vec_is_correct() {
        assert_eq!(elementary_vec::<i64>(2, 4), array![0i64, 0i64, 1i64, 0i64])
    }

    #[test]
    fn elementary_matrix_is_correct() {
        assert_eq!(
            elementary_matrix::<i64>((1, 3), (4, 5)),
            array![
                [0i64, 0i64, 0i64, 0i64, 0i64],
                [0i64, 0i64, 0i64, 1i64, 0i64],
                [0i64, 0i64, 0i64, 0i64, 0i64],
                [0i64, 0i64, 0i64, 0i64, 0i64]
            ]
        )
    }
}
