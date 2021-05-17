// use crate::tableau::Tableau;
use crate::built_info;
use serde_json::json;
use pyo3::{
    prelude::*,
};

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

    // m.add_class::<Tableau>()?;
    Ok(())
}
