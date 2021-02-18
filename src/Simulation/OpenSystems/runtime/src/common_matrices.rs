// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use core::f64::consts::FRAC_1_SQRT_2;
use crate::utils::*;
use ndarray::Array2;
use crate::linalg::HasDagger;

pub fn i() -> Array2<C64> {
    array![
        [ONE_C, ZERO_C],
        [ZERO_C, ONE_C]
    ]
}

pub fn x() -> Array2<C64> {
    array![
        [ZERO_C, ONE_C],
        [ONE_C, ZERO_C]
    ]
}

pub fn y() -> Array2<C64> {
    array![
        [ZERO_C, I_C],
        [-I_C, ZERO_C]
    ]
}

pub fn z() -> Array2<C64> {
    array![
        [ONE_C, ZERO_C],
        [ZERO_C, -ONE_C]
    ]
}

pub fn h() -> Array2<C64> {
    array![
        [ONE_C, ONE_C],
        [ONE_C, -ONE_C]
    ] * FRAC_1_SQRT_2
}

pub fn t() -> Array2<C64> {
    array![
        [ONE_C, ZERO_C],
        [ZERO_C, C64::new(FRAC_1_SQRT_2, FRAC_1_SQRT_2)]
    ]
}

pub fn s() -> Array2<C64> {
    array![
        [ONE_C, ZERO_C],
        [ZERO_C, C64::new(0.0_f64, 1.0_f64)]
    ]
}

pub fn cnot() -> Array2<C64> {
    array![
        [ONE_C, ZERO_C, ZERO_C, ZERO_C],
        [ZERO_C, ONE_C, ZERO_C, ZERO_C],
        [ZERO_C, ZERO_C, ZERO_C, ONE_C],
        [ZERO_C, ZERO_C, ONE_C, ZERO_C]
    ]
}

#[cfg(test)]
mod tests {
    use super::*;

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
    fn s_squares_to_z() {
        assert_eq!(s().dot(&s()), z());
    }

    #[test]
    fn t_squares_to_s() {
        assert!(are_equal_to_precision(t().dot(&t()), s()));
    }
}
