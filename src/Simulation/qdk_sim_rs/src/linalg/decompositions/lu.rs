// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use std::any::type_name;

use cauchy::Scalar;
use ndarray::{Array1, ArrayBase, Axis, Data, Ix1, Ix2, OwnedRepr, RawData};
use num_traits::FromPrimitive;

use crate::{
    error::QdkSimError,
    linalg::array_ext::{RemoveAxisExt, ShapeExt},
};

/// Represents the output of an LU decomposition acting on a matrix.
#[derive(Debug)]
pub struct LU<A, S>
where
    S: Data<Elem = A>,
    A: Scalar,
{
    pub(self) factors: ArrayBase<S, Ix2>,
    pub(self) pivots: Array1<usize>,
}

/// Represents types that represent matrices that are decomposable into lower-
/// and upper-triangular parts.
pub trait LUDecomposable {
    /// The element type for the output matrices.
    type Elem: Scalar;

    /// Type of owned data in the output matrices.
    type OwnedRepr: Data + RawData<Elem = Self::Elem>;

    /// The output type for LU decompositions on this type.
    type Output: LUDecomposition<Self::Elem, Self::OwnedRepr>;

    /// The type used to represent errors in the decomposition.
    type Error: std::error::Error;

    /// Performs an LU decomposition on the given type.
    fn lu(&self) -> Result<Self::Output, Self::Error>;
}

impl<A, S> LUDecomposable for ArrayBase<S, Ix2>
where
    S: Data<Elem = A>,
    A: Scalar,
{
    type Elem = A;
    type OwnedRepr = OwnedRepr<A>;
    type Error = QdkSimError;
    type Output = LU<A, OwnedRepr<A>>;

    // We follow the approach of
    // https://github.com/mathnet/mathnet-numerics/blob/18c99a57562f181aab979b42ba206d3152f86cf2/src/Numerics/LinearAlgebra/Complex/Factorization/UserLU.cs.
    fn lu(&self) -> Result<Self::Output, Self::Error> {
        let n_rows = self.require_square()?;
        let threshold = A::Real::from_f64(1e-10).ok_or_else(|| {
            QdkSimError::CannotConvertElement("f64".to_string(), type_name::<A::Real>().to_string())
        })?;

        let factors = &mut (*self).to_owned();
        let mut pivots: Array1<_> = (0..n_rows).collect::<Vec<_>>().into();

        for j in 0..n_rows {
            let mut pivot_col = factors.index_axis(Axis(1), j).to_owned();

            // We do this in a for loop since the slicing to get the lower-triangular
            // part comes out harder to read.
            for i in 0..n_rows {
                let mut s = A::zero();
                for k in 0..std::cmp::min(i, j) {
                    s += factors[(i, k)] * pivot_col[k];
                }
                pivot_col[i] -= s;
                factors[(i, j)] = pivot_col[i];
            }

            // Find the pivot and exchange if needed.
            let mut idx_pivot = j;
            for i in j + 1..n_rows {
                if pivot_col[i].abs() > pivot_col[idx_pivot].abs() {
                    idx_pivot = i;
                }
            }

            if idx_pivot != j {
                factors.swap_index_axis(Axis(0), idx_pivot, j);

                // Record the exchange in the pivot permutation.
                pivots[j] = idx_pivot;
            }

            // Compute multipliers.
            if j < n_rows && factors[(j, j)].abs() >= threshold {
                for i in j + 1..n_rows {
                    let elem = factors[(j, j)];
                    factors[(i, j)] /= elem;
                }
            }
        }

        Ok(LU {
            factors: factors.clone(),
            pivots,
        })
    }
}

/// Represents the result of decomposing a square matrix $A$ into lower- and
/// upper-triangular components $L$ and $U$, respectively.
pub trait LUDecomposition<A, S>
where
    S: Data<Elem = A>,
    A: Scalar,
{
    /// The type used to represent errors in using this decomposition to solve
    /// matrix equations.
    type Error: std::error::Error;

    /// The type resulting from using this decomposition to solve problems
    /// of the form $A\vec{x} = \vec{y}$.
    type VectorSolution;

    /// The type resulting from using this decomposition to solve problems
    /// of the form $AX = Y$.
    type MatrixSolution;

    /// The size $n$ of the matrix whose decomposition is represented. In
    /// particular, $L\Pi U$ is taken to be an $n \times n$ matrix, where $L$
    /// and $U$ are the lower- and upper-triangular factors, and where $\Pi$
    /// is a permutation matrix.
    fn order(&self) -> usize;

    // TODO: Change signature to be in-place.
    /// Uses this decomposition to solve an equation of the form
    /// $A\vec{x} = \vec{y}$ for $\vec{x}$ given $\vec{y}$, where $A$ is
    /// implicitly represented by this decomposition.
    fn solve_vector(&self, rhs: &ArrayBase<S, Ix1>) -> Result<Self::VectorSolution, Self::Error>;

    // TODO: Change signature to be in-place.
    /// Uses this decomposition to solve an equation of the form
    /// $AX = Y$ for $X$ given $Y$, where $A$ is
    /// implicitly represented by this decomposition.
    fn solve_matrix(&self, rhs: &ArrayBase<S, Ix2>) -> Result<Self::MatrixSolution, Self::Error>;
}

impl<A, S> LUDecomposition<A, S> for LU<A, S>
where
    S: Data<Elem = A>,
    A: Scalar,
{
    type Error = QdkSimError;
    type VectorSolution = ArrayBase<OwnedRepr<A>, Ix1>;
    type MatrixSolution = ArrayBase<OwnedRepr<A>, Ix2>;

    fn solve_vector(&self, rhs: &ArrayBase<S, Ix1>) -> Result<Self::VectorSolution, Self::Error> {
        todo!()
    }

    fn solve_matrix(&self, rhs: &ArrayBase<S, Ix2>) -> Result<Self::MatrixSolution, Self::Error> {
        let n_rows = rhs.require_square()?;
        let mut result = rhs.to_owned();
        for (idx_col, idx_pivot) in self.pivots.iter().enumerate() {
            if idx_col != *idx_pivot {
                result.swap_index_axis(Axis(0), idx_col, *idx_pivot);
            }
        }

        // NB: We use explicit for loops here as using vectorized indexing
        //     for triangular slices is somewhat challenging to do robustly.
        //
        //     Note that by convention, we have stored both the lower- and
        //     upper-triangular parts of the LU decomposition in the same
        //     array, so restricting how we index the decomposition array gives
        //     us each part of the decomposition.

        // Start by solving by using the lower-triangular part.
        for k in 0..n_rows {
            for i in k + 1..n_rows {
                for j in 0..n_rows {
                    let temp = result[(k, j)] * self.factors[(i, k)];
                    result[(i, j)] -= temp;
                }
            }
        }

        // Solve the upper-triangular part.
        for k in (0..n_rows).rev() {
            for j in 0..n_rows {
                result[(k, j)] /= self.factors[(k, k)];
            }
            for i in 0..k {
                for j in 0..n_rows {
                    let temp = result[(k, j)] * self.factors[(i, k)];
                    result[(i, j)] -= temp;
                }
            }
        }

        Ok(result)
    }

    fn order(&self) -> usize {
        self.factors.shape()[0]
    }
}

#[cfg(test)]
mod tests {
    use approx::assert_abs_diff_eq;
    use cauchy::c64;
    use ndarray::{array, Array2, OwnedRepr};

    use crate::{
        c64,
        error::QdkSimError,
        linalg::decompositions::{LUDecomposable, LU},
    };

    #[test]
    fn lu_decomposition_works_f64() -> Result<(), QdkSimError> {
        let mtx = array![[6.0, 18.0, 3.0], [2.0, 12.0, 1.0], [4.0, 15.0, 3.0]];
        let lu: LU<f64, OwnedRepr<f64>> = mtx.lu()?;

        // NB: This tests the internal structure of the LU decomposition, and
        //     may validly fail if the algorithm above is modified.
        let expected_factors = array![
            [6.0, 18.0, 3.0],
            [0.3333333333333333, 6.0, 0.0],
            [0.6666666666666666, 0.5, 1.0],
        ];
        for (actual, expected) in lu.factors.iter().zip(expected_factors.iter()) {
            assert_abs_diff_eq!(actual, expected, epsilon = 1e-6);
        }

        let expected_pivots = vec![0, 1, 2];
        assert_eq!(lu.pivots.to_vec(), expected_pivots);
        Ok(())
    }

    #[test]
    fn lu_decomposition_works_c64() -> Result<(), QdkSimError> {
        // In [1]: import scipy.linalg as la
        // In [2]: la.lu([
        //    ...:     [-1, 1j, -2],
        //    ...:     [3, 0, -4j],
        //    ...:     [-1, 5, -1]
        //    ...: ])
        // Out[2]: (array([[0., 0., 1.],
        //                 [1., 0., 0.],
        //                 [0., 1., 0.]]),
        //          array([[ 1.        +0.j ,  0.        +0.j ,  0.        +0.j ],
        //                 [-0.33333333+0.j ,  1.        +0.j ,  0.        +0.j ],
        //                 [-0.33333333+0.j ,  0.        +0.2j,  1.        +0.j ]]),
        //          array([[ 3.        +0.j        ,  0.        +0.j        ,
        //                  -0.        -4.j        ],
        //                 [ 0.        +0.j        ,  5.        +0.j        ,
        //                  -1.        -1.33333333j],
        //                 [ 0.        +0.j        ,  0.        +0.j        ,
        //                  -2.26666667-1.13333333j]]))
        let mtx: Array2<c64> = array![
            [c64!(-1.0), c64!(1.0 i), c64!(-2.0)],
            [c64!(3.0), c64!(0.0), c64!(-4.0 i)],
            [c64!(-1.0), c64!(5.0), c64!(-1.0)]
        ];
        let lu: LU<c64, OwnedRepr<c64>> = mtx.lu()?;

        // NB: This tests the internal structure of the LU decomposition, and
        //     may validly fail if the algorithm above is modified.
        let expected_factors = array![
            [c64::new(3.0, 0.0), c64::new(0.0, 0.0), c64::new(0.0, -4.0)],
            [
                c64::new(-0.3333333333333333, 0.0),
                c64::new(5.0, 0.0),
                c64::new(-1.0, -1.3333333333333333)
            ],
            [
                c64::new(-0.3333333333333333, 0.0),
                c64::new(0.0, 0.2),
                c64::new(-2.26666667, -1.13333333)
            ],
        ];
        for (actual, expected) in lu.factors.iter().zip(expected_factors.iter()) {
            assert_abs_diff_eq!(actual, expected, epsilon = 1e-6);
        }

        let expected_pivots = vec![1, 2, 2];
        assert_eq!(lu.pivots.to_vec(), expected_pivots);
        Ok(())
    }
}
