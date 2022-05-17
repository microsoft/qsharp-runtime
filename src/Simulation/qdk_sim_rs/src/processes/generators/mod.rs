// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

mod common;

use cauchy::c64;
pub use common::*;
use ndarray::{Array1, Array2};
use serde::{Deserialize, Serialize};

use crate::{
    error::QdkSimError,
    linalg::{decompositions::ExplicitEigenvalueDecomposition, Expm},
    Process, QubitSized,
};

/// Representation of a single-parameter monoid whose elements
/// are quantum processes; that is, the generator of a quantum dynamical
/// monoid.
///
/// Typically, such representations will be derived from Hamiltonian
/// evolution together with some dissipative evolution, as per Lindblad form.
///
/// # Dimensions
/// Generators are expected to represent $4^n \times 4^n$ matrices of the form
/// $G = -\mathrm{i}L + D$, where $L$ is a Liouvillian operator in
/// column-stacking representation (that is, $L = 𝟙 \otimes H - H \otimes 𝟙$),
/// where $H$ is the Hamiltonian, and where $D$ is a dissipator.
pub type Generator = QubitSized<GeneratorData>;

/// Data used to represent a single-parameter monoid whose elements
/// are quantum processes.
#[derive(Clone, Debug, Serialize, Deserialize)]
pub enum GeneratorData {
    /// A representation of a quantum dynamical monoid in terms of the
    /// eigenvalue decomposition of its generator.
    ///
    /// # Remarks
    /// The null space (eigenvectors corresponding to zero eigenvalues) can be
    /// omitted, as they do not contribute to exponentials of generators.
    ExplicitEigenvalueDecomposition {
        /// The eigenvalues of the generator.
        values: Array1<c64>,
        /// The eigenvectors of the generator.
        ///
        /// # Dimensions
        /// This field should have shape `[n_eig, dim]`, where the length of
        /// [`values`] is `n_eig`, and where `dim` is the dimension of the
        /// Liouville space on which this generator acts.
        vectors: Array2<c64>,
    },

    /// Represents that dynamical evolution is not supported in the given noise
    /// model (e.g.: a stabilizer model).
    Unsupported,
}

impl Generator {
    /// Returns an unsupported generator on a specified number of qubits.
    pub fn unsupported(n_qubits: usize) -> Self {
        Self {
            n_qubits,
            data: GeneratorData::Unsupported,
        }
    }

    /// Evaluates a generator at a specific time, returning the process at that
    /// point.
    pub fn at(&self, time: f64) -> Result<Process, QdkSimError> {
        match &self.data {
            GeneratorData::ExplicitEigenvalueDecomposition { values, vectors } => {
                let eig = ExplicitEigenvalueDecomposition {
                    // TODO[perf]: eliminate these two calls to clone; we only
                    //             need them since GeneratorData has to be
                    //             Serialize and thus cannot be the same
                    //             struct as ExplicitEigenvalueDecomposition<T>
                    //             for T that may not be Serialize.
                    values: values.clone(),
                    vectors: vectors.clone(),
                };
                let mtx = eig.expm_scale(c64::new(time, 0.0));
                Ok(Process {
                    n_qubits: self.n_qubits,
                    data: crate::ProcessData::Superoperator(mtx?),
                })
            }
            GeneratorData::Unsupported => Err(QdkSimError::misc(
                "Cannot evaluate generator of kind Unsupported.".to_string(),
            )),
        }
    }
}

/// Data used to represent a single-parameter monoid whose elements
/// are quantum processes, possibly preceded or followed by a time-independent
/// quantum process.
#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct GeneratorCoset {
    /// The quantum process which occurs before dynamical evolution, or
    /// [`Option::None`] if no such process occurs or is identity.
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub pre: Option<Process>,

    /// The quantum process which occurs following dynamical evolution, or
    /// [`Option::None`] if no such process occurs or is identity.
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub post: Option<Process>,

    /// The generator whose coset this struct represents.
    pub generator: Generator,
}

impl GeneratorCoset {
    /// Evaluates a generator at a specific time, returning the process at that
    /// point. By contrast with [`Generator::at`], this method includes the
    /// effect of any pre- or post-evolution quantum processes.
    pub fn at(&self, time: f64) -> Result<Process, QdkSimError> {
        let mut seq = vec![self.generator.at(time)?];
        if let Some(pre) = &self.pre {
            seq.insert(0, pre.clone());
        }
        if let Some(post) = &self.post {
            seq.push(post.clone());
        }
        Ok(Process {
            n_qubits: self.generator.n_qubits,
            data: crate::ProcessData::Sequence(seq),
        })
    }
}

impl From<Generator> for GeneratorCoset {
    fn from(generator: Generator) -> Self {
        Self {
            pre: None,
            post: None,
            generator,
        }
    }
}

#[cfg(test)]
mod tests {
    use approx::assert_abs_diff_eq;

    use crate::{c64, ProcessData, VariantName};

    use super::*;

    #[test]
    fn superoperator_at_rx_is_correct() -> Result<(), QdkSimError> {
        let actual = Generator::hx().at(0.123)?;
        let expected = array![
            [
                c64!(0.9962225160675967),
                c64!(-0.06134504501215767 i),
                c64!(0.06134504501215767 i),
                c64!(0.003777483932403215)
            ],
            [
                c64!(-0.06134504501215767 i),
                c64!(0.9962225160675967),
                c64!(0.003777483932403215),
                c64!(0.06134504501215767 i)
            ],
            [
                c64!(0.06134504501215767 i),
                c64!(0.003777483932403215),
                c64!(0.9962225160675967),
                c64!(-0.06134504501215767 i)
            ],
            [
                c64!(0.003777483932403215),
                c64!(0.06134504501215767 i),
                c64!(-0.06134504501215767 i),
                c64!(0.9962225160675967)
            ]
        ];

        if let ProcessData::Superoperator(actual) = actual.data {
            for (actual, expected) in actual.iter().zip(expected.iter()) {
                assert_abs_diff_eq!(actual, expected, epsilon = 1e-6);
            }
            Ok(())
        } else {
            panic!("Expected superoperator, got {}.", actual.variant_name())
        }
    }

    #[test]
    fn superoperator_at_ry_is_correct() -> Result<(), QdkSimError> {
        let actual = Generator::hy().at(0.123)?;
        let expected = array![
            [
                c64!(0.9962225160675967),
                c64!(-0.06134504501215767),
                c64!(-0.06134504501215767),
                c64!(0.003777483932403215)
            ],
            [
                c64!(0.06134504501215767),
                c64!(0.9962225160675967),
                c64!(-0.003777483932403215),
                c64!(-0.06134504501215767)
            ],
            [
                c64!(0.06134504501215767),
                c64!(-0.003777483932403215),
                c64!(0.9962225160675967),
                c64!(-0.06134504501215767)
            ],
            [
                c64!(0.003777483932403215),
                c64!(0.06134504501215767),
                c64!(0.06134504501215767),
                c64!(0.9962225160675967)
            ]
        ];

        if let ProcessData::Superoperator(actual) = actual.data {
            for (actual, expected) in actual.iter().zip(expected.iter()) {
                assert_abs_diff_eq!(actual, expected, epsilon = 1e-6);
            }
            Ok(())
        } else {
            panic!("Expected superoperator, got {}.", actual.variant_name())
        }
    }
}
