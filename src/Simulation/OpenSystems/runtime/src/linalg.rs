// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use core::ops::Range;
use num_traits::Zero;
use ndarray::{ Array, Array1, Array2 };
use std::ops::Mul;
use std::convert::TryInto;
use std::cmp;

use crate::{ C64, nq_eye };

pub trait HasDagger {
    /// Returns the hermitian conjugate (colloquially, the dagger) of a
    /// borrowed reference as a new copy.
    ///
    /// For most types implementing this trait, the hermitian conjugate
    /// is represented by the conjugate transpose.
    fn dag(self: &Self) -> Self;
}

impl HasDagger for Array2<C64> {
    fn dag(self: &Self) -> Self {
        self.t().map(|element| element.conj())
    }
}

pub trait ConjBy {
    fn conjugate_by(self: &Self, op: &Array2<C64>) -> Self;
}

impl ConjBy for Array2<C64> {
    fn conjugate_by(self: &Self, op: &Array2<C64>) -> Self {
        op.dot(self).dot(&op.dag())
    }
}

pub trait Tensor {
    fn tensor(self: &Self, other: &Self) -> Self;
}

impl <T: Copy + Mul<Output = T>> Tensor for Array1<T> {
    fn tensor(&self, other: &Self) -> Self {
        let unflat = Array::from_shape_fn(
            (self.shape()[0], other.shape()[0]),
            |(i, j)| {
                self[(i)] * other[(j)]
            }
        );
        unflat.into_shape(self.shape()[0] * other.shape()[0]).unwrap()
    }
}

impl <T: Copy + Mul<Output = T>> Tensor for Array2<T> {
    fn tensor(&self, other: &Self) -> Self {
        let unflat = Array::from_shape_fn(
            (self.shape()[0], other.shape()[0], self.shape()[1], other.shape()[1]),
            |(i, j, k, l)| {
                self[(i, k)] * other[(j, l)]
            }
        );
        unflat.into_shape((self.shape()[0] * other.shape()[0], self.shape()[1] * other.shape()[1])).unwrap()
    }
}

pub trait Trace {
    type Output;

    fn trace(self) -> Self::Output;
}

impl <T: Clone + Zero> Trace for Array2<T> {
    type Output = T;

    fn trace(self) -> Self::Output {
        self.diag().sum()
    }
}

impl <T: Clone + Zero> Trace for &Array2<T> {
    type Output = T;

    fn trace(self) -> Self::Output {
        self.diag().sum()
    }
}


// FIXME: weaken data to be a view so that to_owned isn't needed.
// FIXME: modify to Result<..., String> so that errors can propagate to the C API.
pub fn extend_one_to_n(data: &Array2<C64>, idx_qubit: usize, n_qubits: usize) -> Array2<C64> {
    let n_left = idx_qubit;
    let n_right = n_qubits - idx_qubit - 1;
    match (n_left, n_right) {
        (0, _) => {
            let right_eye = nq_eye(n_right);
            data.tensor(&right_eye)
        },
        (_, 0) => {
            let left_eye = Array2::eye(2usize.pow(n_left.try_into().unwrap()));
            left_eye.tensor(data)
        },
        (_, _) => nq_eye(n_left).tensor(&data.tensor(&nq_eye(n_right)))
    }
}

pub fn extend_two_to_n(data: &Array2<C64>, idx_qubit1: usize, idx_qubit2: usize, n_qubits: usize) -> Array2<C64> {
    // TODO: double check that data is 4x4.
    let mut permutation = Array::from((0..n_qubits).collect::<Vec<usize>>());
    match (idx_qubit1, idx_qubit2) {
        (1, 0) => permutation.swap(0, 1),
        (_, 0) => {
            permutation.swap(1, idx_qubit2);
            permutation.swap(1, idx_qubit1);
        },
        _ => {
            permutation.swap(1, idx_qubit2);
            permutation.swap(0, idx_qubit1);
        }
    };

    // TODO: there is almost definitely a more elegant way to write this.
    if n_qubits == 2 {
        permute_mtx(data, &permutation.to_vec()[..])
    } else {
        permute_mtx(&data.tensor(&nq_eye(n_qubits - 2)), &permutation.to_vec()[..])
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
    let new_dims: Vec<usize> = vec![2usize].iter().cycle().take(2 * n_qubits).map(|x| x.clone()).collect();
    // FIXME: make this a result and propagate the result out to the return.
    let tensor = data.clone().into_shared().reshape(new_dims);
    let mut permutation = new_order.to_vec();
    permutation.extend(new_order.to_vec().iter().map(|idx| idx + n_qubits));
    let permuted = tensor.permuted_axes(permutation);

    // Finish by collapsing back down.
    permuted.reshape([n_rows, n_rows]).into_owned()
}


pub fn zeros_like<T: Clone + Zero, Ix: ndarray::Dimension>(data: &Array<T, Ix>) -> Array<T, Ix> {
    Array::zeros(data.dim())
}
