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

use crate::{built_info, NoiseModel, Process, State};
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
fn as_capi_err<F: FnOnce() -> Result<(), String>>(result_fn: F) -> i64 {
    let result = result_fn();
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
///
/// The initial state of the new simulator is populated using the
/// representation nominated by the `representation` argument:
///
/// - **`pure`**: Creates the simulator with an initial state represented by
///   a state vector.
/// - **`mixed`**: Creates the simulator with an initial state represented by
///   a density operat.
/// - **`stabilizer`**: Creates the simulator with an initial state represented by
///   a stabilizer tableau.
///
/// # Safety
/// The caller is responsible for:
///
/// - Ensuring that `sim_id_out` points to valid
///   memory, and that the lifetime of this pointer extends at least for the
///   duration of this call.
/// - Ensuring that `representation` is a valid pointer to a null-terminated
///   string of Unicode characters, encoded as UTF-8.
#[no_mangle]
pub unsafe extern "C" fn init(
    initial_capacity: usize,
    representation: *const c_char,
    sim_id_out: *mut usize,
) -> i64 {
    as_capi_err(|| {
        if representation.is_null() {
            return Err("init called with null pointer for representation".to_string());
        }
        let representation = CStr::from_ptr(representation)
            .to_str()
            .map_err(|e| format!("UTF-8 error decoding representation argument: {}", e))?;

        let state = &mut *STATE.lock().unwrap();
        let id = 1 + state.keys().fold(std::usize::MIN, |a, b| a.max(*b));
        state.insert(
            id,
            CApiState {
                register_state: match representation {
                    "mixed" => State::new_mixed(initial_capacity),
                    "pure" => State::new_pure(initial_capacity),
                    "stabilizer" => State::new_stabilizer(initial_capacity),
                    _ => {
                        return Err(format!(
                            "Unknown initial state representation {}.",
                            representation
                        ))
                    }
                },
                noise_model: NoiseModel::ideal(),
            },
        );
        *sim_id_out = id;
        Ok(())
    })
}

/// Deallocates the simulator with the given id, releasing any resources owned
/// by that simulator.
#[no_mangle]
pub extern "C" fn destroy(sim_id: usize) -> i64 {
    as_capi_err(|| {
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
    as_capi_err(|| apply(sim_id, &[idx], |model| &model.x))
}

/// Applies the `Y` operation acting on a given qubit to a given simulator,
/// using the currently set noise model.
#[no_mangle]
pub extern "C" fn y(sim_id: usize, idx: usize) -> i64 {
    as_capi_err(|| apply(sim_id, &[idx], |model| &model.y))
}

/// Applies the `Z` operation acting on a given qubit to a given simulator,
/// using the currently set noise model.
#[no_mangle]
pub extern "C" fn z(sim_id: usize, idx: usize) -> i64 {
    as_capi_err(|| apply(sim_id, &[idx], |model| &model.z))
}

/// Applies the `H` operation acting on a given qubit to a given simulator,
/// using the currently set noise model.
#[no_mangle]
pub extern "C" fn h(sim_id: usize, idx: usize) -> i64 {
    as_capi_err(|| apply(sim_id, &[idx], |model| &model.h))
}

/// Applies the `S` operation acting on a given qubit to a given simulator,
/// using the currently set noise model.
#[no_mangle]
pub fn s(sim_id: usize, idx: usize) -> i64 {
    as_capi_err(|| apply(sim_id, &[idx], |model| &model.s))
}

/// Applies the `Adjoint S` operation acting on a given qubit to a given
/// simulator, using the currently set noise model.
#[no_mangle]
pub fn s_adj(sim_id: usize, idx: usize) -> i64 {
    as_capi_err(|| apply(sim_id, &[idx], |model| &model.s_adj))
}

/// Applies the `T` operation acting on a given qubit to a given simulator,
/// using the currently set noise model.
#[no_mangle]
pub fn t(sim_id: usize, idx: usize) -> i64 {
    as_capi_err(|| apply(sim_id, &[idx], |model| &model.t))
}

/// Applies the `Adjoint T` operation acting on a given qubit to a given simulator,
/// using the currently set noise model.
#[no_mangle]
pub fn t_adj(sim_id: usize, idx: usize) -> i64 {
    as_capi_err(|| apply(sim_id, &[idx], |model| &model.t_adj))
}

/// Applies the `CNOT` operation acting on two given qubits to a given simulator,
/// using the currently set noise model.
#[no_mangle]
pub fn cnot(sim_id: usize, idx_control: usize, idx_target: usize) -> i64 {
    as_capi_err(|| apply(sim_id, &[idx_control, idx_target], |model| &model.cnot))
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
    as_capi_err(|| {
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

impl NoiseModel {
    /// Private function to help look up common noise models by name.
    fn get_by_name(name: &str) -> Result<NoiseModel, String> {
        match name {
            "ideal" => Ok(NoiseModel::ideal()),
            "ideal_stabilizer" => Ok(NoiseModel::ideal_stabilizer()),
            _ => Err(format!("Unrecognized noise model name {}.", name)),
        }
    }
}

/// Gets the noise model corresponding to a particular name, serialized as a
/// string representing a JSON object.
///
/// Currently recognized names:
/// - `ideal`
/// - `ideal_stabilizer`
///
/// # Safety
/// As this is a C-language API, the Rust compiler cannot guarantee safety when
/// calling into this function. The caller is responsible for ensuring that:
///
/// - `name` is a pointer to a null-terminated string of Unicode characters,
///   encoded as UTF-8, and that the pointer remains valid for the lifetime of
///   this call.
/// - `noise_model_json` is a valid pointer whose lifetime extends for the
///    duration of this function call.
///
/// After this call completes, this function guarantees that either of the two
/// conditions below holds:
///
/// - The return value is negative, in which case calling `lasterr` will return
///   an actionable error message, or
/// - The return value is `0`, and `*noise_model_json` is a valid pointer to a
///   null-terminated string of Unicode characters, encoded as UTF-8. In this
///   case, the caller is considered to own the memory allocated for this
///   string.
#[no_mangle]
pub extern "C" fn get_noise_model_by_name(
    name: *const c_char,
    noise_model_json: *mut *const c_char,
) -> i64 {
    as_capi_err(|| {
        let name = unsafe { CStr::from_ptr(name) }
            .to_str()
            .map_err(|e| format!("UTF-8 error decoding representation argument: {}", e))?;
        let noise_model = NoiseModel::get_by_name(name)?;
        let noise_model = CString::new(noise_model.as_json()).unwrap();
        unsafe {
            *noise_model_json = noise_model.into_raw();
        }
        Ok(())
    })
}

/// Returns the currently configured noise model for a given simulator,
/// serialized as a string representing a JSON object.
///
/// # Safety
/// As this is a C-language API, the Rust compiler cannot guarantee safety when
/// calling into this function. The caller is responsible for ensuring that:
///
/// - `noise_model_json` is a valid pointer whose lifetime extends for the
///    duration of this function call.
///
/// After this call completes, this function guarantees that either of the two
/// conditions below holds:
///
/// - The return value is negative, in which case calling `lasterr` will return
///   an actionable error message, or
/// - The return value is `0`, and `*noise_model_json` is a valid pointer to a
///   null-terminated string of Unicode characters, encoded as UTF-8. In this
///   case, the caller is considered to own the memory allocated for this
///   string.
#[no_mangle]
pub extern "C" fn get_noise_model(sim_id: usize, noise_model_json: *mut *const c_char) -> i64 {
    as_capi_err(|| {
        let state = &*STATE
            .lock()
            .map_err(|e| format!("Lock poisoning error: {}", e))?;
        if let Some(sim_state) = state.get(&sim_id) {
            let c_str = CString::new(sim_state.noise_model.as_json().as_str()).map_err(|e| {
                format!("Null error while converting noise model to C string: {}", e)
            })?;
            unsafe {
                *noise_model_json = c_str.into_raw();
            }
        } else {
            return Err(format!("No simulator with id {} exists.", sim_id));
        }
        Ok(())
    })
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
    as_capi_err(|| {
        if new_model.is_null() {
            return Err("set_noise_model called with null pointer".to_string());
        }

        let c_str = CStr::from_ptr(new_model);
        match c_str.to_str() {
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
        }
    })
}

/// Sets the noise model used by a given simulator instance, given a string
/// containing the name of a built-in noise model.
///
/// # Safety
/// This function is marked as unsafe as the caller is responsible for ensuring
/// that `name`:
///
/// - Is a valid pointer to a null-terminated array of C
///   characters.
/// - The pointer remains valid for at least the duration
///   of the call.
/// - No other thread may modify the memory referenced by `new_model` for at
///   least the duration of the call.
#[no_mangle]
pub unsafe extern "C" fn set_noise_model_by_name(sim_id: usize, name: *const c_char) -> i64 {
    as_capi_err(|| {
        if name.is_null() {
            return Err("set_noise_model_by_name called with null pointer".to_string());
        }

        let name = CStr::from_ptr(name)
            .to_str()
            .map_err(|e| format!("UTF-8 error decoding name: {}", e))?;
        let noise_model = NoiseModel::get_by_name(name)?;
        let state = &mut *STATE.lock().unwrap();
        if let Some(sim_state) = state.get_mut(&sim_id) {
            sim_state.noise_model = noise_model;
            Ok(())
        } else {
            Err(format!("No simulator with id {} exists.", sim_id))
        }
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
