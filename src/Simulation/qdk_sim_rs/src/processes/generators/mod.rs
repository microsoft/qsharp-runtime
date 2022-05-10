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

pub type Generator = QubitSized<GeneratorData>;

/// Data used to represent a single-parameter monoid whose elements
/// are quantum processes.
///
/// # Dimensions
/// Generators are expected to represent $4^n \times 4^n$ matrices of the form
/// $G = -\mathrm{i}L + D$, where $L$ is a Liouvillian operator in
/// column-stacking representation (that is, $L = 𝟙 \otimes H - H \otimes 𝟙$),
/// where $H$ is the Hamiltonian, and where $D$ is a dissipator.
#[derive(Clone, Debug, Serialize, Deserialize)]
pub enum GeneratorData {
    /// # Remarks
    /// The null space (eigenvectors corresponding to zero eigenvalues) can be
    /// omitted, as they do not contribute to exponentials of generators.
    ExplicitEigenvalueDecomposition {
        values: Array1<c64>,
        vectors: Array2<c64>,
    },
    Unsupported,
}

impl Generator {
    pub fn unsupported(n_qubits: usize) -> Self {
        Self {
            n_qubits,
            data: GeneratorData::Unsupported,
        }
    }

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
            GeneratorData::Unsupported => Err(QdkSimError::MiscError(
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
    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub pre: Option<Process>,

    #[serde(default)]
    #[serde(skip_serializing_if = "Option::is_none")]
    pub post: Option<Process>,

    pub generator: Generator,
}

impl GeneratorCoset {
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
