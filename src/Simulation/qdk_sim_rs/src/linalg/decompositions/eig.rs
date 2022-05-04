// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use std::ops::Mul;

use cauchy::Scalar;
use ndarray::{linalg::Dot, Array1, Array2, Data};

use crate::{error::QdkSimError, linalg::HasDagger, C64};

pub trait EigenvalueDecomposition<A>
where
    A: Scalar,
{
    /// The type used to represent errors in using this decomposition to solve
    /// matrix equations.
    type Error: std::error::Error;

    type MatrixSolution;

    /// Given a function from eigenvalues to eigenvalues, uses this
    /// decomposition to return a matrix transformed replacing the Taylor series
    /// for that function with a matrix-valued Taylor series.
    fn apply_mtx_fn<F: FnMut(&A) -> A>(&self, func: F)
        -> Result<Self::MatrixSolution, Self::Error>;
}

/// Used to represent an explicit eigenvalue decomposition, such as may be
/// precomputed by another library or application.
pub struct ExplicitEigenvalueDecomposition<A>
where
    A: Scalar,
{
    pub(crate) values: Array1<A>,
    pub(crate) vectors: Array2<A>,
}

impl<A> EigenvalueDecomposition<A> for ExplicitEigenvalueDecomposition<A>
where
    A: Scalar,
    Array2<A>: Dot<Array2<A>, Output = Array2<A>> + HasDagger<Output = Array2<A>>,
{
    type Error = QdkSimError;

    type MatrixSolution = Array2<A>;

    fn apply_mtx_fn<F: FnMut(&A) -> A>(
        &self,
        func: F,
    ) -> Result<Self::MatrixSolution, Self::Error> {
        let new_eigvals = self.values.map(func);
        let foo: Array2<A> = new_eigvals * &self.vectors;
        let bar = self.vectors.dag();
        Ok(foo.dot(&bar))
    }
}

impl<A> Mul<ExplicitEigenvalueDecomposition<A>> for cauchy::c64
where
    A: Scalar,
    cauchy::c64: Mul<Array1<A>, Output = Array1<A>>,
{
    type Output = ExplicitEigenvalueDecomposition<A>;

    fn mul(self, rhs: ExplicitEigenvalueDecomposition<A>) -> Self::Output {
        ExplicitEigenvalueDecomposition {
            vectors: rhs.vectors,
            values: self * rhs.values,
        }
    }
}

#[cfg(test)]
mod tests {
    use crate::c64;
    use approx::assert_abs_diff_eq;
    use cauchy::c64;

    use super::{EigenvalueDecomposition, ExplicitEigenvalueDecomposition};

    #[test]
    pub fn mtx_fn_applies_to_eig_x() -> Result<(), Box<dyn std::error::Error>> {
        let eigs: ExplicitEigenvalueDecomposition<c64> = ExplicitEigenvalueDecomposition {
            values: array![c64!(1.0), c64!(-1.0)],
            vectors: c64!(0.70710678) * array![[c64!(1.0), c64!(-1.0)], [c64!(1.0), c64!(1.0)],],
        };
        let actual = eigs.apply_mtx_fn(|x| (c64!(-1.0 i) * x).exp())?;
        let expected = array![
            [
                c64::new(0.5403023058681397, 0.0),
                c64::new(0.0, -0.8414709848078964)
            ],
            [
                c64::new(0.0, -0.8414709848078965),
                c64::new(0.5403023058681397, 0.0)
            ],
        ];
        for (actual, expected) in actual.iter().zip(expected.iter()) {
            assert_abs_diff_eq!(actual, expected, epsilon = 1e-6);
        }
        Ok(())
    }
}
