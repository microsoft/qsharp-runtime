// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use core::f64::consts::FRAC_1_SQRT_2;
use crate::utils::*;
use ndarray::{ Array, Array1, Array2 };
use num_traits::{ Zero, One };

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


pub fn elementary_vec<T: Zero + One>(idx: usize, n: usize) -> Array1<T> {
    Array::from_shape_fn(n, |i| if i == idx {T::one()} else {T::zero()})
}

pub fn elementary_matrix<T: Zero + One>((idx0, idx1): (usize, usize), (n, m): (usize, usize)) -> Array2<T> {
    Array::from_shape_fn((n, m), |(i, j)| if i == idx0 && j == idx1 {
        T::one()
    } else {
        T::zero()
    })
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
