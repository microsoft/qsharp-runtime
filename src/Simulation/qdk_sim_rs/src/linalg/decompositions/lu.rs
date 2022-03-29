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

#[derive(Debug)]
pub struct LU<A, S>
where
    S: Data<Elem = A>,
    A: Scalar,
{
    pub(self) factors: ArrayBase<S, Ix2>,
    pub(self) pivots: Array1<usize>,
}

pub trait LUDecomposable {
    type Elem: Scalar;
    type Repr: Data<Elem = Self::Elem>;
    type OwnedRepr: Data + RawData<Elem = Self::Elem>;
    type Output: LUDecomposition<Self::Elem, Self::OwnedRepr>;
    type Error;

    fn lu(&self) -> Result<Self::Output, Self::Error>;
}

impl<A, S> LUDecomposable for ArrayBase<S, Ix2>
where
    S: Data<Elem = A>,
    A: Scalar,
{
    type Elem = A;
    type Repr = S;
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

        let mut factors = &mut (*self).to_owned();
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

pub trait LUDecomposition<A, S>
where
    S: Data<Elem = A>,
    A: Scalar,
{
    type Error: std::error::Error;
    type VectorSolution;
    type MatrixSolution;

    fn order(&self) -> usize;

    // TODO: Change signature to be in-place.
    fn solve_vector(&self, rhs: &ArrayBase<S, Ix1>) -> Result<Self::VectorSolution, Self::Error>;
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
    use ndarray::array;

    use crate::{error::QdkSimError, linalg::decompositions::LUDecomposable};

    #[test]
    fn lu_decomposition_works_f64() -> Result<(), QdkSimError> {
        let mtx = array![[6.0, 18.0, 3.0], [2.0, 12.0, 1.0], [4.0, 15.0, 3.0]];
        // TODO: Actually write the test!
        let lu = mtx.lu()?;
        println!("{:?}", lu);
        Ok(())
    }
}
