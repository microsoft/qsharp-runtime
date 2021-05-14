// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

//! Exposes a C API for this crate, useful for embedding into simulation
//! runtimes.
//!
//! # Safety
//! As this is a foreign-function interface, many of the functions exposed here
//! are unsafe, representing that the caller is required to ensure that safety
//! conditions in the host language are upheld.
//!
//! Please pay attention to any listed safety notes when calling into this C
//! API.

use crate::{NoiseModel, Process, State, built_info};
use lazy_static::lazy_static;
use serde_json::json;
use std::collections::HashMap;
use std::ffi::CStr;
use std::ffi::CString;
use std::os::raw::c_char;
use std::ptr;
use std::sync::Mutex;

struct CApiState {
    register_state: State,
    noise_model: NoiseModel,
}

lazy_static! {
    static ref STATE: Mutex<HashMap<usize, CApiState>> = Mutex::new(HashMap::new());
    static ref LAST_ERROR: Mutex<Option<String>> = Mutex::new(None);
}

// UTILITY FUNCTIONS //

/// Exposes a result to C callers by setting LAST_ERROR in the Error
/// case, and generating an appropriate error code.
fn as_capi_err(result: Result<(), String>) -> i64 {
    match result {
        Ok(_) => 0,
        Err(msg) => {
            *LAST_ERROR.lock().unwrap() = Some(msg);
            -1
        }
    }
}

fn apply<F: Fn(&NoiseModel) -> &Process>(
    sim_id: usize,
    idxs: &[usize],
    channel_fn: F,
) -> Result<(), String> {
    let state = &mut *STATE.lock().unwrap();
    if let Some(sim_state) = state.get_mut(&sim_id) {
        let channel = channel_fn(&sim_state.noise_model);
        match channel.apply_to(idxs, &sim_state.register_state) {
            Ok(new_state) => {
                sim_state.register_state = new_state;
                Ok(())
            }
            Err(err) => Err(err),
        }
    } else {
        return Err(format!("No simulator with id {}.", sim_id));
    }
}

// C API FUNCTIONS //

/// Returns information about how this simulator was built, serialized as a
/// JSON object.
#[no_mangle]
pub extern "C" fn get_simulator_info() -> *const c_char {
    let build_info = json!({
        "name": "Microsoft.Quantum.Experimental.Simulators",
        "version": built_info::PKG_VERSION,
        "opt_level": built_info::OPT_LEVEL,
        "features": built_info::FEATURES,
        "target": built_info::TARGET
    });
    CString::new(serde_json::to_string(&build_info).unwrap().as_str())
        .unwrap()
        .into_raw()
}

/// Returns the last error message raised by a call to a C function.
/// If no error message has been raised, returns a null pointer.
#[no_mangle]
pub extern "C" fn lasterr() -> *const c_char {
    match &*LAST_ERROR.lock().unwrap() {
        None => ptr::null(),
        Some(msg) => CString::new(msg.as_str()).unwrap().into_raw(),
    }
}

/// Allocate a new simulator with a given capacity, measured in the number of
/// qubits supported by that simulator. Returns an id that can be used to refer
/// to the new simulator in future function calls.
#[no_mangle]
pub extern "C" fn init(initial_capacity: usize) -> usize {
    let state = &mut *STATE.lock().unwrap();
    let id = 1 + state.keys().fold(std::usize::MIN, |a, b| a.max(*b));
    state.insert(
        id,
        CApiState {
            register_state: State::new_mixed(initial_capacity),
            noise_model: NoiseModel::ideal(),
        },
    );
    id
}

/// Deallocates the simulator with the given id, releasing any resources owned
/// by that simulator.
#[no_mangle]
pub extern "C" fn destroy(sim_id: usize) -> i64 {
    as_capi_err({
        let state = &mut *STATE.lock().unwrap();
        if state.contains_key(&sim_id) {
            state.remove(&sim_id);
            Ok(())
        } else {
            Err(format!("No simulator with id {} exists.", sim_id))
        }
    })
}

// TODO[code quality]: refactor the following several functions into a macro.

/// Applies the `X` operation acting on a given qubit to a given simulator,
/// using the currently set noise model.
#[no_mangle]
pub extern "C" fn x(sim_id: usize, idx: usize) -> i64 {
    as_capi_err(apply(sim_id, &[idx], |model| &model.x))
}

/// Applies the `Y` operation acting on a given qubit to a given simulator,
/// using the currently set noise model.
#[no_mangle]
pub extern "C" fn y(sim_id: usize, idx: usize) -> i64 {
    as_capi_err(apply(sim_id, &[idx], |model| &model.y))
}

/// Applies the `Z` operation acting on a given qubit to a given simulator,
/// using the currently set noise model.
#[no_mangle]
pub extern "C" fn z(sim_id: usize, idx: usize) -> i64 {
    as_capi_err(apply(sim_id, &[idx], |model| &model.z))
}

/// Applies the `H` operation acting on a given qubit to a given simulator,
/// using the currently set noise model.
#[no_mangle]
pub extern "C" fn h(sim_id: usize, idx: usize) -> i64 {
    as_capi_err(apply(sim_id, &[idx], |model| &model.h))
}

/// Applies the `S` operation acting on a given qubit to a given simulator,
/// using the currently set noise model.
#[no_mangle]
pub fn s(sim_id: usize, idx: usize) -> i64 {
    as_capi_err(apply(sim_id, &[idx], |model| &model.s))
}

/// Applies the `Adjoint S` operation acting on a given qubit to a given
/// simulator, using the currently set noise model.
#[no_mangle]
pub fn s_adj(sim_id: usize, idx: usize) -> i64 {
    as_capi_err(apply(sim_id, &[idx], |model| &model.s_adj))
}

/// Applies the `T` operation acting on a given qubit to a given simulator,
/// using the currently set noise model.
#[no_mangle]
pub fn t(sim_id: usize, idx: usize) -> i64 {
    as_capi_err(apply(sim_id, &[idx], |model| &model.t))
}

/// Applies the `Adjoint T` operation acting on a given qubit to a given simulator,
/// using the currently set noise model.
#[no_mangle]
pub fn t_adj(sim_id: usize, idx: usize) -> i64 {
    as_capi_err(apply(sim_id, &[idx], |model| &model.t_adj))
}

/// Applies the `CNOT` operation acting on two given qubits to a given simulator,
/// using the currently set noise model.
#[no_mangle]
pub fn cnot(sim_id: usize, idx_control: usize, idx_target: usize) -> i64 {
    as_capi_err(apply(sim_id, &[idx_control, idx_target], |model| {
        &model.cnot
    }))
}

/// Measures a single qubit in the $Z$-basis, returning the result by setting
/// the value at a given pointer.
///
/// # Safety
/// This function is marked as unsafe as it is the caller's responsibility to
/// ensure that `result_out` is a valid pointer, and that the memory referenced
/// by `result_out` can be safely set.
#[no_mangle]
pub unsafe extern "C" fn m(sim_id: usize, idx: usize, result_out: *mut usize) -> i64 {
    as_capi_err({
        let state = &mut *STATE.lock().unwrap();
        if let Some(sim_state) = state.get_mut(&sim_id) {
            let instrument = &sim_state.noise_model.z_meas;
            let (result, new_state) = instrument.sample(&[idx], &sim_state.register_state);
            sim_state.register_state = new_state;
            *result_out = result;
            Ok(())
        } else {
            Err(format!("No simulator with id {} exists.", sim_id))
        }
    })
}

#[no_mangle]
pub extern "C" fn get_noise_model(sim_id: usize) -> *const c_char {
    let state = &*STATE.lock().unwrap();
    if let Some(sim_state) = state.get(&sim_id) {
        CString::new(
            serde_json::to_string(&sim_state.noise_model)
                .unwrap()
                .as_str(),
        )
        .unwrap()
        .into_raw()
    } else {
        ptr::null()
    }
}

/// Returns a JSON serialization of the ideal noise model (i.e.: a noise model
/// that agrees with closed-system simulation).
#[no_mangle]
pub extern "C" fn ideal_noise_model() -> *const c_char {
    CString::new(
        serde_json::to_string(&NoiseModel::ideal())
            .unwrap()
            .as_str(),
    )
    .unwrap()
    .into_raw()
}

/// Sets the noise model used by a given simulator instance, given a string
/// containing a JSON serialization of that noise model.
///
/// # Safety
/// This function is marked as unsafe as the caller is responsible for ensuring
/// that `new_model`:
///
/// - Is a valid pointer to a null-terminated array of C
///   characters.
/// - The pointer remains valid for at least the duration
///   of the call.
/// - No other thread may modify the memory referenced by `new_model` for at
///   least the duration of the call.
#[no_mangle]
pub unsafe extern "C" fn set_noise_model(sim_id: usize, new_model: *const c_char) -> i64 {
    if new_model.is_null() {
        return as_capi_err(Err("set_noise_model called with null pointer".to_string()));
    }

    let c_str = CStr::from_ptr(new_model);

    as_capi_err(match c_str.to_str() {
        Ok(serialized_noise_model) => match serde_json::from_str(serialized_noise_model) {
            Ok(noise_model) => {
                let state = &mut *STATE.lock().unwrap();
                if let Some(sim_state) = state.get_mut(&sim_id) {
                    sim_state.noise_model = noise_model;
                    Ok(())
                } else {
                    Err(format!("No simulator with id {} exists.", sim_id))
                }
            }
            Err(serialization_error) => Err(format!(
                "{} error deserializing noise model at line {}, column {}.",
                match serialization_error.classify() {
                    serde_json::error::Category::Data => "Data / schema",
                    serde_json::error::Category::Eof => "End-of-file",
                    serde_json::error::Category::Io => "I/O",
                    serde_json::error::Category::Syntax => "Syntax",
                },
                serialization_error.line(),
                serialization_error.column()
            )),
        },
        Err(msg) => Err(format!(
            "UTF-8 error decoding serialized noise model; was valid until byte {}.",
            msg.valid_up_to()
        )),
    })
}

/// Returns the state of a given simulator, serialized as a JSON object.
#[no_mangle]
pub extern "C" fn get_current_state(sim_id: usize) -> *const c_char {
    let state = &mut *STATE.lock().unwrap();
    if let Some(sim_state) = state.get_mut(&sim_id) {
        CString::new(
            serde_json::to_string(&sim_state.register_state)
                .unwrap()
                .as_str(),
        )
        .unwrap()
        // NB: into_raw implies transferring ownership to the C caller,
        //     and hence moves its self.
        .into_raw()
    } else {
        ptr::null()
    }
}
