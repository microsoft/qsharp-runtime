// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#![cfg_attr(all(), doc = include_str!("../docs/c-api.md"))]

use crate::error::{QdkSimError, QdkSimError::*};
use crate::{built_info, GeneratorCoset, NoiseModel, Process, State};
use cfg_if::cfg_if;
use lazy_static::lazy_static;
use serde_json::json;
use std::collections::HashMap;
use std::error::Error;
use std::ffi::CStr;
use std::ffi::CString;
use std::os::raw::c_char;
use std::sync::Mutex;
use std::{panic, ptr};

struct CApiState {
    register_state: State,
    noise_model: NoiseModel,
}

lazy_static! {
    static ref STATE: Mutex<HashMap<usize, CApiState>> = Mutex::new(HashMap::new());
    static ref LAST_ERROR: Mutex<Option<String>> = Mutex::new(None);
    static ref BACKTRACE: Mutex<Option<String>> = Mutex::new(None);
}

// UTILITY FUNCTIONS //

/// Exposes a result to C callers by setting LAST_ERROR in the Error
/// case, and generating an appropriate error code.
fn as_capi_err<F: FnOnce() -> Result<(), QdkSimError> + panic::UnwindSafe>(result_fn: F) -> i64 {
    let result = panic::catch_unwind(result_fn);
    match result {
        Ok(Ok(_)) => 0,
        Err(panic_err) => {
            *LAST_ERROR.lock().unwrap() = Some(format!("Panic internal to C API: {:?}", panic_err));
            -1
        }
        Ok(Err(api_err)) => {
            *LAST_ERROR.lock().unwrap() = Some(api_err.to_string());
            if let Ok(mut guard) = BACKTRACE.lock() {
                *guard = api_err.backtrace().map(|bt| bt.to_string())
            }
            -1
        }
    }
}

fn with_api_state<T, F: FnOnce(&mut CApiState) -> Result<T, QdkSimError>>(
    sim_id: usize,
    action: F,
) -> Result<T, QdkSimError> {
    let state = &mut *STATE.lock().unwrap();
    if let Some(sim_state) = state.get_mut(&sim_id) {
        action(sim_state)
    } else {
        Err(NoSuchSimulator {
            invalid_id: sim_id,
            expected: state.keys().into_iter().cloned().collect(),
        })
    }
}

fn apply<F: Fn(&NoiseModel) -> Result<&Process, QdkSimError>>(
    sim_id: usize,
    idxs: &[usize],
    channel_fn: F,
) -> Result<(), QdkSimError> {
    with_api_state(sim_id, |sim_state| {
        let channel = channel_fn(&sim_state.noise_model)?;
        let new_state = channel.apply_to(idxs, &sim_state.register_state)?;
        sim_state.register_state = new_state;
        Ok(())
    })
}

fn apply_continuous<F: Fn(&NoiseModel) -> Result<&GeneratorCoset, QdkSimError>>(
    sim_id: usize,
    idxs: &[usize],
    theta: f64,
    channel_fn: F,
) -> Result<(), QdkSimError> {
    with_api_state(sim_id, |sim_state| {
        let channel = channel_fn(&sim_state.noise_model)?;
        let new_state = channel
            .at(theta)?
            .apply_to(idxs, &sim_state.register_state)?;
        sim_state.register_state = new_state;
        Ok(())
    })
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

#[no_mangle]
pub extern "C" fn lastbacktrace() -> *const c_char {
    match &*BACKTRACE.lock().unwrap() {
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
///   a density operator.
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
            return Err(NullPointer("representation".to_string()));
        }
        let representation =
            CStr::from_ptr(representation)
                .to_str()
                .map_err(|e| InvalidUtf8InArgument {
                    arg_name: "representation".to_string(),
                    source: e,
                })?;

        let state = &mut *STATE.lock().unwrap();
        let id = 1 + state.keys().fold(std::usize::MIN, |a, b| a.max(*b));
        state.insert(
            id,
            CApiState {
                register_state: match representation {
                    "mixed" => State::new_mixed(initial_capacity),
                    "pure" => State::new_pure(initial_capacity),
                    "stabilizer" => State::new_stabilizer(initial_capacity),
                    _ => return Err(InvalidRepresentation(representation.to_string())),
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
            Err(NoSuchSimulator {
                invalid_id: sim_id,
                expected: state.keys().into_iter().cloned().collect(),
            })
        }
    })
}

macro_rules! declare_single_qubit_gate {
    (
        $(#[$meta:meta])*
        $gate_name:ident
    ) => {
        $(#[$meta])*
        #[no_mangle]
        pub fn $gate_name(sim_id: usize, idx: usize) -> i64 {
            cfg_if! {
                if #[cfg(feature = "trace_c_api")] {
                    println!("[c_api trace] {}({}, {})", stringify!($gate_name), sim_id, idx);
                }
            }
            as_capi_err(|| apply(sim_id, &[idx], |model| Ok(&model.$gate_name)))
        }
    };
}

macro_rules! declare_continuous_gate {
    (
        $(#[$meta:meta])*
        $gate_name:ident
    ) => {
        $(#[$meta])*
        #[no_mangle]
        pub fn $gate_name(sim_id: usize, theta: f64, idx: usize) -> i64 {
            cfg_if! {
                if #[cfg(feature = "trace_c_api")] {
                    println!("[c_api trace] {}({}, {}, {})", stringify!($gate_name), sim_id, theta, idx);
                }
            }
            as_capi_err(|| {
                apply_continuous(sim_id, &[idx], theta, |model| {
                    Ok(&model.$gate_name)
                })
            })
        }
    };
}

declare_single_qubit_gate!(
    /// Applies the `X` operation acting on a given qubit to a given simulator,
    /// using the currently set noise model.
    x
);

declare_single_qubit_gate!(
    /// Applies the `Y` operation acting on a given qubit to a given simulator,
    /// using the currently set noise model.
    y
);

declare_single_qubit_gate!(
    /// Applies the `Z` operation acting on a given qubit to a given simulator,
    /// using the currently set noise model.
    z
);

declare_single_qubit_gate!(
    /// Applies the `H` operation acting on a given qubit to a given simulator,
    /// using the currently set noise model.
    h
);

declare_single_qubit_gate!(
    /// Applies the `S` operation acting on a given qubit to a given simulator,
    /// using the currently set noise model.
    s
);

declare_single_qubit_gate!(
    /// Applies the `Adjoint S` operation acting on a given qubit to a given
    /// simulator, using the currently set noise model.
    s_adj
);

declare_single_qubit_gate!(
    /// Applies the `T` operation acting on a given qubit to a given simulator,
    /// using the currently set noise model.
    t
);

declare_single_qubit_gate!(
    /// Applies the `Adjoint T` operation acting on a given qubit to a given simulator,
    /// using the currently set noise model.
    t_adj
);

/// Applies the `CNOT` operation acting on two given qubits to a given simulator,
/// using the currently set noise model.
#[no_mangle]
pub extern "C" fn cnot(sim_id: usize, idx_control: usize, idx_target: usize) -> i64 {
    cfg_if! {
        if #[cfg(feature = "trace_c_api")] {
            println!("[c_api trace] cnot({}, {}, {})", sim_id, idx_control, idx_target);
        }
    }
    as_capi_err(|| apply(sim_id, &[idx_control, idx_target], |model| Ok(&model.cnot)))
}

declare_continuous_gate!(
    /// Applies the `Rx` operation acting on two given qubits to a given simulator,
    /// using the currently set noise model.
    rx
);
declare_continuous_gate!(
    /// Applies the `Ry` operation acting on two given qubits to a given simulator,
    /// using the currently set noise model.
    ry
);
declare_continuous_gate!(
    /// Applies the `Rz` operation acting on two given qubits to a given simulator,
    /// using the currently set noise model.
    rz
);

/// Measures a single qubit in the $Z$-basis, returning the result by setting
/// the value at a given pointer.
///
/// # Safety
/// This function is marked as unsafe as it is the caller's responsibility to
/// ensure that `result_out` is a valid pointer, and that the memory referenced
/// by `result_out` can be safely set.
#[no_mangle]
pub unsafe extern "C" fn m(sim_id: usize, idx: usize, result_out: *mut usize) -> i64 {
    cfg_if! {
        if #[cfg(feature = "trace_c_api")] {
            println!("[c_api trace] m({}, {})", sim_id, idx);
        }
    }
    as_capi_err(|| {
        let state = &mut *STATE.lock().unwrap();
        if let Some(sim_state) = state.get_mut(&sim_id) {
            let instrument = &sim_state.noise_model.z_meas;
            let (result, new_state) = instrument.sample(&[idx], &sim_state.register_state);
            sim_state.register_state = new_state;
            *result_out = result;
            Ok(())
        } else {
            Err(NoSuchSimulator {
                invalid_id: sim_id,
                expected: state.keys().into_iter().cloned().collect(),
            })
        }
    })
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
            .map_err(|e| InvalidUtf8InArgument {
                arg_name: "name".to_string(),
                source: e,
            })?;
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
        let state = STATE
            .lock()
            .map_err(|_| {
                // Note that as per https://github.com/dtolnay/anyhow/issues/81#issuecomment-609247231,
                // common practice is for poison errors to indicate that the containing thread
                // has been irrevocably corrupted and must panic.
                panic!("The lock on shared state for the C API has been poisoned.");
            })
            .unwrap();
        if let Some(sim_state) = state.get(&sim_id) {
            let c_str = CString::new(sim_state.noise_model.as_json().as_str())
                .map_err(|e| UnanticipatedCApiError(anyhow::Error::new(e)))?;
            unsafe {
                *noise_model_json = c_str.into_raw();
            };
            Ok(())
        } else {
            Err(NoSuchSimulator {
                invalid_id: sim_id,
                expected: state.keys().into_iter().cloned().collect(),
            })
        }
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
            return Err(NullPointer("new_model".to_string()));
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
                        Err(NoSuchSimulator {
                            invalid_id: sim_id,
                            expected: state.keys().into_iter().cloned().collect(),
                        })
                    }
                }
                Err(err) => Err(JsonDeserializationError(err)),
            },
            Err(msg) => Err(InvalidUtf8InArgument {
                arg_name: "new_model".to_string(),
                source: msg,
            }),
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
            return Err(NullPointer("name".to_string()));
        }

        let name = CStr::from_ptr(name)
            .to_str()
            .map_err(|e| InvalidUtf8InArgument {
                arg_name: "name".to_string(),
                source: e,
            })?;
        let noise_model = NoiseModel::get_by_name(name)?;
        let state = &mut *STATE.lock().unwrap();
        if let Some(sim_state) = state.get_mut(&sim_id) {
            sim_state.noise_model = noise_model;
            Ok(())
        } else {
            Err(NoSuchSimulator {
                invalid_id: sim_id,
                expected: state.keys().into_iter().cloned().collect(),
            })
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

#[cfg(test)]
mod tests {
    use std::ffi::CString;

    use backtrace::Backtrace;

    use crate::c_api::{self, LAST_ERROR};

    fn as_result(c_api_code: i64) -> Result<(), (String, i64)> {
        if c_api_code == 0 {
            Ok(())
        } else {
            let msg = LAST_ERROR
                .lock()
                .ok()
                .map(|l| l.as_ref().map(|s| s.to_owned()).unwrap_or_default())
                .unwrap_or_default();
            let backtrace = Backtrace::new();
            println!("C API error during tests: {}\n{:?}", msg, backtrace);
            let err = unsafe { c_api::lasterr().as_ref() }.unwrap().to_string();
            Err((err, c_api_code))
        }
    }

    #[test]
    fn ry_runs_without_error_or_panic() -> Result<(), (String, i64)> {
        unsafe {
            let mut sim_id: usize = 0;
            let mixed = CString::new("mixed").unwrap();
            as_result(c_api::init(3, mixed.as_ptr(), &mut sim_id))?;
            as_result(c_api::ry(sim_id, 1.234, 1))?;
            as_result(c_api::destroy(sim_id))?;
            Ok(())
        }
    }

    #[test]
    fn teleport() -> Result<(), (String, i64)> {
        unsafe {
            let mut sim_id: usize = 0;
            let mixed = CString::new("mixed").unwrap();
            let ideal = CString::new("ideal").unwrap();
            as_result(c_api::init(3, mixed.as_ptr(), &mut sim_id))?;
            as_result(c_api::set_noise_model_by_name(sim_id, ideal.as_ptr()))?;

            let idx_msg = 0;
            let idx_here = 1;
            let idx_there = 2;

            // Prepare Bell pair.
            as_result(c_api::h(sim_id, idx_here))?;
            as_result(c_api::cnot(sim_id, idx_here, idx_there))?;

            // Prepare state to be teleported.
            as_result(c_api::h(sim_id, idx_msg))?;
            as_result(c_api::rz(sim_id, 1.1, idx_msg))?;

            // Perform the actual teleportation.
            as_result(c_api::cnot(sim_id, idx_msg, idx_here))?;
            as_result(c_api::h(sim_id, idx_msg))?;

            // Perform correction steps.
            let mut corr_x = 0;
            as_result(c_api::m(sim_id, idx_here, &mut corr_x))?;
            let mut corr_z = 0;
            as_result(c_api::m(sim_id, idx_msg, &mut corr_z))?;

            if corr_x == 1 {
                as_result(c_api::x(sim_id, idx_there))?;
            }
            if corr_z == 1 {
                as_result(c_api::z(sim_id, idx_there))?;
            }

            // Unprepare message state.
            as_result(c_api::rz(sim_id, -1.1, idx_there))?;
            as_result(c_api::h(sim_id, idx_there))?;

            // Make sure we get zero.
            let mut result = 0;
            as_result(c_api::m(sim_id, idx_there, &mut result))?;
            assert_eq!(result, 0, "Unexpected result from teleportation.");

            as_result(c_api::destroy(sim_id))?;
            Ok(())
        }
    }
}
