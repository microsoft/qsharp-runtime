// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use std::f64::consts::PI;

use num_traits::{abs, Float, FromPrimitive, Signed};

/// Returns the approximate factorial of a given number.
pub fn approximate_factorial<T: Into<F>, F: Float + Signed + FromPrimitive>(x: T) -> F {
    let x: F = x.into();
    let abs_x = abs(x);

    // TODO: For small numbers that are close to integers, use the more manual implementation.
    if abs_x < F::from_f64(10.0).unwrap()
        && (abs_x - abs_x.round()).abs() <= F::from_f64(1e-9).unwrap()
    {
        let x: i64 = abs_x.round().to_i64().unwrap(); // unwrap is safe here since we already checked the range.
        let mut acc = 1i64;
        for i in 1..x + 1 {
            acc *= i;
        }
        return F::from_i64(acc).unwrap();
    }

    let e = F::exp(F::one());
    let three = F::from_f64(3.0).unwrap();
    let two_pi = F::from_f64(2.0 * PI).unwrap();
    let twelve = F::from_f64(12.0).unwrap();
    let three_sixty = F::from_f64(360.0).unwrap();

    let a = (two_pi * abs_x).sqrt();
    let b = (abs_x / e).powf(abs_x);
    let c = e.powf(F::one() / (twelve * abs_x) - F::one() / (three_sixty * abs_x.powf(three)));

    a * b * c
}

#[cfg(test)]
mod tests {
    use crate::math::approximate_factorial;
    use approx::assert_abs_diff_eq;

    #[test]
    fn approximate_factorial_is_correct_f64() {
        assert_abs_diff_eq!(approximate_factorial::<f64, f64>(0.0), 1.0, epsilon = 1e-4);
        assert_abs_diff_eq!(approximate_factorial::<f64, f64>(3.0), 6.0, epsilon = 1e-4);

        // We expect approximate_factorial(10.0) to return 10! ≈ 3628800.0.
        let expected = 3628800.0;
        assert_abs_diff_eq!(
            approximate_factorial::<f64, f64>(10.0),
            expected,
            epsilon = expected * 1e-8
        );

        // We expect approximate_factorial(123.0) to return 123! ≈ 1.214 × 10²⁰⁵.
        // https://www.wolframalpha.com/input?i=123%21
        let expected = 1.214630436702533e+205;
        assert_abs_diff_eq!(
            approximate_factorial::<f64, f64>(123.0),
            expected,
            epsilon = expected * 1e-8
        );
    }
}
