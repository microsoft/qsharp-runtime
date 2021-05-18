// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

//! Provides common linear algebra functions and traits.

use ndarray::{Array, Array1, Array2, ArrayView1, ArrayView2};
use num_traits::Zero;
use std::{convert::TryInto, ops::Mul};

use crate::{common_matrices::nq_eye, C64};

/// Represents types that have hermitian conjugates (e.g.: $A^\dagger$ for
/// a matrix $A$ is defined as the complex conjugate transpose of $A$,
/// $(A^\dagger)\_{ij} = A\_{ji}^*$).
pub trait HasDagger {
    /// The type of the hermitian conjugate.
    type Output;

    /// Returns the hermitian conjugate (colloquially, the dagger) of a
    /// borrowed reference as a new copy.
    ///
    /// For most types implementing this trait, the hermitian conjugate
    /// is represented by the conjugate transpose.
    fn dag(&self) -> Self::Output;
}

impl HasDagger for Array2<C64> {
    type Output = Self;

    fn dag(&self) -> Self {
        self.t().map(|element| element.conj())
    }
}

impl HasDagger for ArrayView2<'_, C64> {
    type Output = Array2<C64>;

    fn dag(&self) -> Self::Output {
        self.t().map(|element| element.conj())
    }
}

/// Represent types that can be conjugated by 2-dimensional arrays; that is,
/// as $UXU^{\dagger}$.
pub trait ConjBy {
    /// Conjugates this value by a given matrix, returning a copy.
    fn conjugate_by(&self, op: &ArrayView2<C64>) -> Self;
}

impl ConjBy for Array2<C64> {
    fn conjugate_by(&self, op: &ArrayView2<C64>) -> Self {
        op.dot(self).dot(&op.dag())
    }
}

/// The tensor product operator ($\otimes$).
pub trait Tensor<Rhs = Self> {
    /// The resulting type after applying the tensor product.
    type Output;

    /// Performs the tensor product.
    ///
    /// # Example
    /// ```
    /// // TODO
    /// ```
    fn tensor(self, rhs: Rhs) -> Self::Output;
}

impl<Other: Into<Self>, T: Copy + Mul<Output = T>> Tensor<Other> for ArrayView1<'_, T> {
    type Output = Array1<T>;
    fn tensor(self, other: Other) -> Self::Output {
        let other: Self = other.into();
        let unflat = Array::from_shape_fn((self.shape()[0], other.shape()[0]), |(i, j)| {
            self[(i)] * other[(j)]
        });
        unflat
            .into_shape(self.shape()[0] * other.shape()[0])
            .unwrap()
    }
}

impl<Other: Into<Self>, T: Copy + Mul<Output = T>> Tensor<Other> for &Array1<T> {
    type Output = Array1<T>;

    fn tensor(self, other: Other) -> Self::Output {
        let other: Self = other.into();
        self.view().tensor(other).to_owned()
    }
}

impl<Other: Into<Self>, T: Copy + Mul<Output = T>> Tensor<Other> for ArrayView2<'_, T> {
    type Output = Array2<T>;
    fn tensor(self, other: Other) -> Self::Output {
        let other: Self = other.into();
        let unflat = Array::from_shape_fn(
            (
                self.shape()[0],
                other.shape()[0],
                self.shape()[1],
                other.shape()[1],
            ),
            |(i, j, k, l)| self[(i, k)] * other[(j, l)],
        );
        unflat
            .into_shape((
                self.shape()[0] * other.shape()[0],
                self.shape()[1] * other.shape()[1],
            ))
            .unwrap()
    }
}

impl<Other: Into<Self>, T: Copy + Mul<Output = T>> Tensor<Other> for &Array2<T> {
    type Output = Array2<T>;

    fn tensor(self, other: Other) -> Self::Output {
        let other: Self = other.into();
        self.view().tensor(other).to_owned()
    }
}

/// Represents types for which the trace can be computed.
pub trait Trace {
    /// The type returned by the trace.
    type Output;

    /// The trace (typically, the sum of the eigenvalues,
    /// or the sum of the diagonal elements $\sum_i A_{ii}$).
    ///
    /// # Example
    /// ```
    /// // TODO
    /// ```
    fn trace(self) -> Self::Output;
}

impl<T: Clone + Zero> Trace for Array2<T> {
    type Output = T;

    fn trace(self) -> Self::Output {
        self.diag().sum()
    }
}

impl<T: Clone + Zero> Trace for &Array2<T> {
    type Output = T;

    fn trace(self) -> Self::Output {
        self.diag().sum()
    }
}

// FIXME: modify to Result<..., String> so that errors can propagate to the C API.
// FIXME[perf]: This function is significantly slower than would be expected
//              from microbenchmarks on tensor and nq_eye directly.
/// Given an array representing an operator acting on single-qubit states,
/// returns a new operator that acts on $n$-qubit states.
pub fn extend_one_to_n(data: ArrayView2<C64>, idx_qubit: usize, n_qubits: usize) -> Array2<C64> {
    let n_left = idx_qubit;
    let n_right = n_qubits - idx_qubit - 1;
    match (n_left, n_right) {
        (0, _) => {
            let right_eye = nq_eye(n_right);
            data.view().tensor(&right_eye)
        }
        (_, 0) => {
            let left_eye = Array2::eye(2usize.pow(n_left.try_into().unwrap()));
            left_eye.view().tensor(&data)
        }
        (_, _) => {
            let eye = nq_eye(n_right);
            let right = data.view().tensor(&eye);
            nq_eye(n_left).view().tensor(&right)
        }
    }
}

/// Given a view of an array representing a matrix acting on two-qubit states,
/// extends that array to act on $n$ qubits.
pub fn extend_two_to_n(
    data: ArrayView2<C64>,
    idx_qubit1: usize,
    idx_qubit2: usize,
    n_qubits: usize,
) -> Array2<C64> {
    // TODO: double check that data is 4x4.
    let mut permutation = Array::from((0..n_qubits).collect::<Vec<usize>>());
    match (idx_qubit1, idx_qubit2) {
        (1, 0) => permutation.swap(0, 1),
        (_, 0) => {
            permutation.swap(1, idx_qubit2);
            permutation.swap(1, idx_qubit1);
        }
        _ => {
            permutation.swap(1, idx_qubit2);
            permutation.swap(0, idx_qubit1);
        }
    };

    // TODO: there is almost definitely a more elegant way to write this.
    if n_qubits == 2 {
        // TODO[perf]: Eliminate the to_owned here by weakening permute_mtx.
        permute_mtx(&data.to_owned(), &permutation.to_vec()[..])
    } else {
        permute_mtx(
            &data.view().tensor(&nq_eye(n_qubits - 2)),
            &permutation.to_vec()[..],
        )
    }
}

/// Given a two-index array (i.e.: a matrix) of dimensions 2^n × 2^n for some
/// n, permutes the left and right indices of the matrix.
/// Used to represent, for example, swapping qubits in a register.
pub fn permute_mtx(data: &Array2<C64>, new_order: &[usize]) -> Array2<C64> {
    // Check that data is square.
    let (n_rows, n_cols) = (data.shape()[0], data.shape()[1]);
    assert_eq!(n_rows, n_cols);

    // Check that dims are 2^n and find n.
    let n_qubits = (n_rows as f64).log2().floor() as usize;
    assert_eq!(n_rows, 2usize.pow(n_qubits.try_into().unwrap()));

    // Check that the length of new_order is the same as the number of qubits.
    assert_eq!(n_qubits, new_order.len());

    // FIXME: there has to be a better way to make a vector that consists of
    //        2n copies of 2usize.
    let new_dims: Vec<usize> = vec![2usize]
        .iter()
        .cycle()
        .take(2 * n_qubits)
        .copied()
        .collect();
    // FIXME: make this a result and propagate the result out to the return.
    let tensor = data.clone().into_shared().reshape(new_dims);
    let mut permutation = new_order.to_vec();
    permutation.extend(new_order.to_vec().iter().map(|idx| idx + n_qubits));
    let permuted = tensor.permuted_axes(permutation);

    // Finish by collapsing back down.
    permuted.reshape([n_rows, n_rows]).into_owned()
}

/// Returns a new array of the same type and shape as a given array, but
/// containing only zeros.
pub fn zeros_like<T: Clone + Zero, Ix: ndarray::Dimension>(data: &Array<T, Ix>) -> Array<T, Ix> {
    Array::zeros(data.dim())
}
