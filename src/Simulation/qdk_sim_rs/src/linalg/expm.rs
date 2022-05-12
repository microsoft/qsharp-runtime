// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use std::ops::Mul;

use cauchy::Scalar;

#[cfg(feature = "pade")]
use ndarray::{ArrayBase, Data, Ix2, OwnedRepr, RawData, ScalarOperand};

use crate::linalg::decompositions::{EigenvalueDecomposition, ExplicitEigenvalueDecomposition};

#[cfg(feature = "pade")]
use crate::{
    error::QdkSimError,
    linalg::{Identity, Inv, MatrixPower},
    math::approximate_factorial,
};

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
pub trait Expm<A>
where
    A: Scalar,
{
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

    /// Returns the matrix exponential $e^{\alpha A}$ of a matrix $A$,
    /// and where $\alpha$ is a complex scalar.
    fn expm_scale(&self, scale: A) -> Result<Self::Output, Self::Error>;
}

impl<A> Expm<A> for ExplicitEigenvalueDecomposition<A>
where
    A: Scalar + Mul<Output = A>,
    ExplicitEigenvalueDecomposition<A>: EigenvalueDecomposition<A>,
{
    type Error = <Self as EigenvalueDecomposition<A>>::Error;
    type Output = <Self as EigenvalueDecomposition<A>>::MatrixSolution;

    fn expm(&self) -> Result<Self::Output, Self::Error> {
        self.apply_mtx_fn(|x| x.exp())
    }

    fn expm_scale(&self, scale: A) -> Result<Self::Output, Self::Error> {
        self.apply_mtx_fn(|x| (*x * scale).exp())
    }
}

#[cfg(feature = "pade")]
impl<A, S, E> Expm<A> for ArrayBase<S, Ix2>
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

    fn expm_scale(&self, scale: A) -> Result<Self::Output, Self::Error> {
        Ok((self * scale).expm()?)
    }
}

// TODO: Allow simpler type constraints.
// fn pade_d<'a, T: Identity + MatrixPower<Error = E>, E>(mtx: &'a T, p: u32, q: u32) -> Result<T, E>
// where &'a T: Neg<Output = T> {
#[cfg(feature = "pade")]
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

#[cfg(feature = "pade")]
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
    use std::f64::consts::FRAC_1_SQRT_2;

    use approx::assert_abs_diff_eq;
    use cauchy::c64;
    use ndarray::array;

    use crate::{
        c64,
        error::QdkSimError,
        linalg::{decompositions::ExplicitEigenvalueDecomposition, Expm},
    };

    #[cfg(feature = "pade")]
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
    fn explicit_eig_works_for_sparse_diag_h() -> Result<(), QdkSimError> {
        let h = ExplicitEigenvalueDecomposition {
            values: array![c64!(1.0), c64!(-1.0)],
            vectors: array![
                [c64!(1.0), c64!(0.0), c64!(0.0), c64!(0.0)],
                [c64!(0.0), c64!(0.0), c64!(0.0), c64!(-1.0)],
            ],
        };
        let actual = (c64!(1.0 i) * h).expm()?;
        // We can compute the expected output below by using QuTiP in Python.
        let expected = array![
            [
                c64!(0.54030231 + 0.84147098 i),
                c64!(0.0),
                c64!(0.0),
                c64!(0.0)
            ],
            [c64!(0.0), c64!(1.0), c64!(0.0), c64!(0.0)],
            [c64!(0.0), c64!(0.0), c64!(1.0), c64!(0.0)],
            [
                c64!(0.0),
                c64!(0.0),
                c64!(0.0),
                c64!(0.54030231 - 0.84147098 i)
            ],
        ];
        for (actual, expected) in actual.iter().zip(expected.iter()) {
            assert_abs_diff_eq!(actual, expected, epsilon = 1e-8);
        }
        Ok(())
    }

    #[test]
    fn explicit_eig_works_for_ry() -> Result<(), QdkSimError> {
        let hy = ExplicitEigenvalueDecomposition {
            values: array![c64!(1.0), c64!(-1.0)],
            vectors: array![
                [c64::new(-0.0, -FRAC_1_SQRT_2), c64::new(FRAC_1_SQRT_2, 0.0)],
                [c64::new(FRAC_1_SQRT_2, 0.0), c64::new(0.0, -FRAC_1_SQRT_2)],
            ],
        };
        let actual = (c64!(1.0 i) * hy).expm()?;
        // We can compute the expected output below by using QuTiP in Python:
        //
        // >>> import qutip as qt
        // >>> Y = qt.sigmay()
        // >>> (1j * Y).expm()
        // Quantum object: dims = [[2], [2]], shape = (2, 2), type = oper, isherm = False
        // Qobj data =
        // [[ 0.54030231  0.84147098]
        //  [-0.84147098  0.54030231]]
        let expected = array![
            [c64!(0.54030231), c64!(0.84147098)],
            [c64!(-0.84147098), c64!(0.54030231)]
        ];
        for (actual, expected) in actual.iter().zip(expected.iter()) {
            assert_abs_diff_eq!(actual, expected, epsilon = 1e-6);
        }
        Ok(())
    }

    #[test]
    fn explicit_eig_works_for_gy() -> Result<(), QdkSimError> {
        let gy = ExplicitEigenvalueDecomposition {
            values: array![c64!(1.0 i), c64!(-1.0 i)],
            vectors: array![
                [c64!(0.5 i), c64!(-0.5), c64!(0.5), c64!(0.5 i)],
                [c64!(0.5), c64!(-0.5 i), c64!(0.5 i), c64!(0.5)],
            ],
        };
        let actual = gy.expm()?;
        // We can compute the expected output below by using QuTiP in Python.
        let expected = array![
            [
                c64!(0.77015115293407),
                c64!(0.4207354924039481),
                c64!(-0.42073549240394814),
                c64!(-0.22984884706592998)
            ],
            [
                c64!(-0.42073549240394803),
                c64!(0.77015115293407),
                c64!(0.22984884706593),
                c64!(-0.4207354924039482)
            ],
            [
                c64!(0.42073549240394814),
                c64!(0.22984884706592998),
                c64!(0.7701511529340699),
                c64!(0.4207354924039481)
            ],
            [
                c64!(-0.22984884706593),
                c64!(0.42073549240394803),
                c64!(-0.4207354924039482),
                c64!(0.77015115293407)
            ]
        ];

        for (actual, expected) in actual.iter().zip(expected.iter()) {
            assert_abs_diff_eq!(actual, expected, epsilon = 1e-6);
        }
        Ok(())
    }
}
