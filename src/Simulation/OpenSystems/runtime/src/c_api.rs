use std::ffi::CStr;
use std::ffi::CString;
use std::os::raw::c_char;
use std::ptr;
use crate::{ Channel, NoiseModel, State };
use lazy_static::lazy_static;
use std::sync::Mutex;
use std::collections::HashMap;

const DEFAULT_CAPACITY: usize = 1;

struct CApiState {
    register_state: State,
    noise_model: NoiseModel
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

fn apply<F: Fn(&NoiseModel) -> &Channel>(sim_id: usize, idxs: &[usize], channel_fn: F) -> Result<(), String> {
    let state = &mut *STATE.lock().unwrap();
    if let Some(sim_state) = state.get_mut(&sim_id) {
        let channel = channel_fn(&sim_state.noise_model);
        match channel.apply_to(idxs, &sim_state.register_state) {
            Ok(new_state) => {
                sim_state.register_state = new_state;
                Ok(())
            },
            Err(err) => Err(err)
        }
    } else {
        return Err(format!("No simulator with id {}.", sim_id).to_string());
    }
}

// C API FUNCTIONS //

#[no_mangle]
pub extern fn init(initial_capacity: usize) -> usize {
    let state = &mut *STATE.lock().unwrap();
    let id = 1 + state.keys().fold(
        std::usize::MIN, |a, b| a.max(*b)
    );
    state.insert(
        id,
        CApiState {
            register_state: State::new_mixed(initial_capacity),
            noise_model: NoiseModel::ideal()
        }
    );
    id
}

#[no_mangle]
pub extern fn destroy(sim_id: usize) -> i64 {
    as_capi_err({
        let state = &mut *STATE.lock().unwrap();
        if state.contains_key(&sim_id) {
            state.remove(&sim_id);
            Ok(())
        } else {
            Err(format!("No simulator with id {} exists.", sim_id).to_string())
        }
    })
}

#[no_mangle]
pub extern fn dump_to_console(sim_id: usize) -> () {
    // FIXME: implement this
}

#[no_mangle]
pub extern fn x(sim_id: usize, idx: usize) -> i64 {
    as_capi_err(apply(sim_id, &[idx], |model| &model.x))
}

#[no_mangle]
pub extern fn y(sim_id: usize, idx: usize) -> i64 {
    as_capi_err(apply(sim_id, &[idx], |model| &model.y))}

#[no_mangle]
pub extern fn z(sim_id: usize, idx: usize) -> i64 {
    as_capi_err(apply(sim_id, &[idx], |model| &model.z))
}

#[no_mangle]
pub extern fn h(sim_id: usize, idx: usize) -> i64 {
    as_capi_err(apply(sim_id, &[idx], |model| &model.h))
}

#[no_mangle]
pub fn s(sim_id: usize, idx: usize) -> i64 {
    as_capi_err(apply(sim_id, &[idx], |model| &model.s))
}

#[no_mangle]
pub fn s_adj(sim_id: usize, idx: usize) -> i64 {
    as_capi_err(apply(sim_id, &[idx], |model| &model.s_adj))
}

#[no_mangle]
pub fn t(sim_id: usize, idx: usize) -> i64 {
    as_capi_err(apply(sim_id, &[idx], |model| &model.t))
}

#[no_mangle]
pub fn t_adj(sim_id: usize, idx: usize) -> i64 {
    as_capi_err(apply(sim_id, &[idx], |model| &model.t_adj))
}

#[no_mangle]
pub fn cnot(sim_id: usize, idx_control: usize, idx_target: usize) -> i64 {
    as_capi_err(apply(sim_id, &[idx_control, idx_target], |model| &model.cnot))
}

#[no_mangle]
pub extern fn m(sim_id: usize, idx: usize, result_out: *mut usize) -> i64 {
    as_capi_err({
        let state = &mut *STATE.lock().unwrap();
        if let Some(sim_state) = state.get_mut(&sim_id) {
            let instrument = &sim_state.noise_model.z_meas;
            let (result, new_state) = instrument.sample(&[idx], &sim_state.register_state);
            sim_state.register_state = new_state;
            unsafe {
                *result_out = result;
            };
            Ok(())
        } else {
            Err(format!("No simulator with id {} exists.", sim_id).to_string())
        }
    })
}


#[no_mangle]
pub extern fn lasterr() -> *const c_char {
    match &*LAST_ERROR.lock().unwrap() {
        None => ptr::null(),
        Some(msg) => {
            let wrapped_msg = CString::new(msg.as_str()).unwrap().into_raw();
            std::mem::forget(wrapped_msg);
            wrapped_msg
        }
    }
}

#[no_mangle]
pub extern fn get_noise_model(sim_id: usize) -> *const c_char {
    let state = &*STATE.lock().unwrap();
    if let Some(sim_state) = state.get(&sim_id) {
        let serialized = CString::new(
            serde_json::to_string(&sim_state.noise_model).unwrap().as_str()
        ).unwrap().into_raw();
        // Need to forget that we hold this reference so that it doesn't
        // get released after returning to C.
        std::mem::forget(serialized);
        serialized
    } else {
        ptr::null()
    }
}

#[no_mangle]
pub extern fn set_noise_model(sim_id: usize, new_model: *const c_char) -> i64 {
    if new_model.is_null() {
        return as_capi_err(Err("set_noise_model called with null pointer".to_string()));
    }

    let c_str = unsafe {
        CStr::from_ptr(new_model)
    };

    as_capi_err(
        match c_str.to_str() {
            Ok(serialized_noise_model) => {
                match serde_json::from_str(serialized_noise_model) {
                    Ok(noise_model) => {
                        let state = &mut *STATE.lock().unwrap();
                        if let Some(sim_state) = state.get_mut(&sim_id) {
                            sim_state.noise_model = noise_model;
                            Ok(())
                        } else {
                            Err(format!("No simulator with id {} exists.", sim_id).to_string())
                        }
                    },
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
                    ))
                }
            },
            Err(msg) => Err(
                format!(
                    "UTF-8 error decoding serialized noise model; was valid until byte {}.",
                    msg.valid_up_to()
                )
            )
        }
    )
}

#[no_mangle]
pub extern fn get_current_state(sim_id: usize) -> *const c_char {
    let state = &mut *STATE.lock().unwrap();
    if let Some(sim_state) = state.get_mut(&sim_id) {
        let serialized = CString::new(
            serde_json::to_string(&sim_state.register_state).unwrap().as_str()
        ).unwrap().into_raw();
        std::mem::forget(serialized);
        serialized
    } else {
        ptr::null()
    }
}