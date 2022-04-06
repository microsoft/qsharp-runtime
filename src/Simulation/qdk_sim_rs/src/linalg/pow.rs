// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use cauchy::Scalar;
use ndarray::{linalg::Dot, Array, Array2, Ix2};
use num_traits::Zero;

use crate::linalg::Inv;

/// Types for which there is a meaningful matrix identity value.
pub trait Identity: Sized {
    /// Returns a matrix identity of a given size.
    fn eye(size: usize) -> Self;

    /// Returns a matrix identity the same size as a given input.
    fn eye_like(&self) -> Self;
}

impl<A> Identity for Array<A, Ix2>
where
    A: Scalar + Zero + Clone,
{
    fn eye(size: usize) -> Self {
        Self::eye(size)
    }

    fn eye_like(&self) -> Self {
        <Array2<A> as Identity>::eye(std::cmp::min(self.shape()[0], self.shape()[1]))
    }
}

/// Types that support matrix powers $A^{n}$.
pub trait MatrixPower: Sized {
    /// Errors that can result from the [`matrix_power`] method.
    ///
    /// [`matrix_power`]: MatrixPower::matrix_power
    type Error;

    /// Returns an integer power of the given matrix.
    fn matrix_power(&self, pow: i64) -> Result<Self, Self::Error>;
}

impl<M> MatrixPower for M
where
    M: Inv<Output = Self> + Dot<Self, Output = Self> + Identity,
{
    type Error = M::Error;

    fn matrix_power(&self, pow: i64) -> Result<Self, Self::Error> {
        if pow < 0 {
            return self.inv()?.matrix_power(-pow);
        }

        let mut result = self.eye_like();

        // TODO(perf): use binary exponentiation; the simple for loop is just to
        //             quickly get something that can be tested. Once we have
        //             good unit test coverage, we can use that to make sure
        //             binary exponentiation works right.
        for _ in 0..pow {
            result = result.dot(self);
        }

        Ok(result)
    }
}

#[cfg(test)]
mod tests {
    use approx::assert_abs_diff_eq;
    use cauchy::c64;
    use ndarray::{array, Array2};

    use crate::{c64, error::QdkSimError, linalg::MatrixPower};

    #[test]
    fn pauli_x_squares_to_ident() -> Result<(), QdkSimError> {
        let x: Array2<f64> = array![[0.0, 1.0], [1.0, 0.0]];
        let actual = x.matrix_power(2)?;
        let expected = array![[1.0, 0.0], [0.0, 1.0]];
        for (actual, expected) in actual.iter().zip(expected.iter()) {
            assert_abs_diff_eq!(actual, expected, epsilon = 1e-6);
        }
        Ok(())
    }

    #[test]
    fn sqrtx_to_the_fourth_is_ident() -> Result<(), QdkSimError> {
        let sqrtx: Array2<c64> = c64!(0.5)
            * array![
                [c64!(1.0 + 1.0 i), c64!(1.0 - 1.0 i)],
                [c64!(1.0 - 1.0 i), c64!(1.0 + 1.0 i)]
            ];
        let actual = sqrtx.matrix_power(4)?;
        let expected = array![[c64!(1.0), c64!(0.0)], [c64!(0.0), c64!(1.0)]];
        for (actual, expected) in actual.iter().zip(expected.iter()) {
            assert_abs_diff_eq!(actual, expected, epsilon = 1e-6);
        }
        Ok(())
    }

    #[test]
    fn seventh_root_of_x_to_the_seventh_is_x() -> Result<(), QdkSimError> {
        let seventh_root_x: Array2<c64> = array![
            [
                c64::new(0.9504844339512094, 0.21694186955877903),
                c64::new(0.04951556604879037, -0.21694186955877903)
            ],
            [
                c64::new(0.04951556604879037, -0.21694186955877903),
                c64::new(0.9504844339512094, 0.21694186955877903)
            ],
        ];
        let actual = seventh_root_x.matrix_power(7)?;
        let expected = array![[c64!(0.0), c64!(1.0)], [c64!(1.0), c64!(0.0)]];
        for (actual, expected) in actual.iter().zip(expected.iter()) {
            assert_abs_diff_eq!(actual, expected, epsilon = 1e-6);
        }
        Ok(())
    }

    #[test]
    fn rand_4x4_c64_pow() -> Result<(), QdkSimError> {
        let arr: Array2<c64> = array![
            [
                c64::new(0.4197614535218097, 0.6393638574841801),
                c64::new(0.021249529076351803, 0.4916053336160465),
                c64::new(0.7598776596987344, 0.06591304637672646),
                c64::new(0.5633311068416154, 0.031336286212855446)
            ],
            [
                c64::new(0.0269250407737347, 0.20379518145743047),
                c64::new(0.30555508065274883, 0.15808290828587157),
                c64::new(0.5104720129393309, 0.6948521818460662),
                c64::new(0.19865943993696022, 0.9287971169482773)
            ],
            [
                c64::new(0.2905701510819163, 0.09833520319062727),
                c64::new(0.23402610846324, 0.8393135547393529),
                c64::new(0.5401748112924776, 0.9821393064000913),
                c64::new(0.0927979325237448, 0.2477695883264862)
            ],
            [
                c64::new(0.7717353949875485, 0.42140532067756675),
                c64::new(0.5528553121605853, 0.9640588921494402),
                c64::new(0.7349192227517806, 0.5792000992940656),
                c64::new(0.12338346370340081, 0.07289997402380066)
            ],
        ];
        let actual = arr.matrix_power(13)?;
        let expected = array![
            [
                c64::new(7238.141066326559, -9911.274649764955),
                c64::new(17648.478137710346, -9418.948356812798),
                c64::new(18297.504198477975, -18154.35549609193),
                c64::new(10159.63982578618, -5485.709652173136)
            ],
            [
                c64::new(12959.04402150731, -4661.525869682588),
                c64::new(22325.641696782357, 2341.2319188120773),
                c64::new(28420.99091079291, -5370.043643156111),
                c64::new(12892.072719114653, 1288.7133317204193)
            ],
            [
                c64::new(12882.930101604788, -2963.4083140513117),
                c64::new(21010.506984145948, 4779.901376069587),
                c64::new(27700.037816647793, -1873.6300238965507),
                c64::new(12139.8605952774, 2699.9073450820306)
            ],
            [
                c64::new(12071.951917001059, -9465.554479542623),
                c64::new(24427.99605457002, -5339.098219764661),
                c64::new(28174.33364730465, -15627.076130106801),
                c64::new(14083.953080905429, -3149.97121499003)
            ],
        ];
        for (actual, expected) in actual.iter().zip(expected.iter()) {
            assert_abs_diff_eq!(actual, expected, epsilon = 1e-6);
        }
        Ok(())
    }
}
