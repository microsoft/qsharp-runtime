// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use std::{fmt::Error, ops::Neg, process::Output};

use cauchy::Scalar;
use ndarray::{
    linalg::Dot, Array2, ArrayBase, Data, Ix2, OwnedRepr, RawArrayView, RawData, ScalarOperand,
};

use crate::{
    error::QdkSimError,
    linalg::{decompositions::EigenvalueDecomposition, Identity, Inv, MatrixPower},
    math::approximate_factorial,
};

use super::{decompositions::ExplicitEigenvalueDecomposition, HasDagger};

// NB: We use the notation of
//     https://www.cs.jhu.edu/~misha/ReadingSeminar/Papers/Moler03.pdf.
//
//     In particular:
//
//         e^{A} ≈ R_pq(A) ≔ [D_pq(A)]⁻¹ N_pq(A)
//
//     where
//
//         N_pq(A) ≔ Σ_j=0^p [(p + q - j)! p!] / [(p + q)! j! (p - j)!] A^j
//
//     and
//
//         D_pq(A) ≔ Σ_j=0^q [(p + q - j)! p!] / [(p + q)! j! (q - j)!] (-A)^j.

/// Types that support the matrix exponential $e^{A}$.
pub trait Expm {
    /// Errors that can result from the [`expm`] method.
    ///
    /// [`expm`]: Expm::expm
    type Error;
    /// Type used to represent $e^{A}$ when calling [`expm`].
    ///
    /// [`expm`]: Expm::expm
    type Output;

    /// Returns the matrix exponential $e^{A}$ of a matrix $A$.
    fn expm(&self) -> Result<Self::Output, Self::Error>;
}

impl<A> Expm for ExplicitEigenvalueDecomposition<A>
where
    A: Scalar,
    ExplicitEigenvalueDecomposition<A>: EigenvalueDecomposition<A>,
{
    type Error = <Self as EigenvalueDecomposition<A>>::Error;
    type Output = <Self as EigenvalueDecomposition<A>>::MatrixSolution;

    fn expm(&self) -> Result<Self::Output, Self::Error> {
        self.apply_mtx_fn(|x| x.exp())
    }
}

impl<A, S, E> Expm for ArrayBase<S, Ix2>
where
    S: Data + RawData<Elem = A>,
    A: Scalar + ScalarOperand,
    E: std::convert::From<QdkSimError>,
    ArrayBase<S, Ix2>: Inv<Error = E> + Identity,
{
    type Error = E;
    type Output = ArrayBase<OwnedRepr<A>, Ix2>;

    fn expm(&self) -> Result<Self::Output, Self::Error> {
        // TODO: allow generalizing p, q
        let p = 16;
        let q = 16;

        let n = pade_n::<A, S, E>(self, p, q)?;
        let d_inv = pade_d::<A, S, E>(self, p, q)?.inv()?;

        Ok(d_inv.dot(&n))
    }
}

// TODO: Allow simpler type constraints.
// fn pade_d<'a, T: Identity + MatrixPower<Error = E>, E>(mtx: &'a T, p: u32, q: u32) -> Result<T, E>
// where &'a T: Neg<Output = T> {
fn pade_d<A: Scalar + ScalarOperand, S: Data + RawData<Elem = A>, E>(
    mtx: &ArrayBase<S, Ix2>,
    p: u32,
    q: u32,
) -> Result<ArrayBase<OwnedRepr<A>, Ix2>, E>
where
    ArrayBase<S, Ix2>: Inv<Error = E> + Identity,
    E: std::convert::From<QdkSimError>,
{
    // D_pq(A) ≔ Σ_j=0^q [(p + q - j)! p!] / [(p + q)! j! (q - j)!] (-A)^j
    let mut result = mtx.eye_like().to_owned();
    for j in 0..q + 1 {
        let arr: [i64; 0] = [];
        assert!(arr.len() == 0);
        let coeff = (approximate_factorial::<_, f64>(p + q - j)
            * approximate_factorial::<_, f64>(p))
            / (approximate_factorial::<_, f64>(p + q)
                * approximate_factorial::<_, f64>(j)
                * approximate_factorial::<_, f64>(q - j));
        let coeff = A::from(coeff).unwrap();
        let mtx_pow = (-mtx.to_owned()).matrix_power(j.into())?;
        let term = mtx_pow * coeff;
        result = result + term;
    }
    Ok(result)
}

fn pade_n<A: Scalar + ScalarOperand, S: Data + RawData<Elem = A>, E>(
    mtx: &ArrayBase<S, Ix2>,
    p: u32,
    q: u32,
) -> Result<ArrayBase<OwnedRepr<A>, Ix2>, E>
where
    ArrayBase<S, Ix2>: Inv<Error = E> + Identity,
    E: std::convert::From<QdkSimError>,
{
    // N_pq(A) ≔ Σ_j=0^p [(p + q - j)! p!] / [(p + q)! j! (p - j)!] A^j
    // [(p + q - 0)! p!] / [(p + q)! (p)!]
    let mut result = mtx.eye_like().to_owned();
    for j in 0..p + 1 {
        let coeff = (approximate_factorial::<_, f64>(p + q - j)
            * approximate_factorial::<_, f64>(p))
            / (approximate_factorial::<_, f64>(p + q)
                * approximate_factorial::<_, f64>(j)
                * approximate_factorial::<_, f64>(p - j));
        let coeff = A::from(coeff).unwrap();
        let mtx_pow = mtx.to_owned().matrix_power(j.into())?;
        let term = mtx_pow * coeff;
        result = result + term;
    }
    Ok(result)
}

#[cfg(test)]
mod tests {
    use cauchy::c64;
    use ndarray::array;
    use num_traits::{One, Zero};

    use crate::{
        c64,
        error::QdkSimError,
        linalg::{decompositions::ExplicitEigenvalueDecomposition, Expm},
    };

    #[test]
    fn expm_works_for_rz() -> Result<(), QdkSimError> {
        let hz =
            c64::new(0.0, -1.0) * array![[c64::one(), c64::zero()], [c64::zero(), -c64::one()]];
        println!("hz = {hz}");
        let u = hz.expm();
        // FIXME: returns the wrong answer, so we print while we diagnose.
        println!("{:?}", u);
        panic!("Test currently fails.");
    }

    #[test]
    fn explicit_eig_works_for_ry() -> Result<(), QdkSimError> {
        let hy = ExplicitEigenvalueDecomposition {
            values: array![c64!(1.0), c64!(-1.0)],
            vectors: array![
                [
                    c64::new(-0.0, -0.7071067811865474),
                    c64::new(0.7071067811865475, 0.0)
                ],
                [
                    c64::new(0.7071067811865476, 0.0),
                    c64::new(0.0, -0.7071067811865475)
                ],
            ],
        };
        let actual = (c64!(1.0 i) * hy).expm();
        todo!();
    }
}
