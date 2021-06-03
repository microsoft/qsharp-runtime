// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// FIXME: remove when the Python module is documented.
#![allow(missing_docs)]

use std::convert::TryFrom;

use crate::{built_info, Instrument, NoiseModel, Pauli, Process};
use crate::{tableau::Tableau, State};
use pyo3::{exceptions::PyRuntimeError, prelude::*, types::PyType, PyObjectProtocol};
use serde_json::json;

#[pymodule]
fn _qdk_sim_rs(_py: Python, m: &PyModule) -> PyResult<()> {
    /// Returns information about how this simulator was built, serialized as a
    /// JSON object.
    #[pyfn(m, "build_info_json")]
    fn build_info_json_py(_py: Python) -> String {
        // TODO[code quality]: Deduplicate this with the
        // version in the c_api module.
        let build_info = json!({
            "name": "Microsoft.Quantum.Experimental.Simulators",
            "version": built_info::PKG_VERSION,
            "opt_level": built_info::OPT_LEVEL,
            "features": built_info::FEATURES,
            "target": built_info::TARGET
        });
        serde_json::to_string(&build_info).unwrap()
    }

    #[pyfn(m, "pauli_test")]
    fn pauli_test(_py: Python, p: Pauli) -> Pauli {
        p
    }

    m.add_class::<Tableau>()?;
    m.add_class::<PyState>()?;
    m.add_class::<PyProcess>()?;
    m.add_class::<PyInstrument>()?;
    m.add_class::<PyNoiseModel>()?;
    Ok(())
}

// Design notes:
//
// Some important Rust concepts, such as enums, do not forward "nicely" to
// Python types. When that happens, we make new types here to wrap the pure-Rust
// equivalents.

#[pyclass(name = "State")]
#[derive(Debug, Clone)]
pub struct PyState {
    data: State,
}

#[pyproto]
impl PyObjectProtocol for PyState {
    fn __repr__(&self) -> String {
        format!("<State {:?}>", self.data)
    }
}

#[pymethods]
impl PyState {
    #[staticmethod]
    pub fn new_mixed(n_qubits: usize) -> Self {
        Self {
            data: State::new_mixed(n_qubits),
        }
    }

    #[staticmethod]
    pub fn new_stabilizer(n_qubits: usize) -> Self {
        Self {
            data: State::new_stabilizer(n_qubits),
        }
    }
}

#[pyclass(name = "Process")]
#[derive(Debug)]
pub struct PyProcess {
    data: Process,
}

#[pyproto]
impl PyObjectProtocol for PyProcess {
    fn __repr__(&self) -> String {
        format!("<Process {:?}>", self.data)
    }
}

#[pymethods]
impl PyProcess {
    #[staticmethod]
    pub fn new_pauli_channel(data: Vec<(f64, Vec<Pauli>)>) -> Self {
        PyProcess {
            data: Process::new_pauli_channel(data),
        }
    }

    pub fn as_json(&self) -> String {
        self.data.as_json()
    }

    pub fn apply(&self, state: PyState) -> PyResult<PyState> {
        let data = self
            .data
            .apply(&state.data)
            .map_err(|e| PyErr::new::<PyRuntimeError, String>(e))?;
        Ok(PyState { data })
    }

    pub fn apply_to(&self, idx_qubits: Vec<usize>, state: PyState) -> PyResult<PyState> {
        let data = self
            .data
            .apply_to(idx_qubits.as_slice(), &state.data)
            .map_err(|e| PyErr::new::<PyRuntimeError, String>(e))?;
        Ok(PyState { data })
    }
}

#[pyclass(name = "Instrument")]
#[derive(Debug)]
pub struct PyInstrument {
    data: Instrument,
}

#[pyproto]
impl PyObjectProtocol for PyInstrument {
    fn __repr__(&self) -> String {
        format!("<Instrument {:?}>", self.data)
    }
}

#[pymethods]
impl PyInstrument {
    pub fn sample(&self, idx_qubits: Vec<usize>, state: &PyState) -> (usize, PyState) {
        let (result, data) = self.data.sample(idx_qubits.as_slice(), &state.data);
        (result, PyState { data })
    }

    #[staticmethod]
    #[args(pr_readout_error = "0.0")]
    pub fn new_z_measurement(pr_readout_error: f64) -> PyInstrument {
        PyInstrument {
            data: Instrument::ZMeasurement { pr_readout_error },
        }
    }

    pub fn as_json(&self) -> String {
        self.data.as_json()
    }
}

#[pyclass(name = "NoiseModel")]
#[derive(Debug)]
pub struct PyNoiseModel {
    data: NoiseModel,
}

#[pymethods]
impl PyNoiseModel {
    #[staticmethod]
    pub fn ideal() -> PyNoiseModel {
        PyNoiseModel {
            data: NoiseModel::ideal(),
        }
    }

    pub fn as_json(&self) -> String {
        self.data.as_json()
    }
}

// See https://stackoverflow.com/q/67412827/267841 for why the following works
// to expose Pauli. If we have more enums like this, we could likewise expose
// them by using the macro from that SO question.
//
// We got through some extra hoops to make sure everything user-facing appears
// as a value of the Pauli enum on the Python side.
impl IntoPy<PyObject> for Pauli {
    fn into_py(self, py: Python) -> PyObject {
        // Import the root module containing this native extension, and find
        // the enum definition there that we can call.
        let root = PyModule::import(py, "qdk_sim").unwrap();
        let py_enum = root.get("Pauli").unwrap();
        let args = ((self as u8).into_py(py),);
        py_enum.call1(args).unwrap().into_py(py)
    }
}

impl FromPyObject<'_> for Pauli {
    fn extract(ob: &'_ PyAny) -> PyResult<Self> {
        // We want to support either a primitive type that can extract to u8,
        // or a value of type qdk_sim.Pauli from the root module.
        Python::with_gil(|py| {
            let root = PyModule::import(py, "qdk_sim").unwrap();
            let py_enum: &PyType = root.get("Pauli").unwrap().downcast().unwrap();
            let value: u8 = match py_enum.is_instance(ob) {
                Ok(true) => ob.getattr("value")?,
                _ => ob,
            }
            .extract()?;
            let value = Pauli::try_from(value)
                .map_err(|e| PyErr::new::<PyRuntimeError, String>(format!("{:?}", e)))?;
            Ok(value)
        })
    }
}
