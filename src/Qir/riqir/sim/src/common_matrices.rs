// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use core::f64::consts::FRAC_1_SQRT_2;
use ndarray::{array, s, Array2};
use num_complex::Complex64;
use num_traits::{One, Zero};

/// Returns a unitary matrix representing the `X` operation.
#[cfg(test)]
#[must_use]
pub fn x() -> Array2<Complex64> {
    array![
        [Complex64::zero(), Complex64::one()],
        [Complex64::one(), Complex64::zero()]
    ]
}

/// Returns a unitary matrix representing the `Y` operation.
#[cfg(test)]
#[must_use]
pub fn y() -> Array2<Complex64> {
    array![
        [Complex64::zero(), -Complex64::i()],
        [Complex64::i(), Complex64::zero()]
    ]
}

/// Returns a unitary matrix representing the `Z` operation.
#[cfg(test)]
#[must_use]
pub fn z() -> Array2<Complex64> {
    array![
        [Complex64::one(), Complex64::zero()],
        [Complex64::zero(), -Complex64::one()]
    ]
}

/// Returns a unitary matrix representing the single-qubit Hadamard transformation.
#[must_use]
pub fn h() -> Array2<Complex64> {
    array![
        [Complex64::one(), Complex64::one()],
        [Complex64::one(), -Complex64::one()]
    ] * FRAC_1_SQRT_2
}

/// Returns a unitary matrix representing the `T` operation.
#[must_use]
pub fn t() -> Array2<Complex64> {
    array![
        [Complex64::one(), Complex64::zero()],
        [
            Complex64::zero(),
            Complex64::new(FRAC_1_SQRT_2, FRAC_1_SQRT_2)
        ]
    ]
}

/// Returns a unitary matrix representing the `S` operation.
#[must_use]
pub fn s() -> Array2<Complex64> {
    array![
        [Complex64::one(), Complex64::zero()],
        [Complex64::zero(), Complex64::new(0.0_f64, 1.0_f64)]
    ]
}

/// Returns a unitary matrix representing the `Rx` operation with the given angle.
#[must_use]
pub fn rx(theta: f64) -> Array2<Complex64> {
    let cos_theta = f64::cos(theta / 2.0);
    let sin_theta = f64::sin(theta / 2.0);
    array![
        [
            Complex64::new(cos_theta, 0.0),
            Complex64::new(0.0, -sin_theta)
        ],
        [
            Complex64::new(0.0, -sin_theta),
            Complex64::new(cos_theta, 0.0)
        ]
    ]
}

/// Returns a unitary matrix representing the `Ry` operation with the given angle.
#[must_use]
pub fn ry(theta: f64) -> Array2<Complex64> {
    let cos_theta = f64::cos(theta / 2.0);
    let sin_theta = f64::sin(theta / 2.0);
    array![
        [
            Complex64::new(cos_theta, 0.0),
            Complex64::new(-sin_theta, 0.0)
        ],
        [
            Complex64::new(sin_theta, 0.0),
            Complex64::new(cos_theta, 0.0)
        ]
    ]
}

/// Returns a unitary matrix representing the `Rz` operation with the given angle.
#[must_use]
pub fn rz(theta: f64) -> Array2<Complex64> {
    let exp_theta = Complex64::exp(Complex64::new(0.0, theta / 2.0));
    let neg_exp_theta = Complex64::exp(Complex64::new(0.0, -theta / 2.0));
    array![
        [neg_exp_theta, Complex64::zero()],
        [Complex64::zero(), exp_theta]
    ]
}

/// Returns a unitary matrix representing the `G` or `GlobalPhase` operation with the given angle.
#[must_use]
pub fn g(theta: f64) -> Array2<Complex64> {
    let neg_exp_theta = Complex64::exp(Complex64::new(0.0, -theta / 2.0));
    array![
        [neg_exp_theta, Complex64::zero()],
        [Complex64::zero(), neg_exp_theta]
    ]
}

/// Returns a unitary matrix representing the `SWAP` operation.
#[must_use]
pub fn swap() -> Array2<Complex64> {
    array![
        [
            Complex64::one(),
            Complex64::zero(),
            Complex64::zero(),
            Complex64::zero()
        ],
        [
            Complex64::zero(),
            Complex64::zero(),
            Complex64::one(),
            Complex64::zero()
        ],
        [
            Complex64::zero(),
            Complex64::one(),
            Complex64::zero(),
            Complex64::zero()
        ],
        [
            Complex64::zero(),
            Complex64::zero(),
            Complex64::zero(),
            Complex64::one()
        ]
    ]
}

/// Transforms the given matrix into it's adjoint using the transpose of the complex conjugate.
#[must_use]
pub fn adjoint(u: &Array2<Complex64>) -> Array2<Complex64> {
    u.t().map(Complex64::conj)
}

/// Extends the given unitary matrix into a matrix corresponding to the same unitary with a given number of controls
/// by inserting it into an identity matrix.
#[must_use]
pub fn controlled(u: &Array2<Complex64>, num_ctrls: u32) -> Array2<Complex64> {
    let mut controlled_u = Array2::eye(u.nrows() * 2_usize.pow(num_ctrls));
    controlled_u
        .slice_mut(s![
            (controlled_u.nrows() - u.nrows())..,
            (controlled_u.ncols() - u.ncols())..
        ])
        .assign(u);
    controlled_u
}

#[cfg(test)]
mod tests {
    use super::*;
    use core::f64::consts::PI;

    fn is_self_adjoint(arr: &Array2<Complex64>) -> bool {
        arr == adjoint(arr)
    }

    fn are_equal_to_precision(actual: Array2<Complex64>, expected: Array2<Complex64>) -> bool {
        // If we use assert_eq here, we'll get bitten by finite precision.
        // We also can't use LAPACK, since that greatly complicates bindings,
        // so we do an ad hoc implementation here.
        (actual - expected).map(|x| x.norm()).sum() <= 1e-10
    }

    #[test]
    fn h_is_self_adjoint() {
        assert!(is_self_adjoint(&h()));
    }

    #[test]
    fn x_is_self_adjoint() {
        assert!(is_self_adjoint(&x()));
    }

    #[test]
    fn y_is_self_adjoint() {
        assert!(is_self_adjoint(&y()));
    }

    #[test]
    fn z_is_self_adjoint() {
        assert!(is_self_adjoint(&z()));
    }

    #[test]
    fn swap_is_self_adjoint() {
        assert!(is_self_adjoint(&swap()));
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
    fn rx_pi_is_x() {
        assert!(are_equal_to_precision(Complex64::i() * rx(PI), x()));
    }

    #[test]
    fn ry_pi_is_y() {
        assert!(are_equal_to_precision(Complex64::i() * ry(PI), y()));
    }

    #[test]
    fn rz_pi_is_z() {
        assert!(are_equal_to_precision(Complex64::i() * rz(PI), z()));
    }

    #[test]
    fn gate_multiplication() {
        assert!(are_equal_to_precision(x().dot(&y()), Complex64::i() * z()));
    }

    #[test]
    fn controlled_extension() {
        fn cnot() -> Array2<Complex64> {
            array![
                [
                    Complex64::one(),
                    Complex64::zero(),
                    Complex64::zero(),
                    Complex64::zero()
                ],
                [
                    Complex64::zero(),
                    Complex64::one(),
                    Complex64::zero(),
                    Complex64::zero()
                ],
                [
                    Complex64::zero(),
                    Complex64::zero(),
                    Complex64::zero(),
                    Complex64::one()
                ],
                [
                    Complex64::zero(),
                    Complex64::zero(),
                    Complex64::one(),
                    Complex64::zero()
                ]
            ]
        }
        assert!(are_equal_to_precision(controlled(&x(), 1), cnot()));
        assert!(are_equal_to_precision(
            controlled(&x(), 2),
            controlled(&cnot(), 1)
        ));
        assert_eq!(controlled(&x(), 3).nrows(), 2_usize.pow(4));
    }
}
