use cauchy::c64;
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
#[derive(Clone, Debug, Serialize, Deserialize)]
pub enum GeneratorData {
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
