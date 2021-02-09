use core::f64::consts::FRAC_1_SQRT_2;
use crate::utils::*;
use ndarray::Array2;

pub fn I() -> Array2<C64> {
    array![
        [ONE_C, ZERO_C],
        [ZERO_C, ONE_C]
    ]
}

pub fn X() -> Array2<C64> {
    array![
        [ZERO_C, ONE_C],
        [ONE_C, ZERO_C]
    ]
}

pub fn Y() -> Array2<C64> {
    array![
        [ZERO_C, I_C],
        [-I_C, ZERO_C]
    ]
}

pub fn Z() -> Array2<C64> {
    array![
        [ONE_C, ZERO_C],
        [ZERO_C, -ONE_C]
    ]
}

pub fn H() -> Array2<C64> {
    array![
        [ONE_C, ONE_C],
        [ONE_C, -ONE_C]
    ] * FRAC_1_SQRT_2
}

pub fn T() -> Array2<C64> {
    array![
        [ONE_C, ZERO_C],
        [ZERO_C, C64::new(FRAC_1_SQRT_2, FRAC_1_SQRT_2)]
    ]
}

pub fn S() -> Array2<C64> {
    array![
        [ONE_C, ZERO_C],
        [ZERO_C, C64::new(0.0_f64, 1.0_f64)]
    ]
}

pub fn CNOT() -> Array2<C64> {
    array![
        [ONE_C, ZERO_C, ZERO_C, ZERO_C],
        [ZERO_C, ONE_C, ZERO_C, ZERO_C],
        [ZERO_C, ZERO_C, ZERO_C, ONE_C],
        [ZERO_C, ZERO_C, ONE_C, ZERO_C]
    ]
}
