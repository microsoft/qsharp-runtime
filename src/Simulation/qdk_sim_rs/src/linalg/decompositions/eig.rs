// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use std::ops::Mul;

use cauchy::Scalar;
use ndarray::{linalg::Dot, Array1, Array2, NewAxis};

use crate::{error::QdkSimError, linalg::HasDagger};
use num_traits::FromPrimitive;

/// Represents the decomposition of a matrix into eigenvalues and eigenvectors.
pub trait EigenvalueDecomposition<A>
where
    A: Scalar,
{
    /// The type used to represent errors in using this decomposition to solve
    /// matrix equations.
    type Error: std::error::Error;

    /// The type of the matrix reconstructed from this decomposition.
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
    A: Scalar + ndarray::ScalarOperand,
    Array2<A>: Dot<Array2<A>, Output = Array2<A>> + HasDagger<Output = Array2<A>>,
{
    type Error = QdkSimError;

    type MatrixSolution = Array2<A>;

    fn apply_mtx_fn<F: FnMut(&A) -> A>(
        &self,
        mut func: F,
    ) -> Result<Self::MatrixSolution, Self::Error> {
        let n_eigvals = self.values.shape()[0];
        let dim = self.vectors.shape()[1];
        assert_eq!(n_eigvals, self.vectors.shape()[0]);

        // If we have a singular matrix (that is, a matrix with a nontrivial null
        // space), and if 𝑓(0) ≠ 0, then we'll need to add in how the matrix
        // function works on that null space as well.
        let null_mtx = if n_eigvals < dim {
            let f_zero = func(&A::zero());
            if (f_zero - A::zero()).abs() >= A::Real::from_f64(0.0f64).unwrap() {
                let mut null_proj = Array2::eye(dim);
                for eigvec in self.vectors.rows() {
                    let eigvec = eigvec.slice(s![.., NewAxis]);
                    null_proj = null_proj - eigvec.dot(&eigvec.t().map(|e| e.conj()));
                }
                Some(null_proj * f_zero)
            } else {
                None
            }
        } else {
            None
        };

        let new_eigvals = self.values.map(func);
        let shape = (dim, dim);
        let mut res: Self::MatrixSolution = Array2::zeros(shape);
        // TODO[perf]: Write this out as dot products.
        for i in 0..dim {
            for j in 0..dim {
                let mut element = A::zero();
                for idx_eig in 0..n_eigvals {
                    element += self.vectors[(idx_eig, i)]
                        * new_eigvals[(idx_eig)]
                        * self.vectors[(idx_eig, j)].conj();
                }
                res[(i, j)] = element;
            }
        }
        Ok(match null_mtx {
            Some(null_mtx) => res + null_mtx,
            None => res,
        })
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
    use core::f64::consts::FRAC_1_SQRT_2;

    #[test]
    pub fn ident_applies_to_eig_x() -> Result<(), Box<dyn std::error::Error>> {
        let eigs: ExplicitEigenvalueDecomposition<c64> = ExplicitEigenvalueDecomposition {
            values: array![c64!(-1.0), c64!(1.0)],
            vectors: c64::new(FRAC_1_SQRT_2, 0.0)
                * array![[c64!(1.0), c64!(-1.0)], [c64!(1.0), c64!(1.0)],],
        };
        let actual = eigs.apply_mtx_fn(|x| *x)?;
        let expected = array![[c64!(0.0), c64!(1.0)], [c64!(1.0), c64!(0.0),],];
        for (actual, expected) in actual.iter().zip(expected.iter()) {
            assert_abs_diff_eq!(actual, expected, epsilon = 1e-6);
        }
        Ok(())
    }

    #[test]
    pub fn mtx_fn_applies_to_eig_x() -> Result<(), Box<dyn std::error::Error>> {
        let eigs: ExplicitEigenvalueDecomposition<c64> = ExplicitEigenvalueDecomposition {
            values: array![c64!(-1.0), c64!(1.0)],
            vectors: c64::new(FRAC_1_SQRT_2, 0.0)
                * array![[c64!(1.0), c64!(-1.0)], [c64!(1.0), c64!(1.0)],],
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
