// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use std::ops::Mul;

use ndarray::{Array, Array1, Array2, ArrayView1, ArrayView2};

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
        self.view().tensor(other)
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
