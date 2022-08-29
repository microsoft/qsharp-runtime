// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

//! Module defining QIR compliant APIs for quantum simulation.

mod common_matrices;
mod simulator;
mod sparsestate;

use bitvec::prelude::*;
use lazy_static::lazy_static;
use sparsestate::SparseStateQuantumSim;
use std::convert::TryInto;
use std::ffi::{c_void, CString};
use std::mem::size_of;
use std::os::raw::c_double;
use std::sync::atomic::{AtomicUsize, Ordering::Relaxed};
use std::sync::Mutex;

use super::{
    Pauli, __quantum__rt__fail,
    arrays::{
        __quantum__rt__array_create_1d, __quantum__rt__array_get_element_ptr_1d,
        __quantum__rt__array_get_size_1d, __quantum__rt__array_update_alias_count,
    },
    result_bool::{
        __quantum__rt__result_equal, __quantum__rt__result_get_one, __quantum__rt__result_get_zero,
    },
    strings::__quantum__rt__string_create,
    tuples::{__quantum__rt__tuple_create, __quantum__rt__tuple_update_reference_count},
};

lazy_static! {
    static ref SIM: Mutex<Option<SparseStateQuantumSim>> = Mutex::new(None);
    static ref RESULTS: Mutex<BitVec> = Mutex::new(bitvec![]);
    static ref MAX_QUBIT_ID: AtomicUsize = AtomicUsize::new(0);
}

fn ensure_sufficient_qubits(sim: &mut SparseStateQuantumSim, qubit_id: usize) {
    while qubit_id + 1 > (*MAX_QUBIT_ID).load(Relaxed) {
        let _ = sim.allocate();
        (*MAX_QUBIT_ID).fetch_add(1, Relaxed);
    }
}

#[allow(clippy::cast_ptr_alignment)]
unsafe fn map_paulis(
    sim: &mut SparseStateQuantumSim,
    paulis: *const (usize, Vec<u8>),
    qubits: *const (usize, Vec<u8>),
) -> Vec<(Pauli, usize)> {
    let paulis_size = __quantum__rt__array_get_size_1d(paulis);
    let qubits_size = __quantum__rt__array_get_size_1d(qubits);
    if paulis_size != qubits_size {
        __quantum__rt__fail(__quantum__rt__string_create(
            CString::new("Pauli array and Qubit array must be the same size.")
                .unwrap()
                .as_bytes_with_nul()
                .as_ptr() as *mut i8,
        ));
    }

    let combined_list: Vec<(Pauli, usize)> = (0..paulis_size)
        .filter_map(|index| {
            let p =
                *__quantum__rt__array_get_element_ptr_1d(paulis, index).cast::<Pauli>() as Pauli;
            let q = *__quantum__rt__array_get_element_ptr_1d(qubits, index as u64)
                .cast::<*mut c_void>() as usize;
            if let Pauli::I = p {
                None
            } else {
                ensure_sufficient_qubits(sim, q);
                Some((p, q))
            }
        })
        .collect();

    for (pauli, qubit) in &combined_list {
        match pauli {
            Pauli::X => sim.apply(&common_matrices::h(), &[*qubit], None),
            Pauli::Y => {
                sim.apply(&common_matrices::h(), &[*qubit], None);
                sim.apply(&common_matrices::s(), &[*qubit], None);
                sim.apply(&common_matrices::h(), &[*qubit], None);
            }
            _ => (),
        }
    }

    combined_list
}

fn unmap_paulis(sim: &mut SparseStateQuantumSim, combined_list: Vec<(Pauli, usize)>) {
    for (pauli, qubit) in combined_list {
        match pauli {
            Pauli::X => sim.apply(&common_matrices::h(), &[qubit], None),
            Pauli::Y => {
                sim.apply(&common_matrices::h(), &[qubit], None);
                sim.apply(
                    &common_matrices::adjoint(&common_matrices::s()),
                    &[qubit],
                    None,
                );
                sim.apply(&common_matrices::h(), &[qubit], None);
            }
            _ => (),
        }
    }
}

macro_rules! single_qubit_gate {
    ($(#[$meta:meta])*
    $qir_name:ident, $gate_matrix:expr) => {
        $(#[$meta])*
        #[no_mangle]
        pub extern "C" fn $qir_name(qubit: *mut c_void) {
            let mut sim_lock = SIM.lock().expect("Unable to lock global simulator state.");
            let mut sim = sim_lock
                .take()
                .map_or_else(SparseStateQuantumSim::new, |s| s);
            ensure_sufficient_qubits(&mut sim, qubit as usize);

            sim.apply(&$gate_matrix, &[qubit as usize], None);

            *sim_lock = Some(sim);
        }
    };
}

single_qubit_gate!(
    /// QIR API for performing the H gate on the given qubit.
    __quantum__qis__h__body,
    common_matrices::h()
);
single_qubit_gate!(
    /// QIR API for performing the S gate on the given qubit.
    __quantum__qis__s__body,
    common_matrices::s()
);
single_qubit_gate!(
    /// QIR API for performing the Adjoint S gate on the given qubit.
    __quantum__qis__s__adj,
    common_matrices::adjoint(&common_matrices::s())
);
single_qubit_gate!(
    /// QIR API for performing the T gate on the given qubit.
    __quantum__qis__t__body,
    common_matrices::t()
);
single_qubit_gate!(
    /// QIR API for performing the Adjoint T gate on the given qubit.
    __quantum__qis__t__adj,
    common_matrices::adjoint(&common_matrices::t())
);
single_qubit_gate!(
    /// QIR API for performing the X gate on the given qubit.
    __quantum__qis__x__body,
    common_matrices::x()
);
single_qubit_gate!(
    /// QIR API for performing the Y gate on the given qubit.
    __quantum__qis__y__body,
    common_matrices::y()
);
single_qubit_gate!(
    /// QIR API for performing the Z gate on the given qubit.
    __quantum__qis__z__body,
    common_matrices::z()
);

macro_rules! controlled_qubit_gate {
    ($(#[$meta:meta])*
    $qir_name:ident, $gate_matrix:expr, 1) => {
        $(#[$meta])*
        #[no_mangle]
        pub extern "C" fn $qir_name(control: *mut c_void, target: *mut c_void) {
            let mut sim_lock = SIM.lock().expect("Unable to lock global simulator state.");
            let mut sim = sim_lock
                .take()
                .map_or_else(SparseStateQuantumSim::new, |s| s);
            ensure_sufficient_qubits(&mut sim, target as usize);
            ensure_sufficient_qubits(&mut sim, control as usize);

            sim.apply(&$gate_matrix, &[target as usize], Some(&[control as usize]));

            *sim_lock = Some(sim);
        }
    };
    ($(#[$meta:meta])*
    $qir_name:ident, $gate_matrix:expr, 2) => {
        $(#[$meta])*
        #[no_mangle]
        pub extern "C" fn $qir_name(
            control_1: *mut c_void,
            control_2: *mut c_void,
            target: *mut c_void,
        ) {
            let mut sim_lock = SIM.lock().expect("Unable to lock global simulator state.");
            let mut sim = sim_lock
                .take()
                .map_or_else(SparseStateQuantumSim::new, |s| s);
            ensure_sufficient_qubits(&mut sim, target as usize);
            ensure_sufficient_qubits(&mut sim, control_1 as usize);
            ensure_sufficient_qubits(&mut sim, control_2 as usize);

            sim.apply(
                &$gate_matrix,
                &[target as usize],
                Some(&[control_1 as usize, control_2 as usize]),
            );

            *sim_lock = Some(sim);
        }
    };
}

controlled_qubit_gate!(
    /// QIR API for performing the CNOT gate with the given qubits.
    __quantum__qis__cnot__body,
    common_matrices::x(),
    1
);
controlled_qubit_gate!(
    /// QIR API for performing the CX gate with the given qubits.
    __quantum__qis__cx__body,
    common_matrices::x(),
    1
);
controlled_qubit_gate!(
    /// QIR API for performing the CCX gate with the given qubits.
    __quantum__qis__ccx__body,
    common_matrices::x(),
    2
);
controlled_qubit_gate!(
    /// QIR API for performing the CZ gate with the given qubits.
    __quantum__qis__cz__body,
    common_matrices::z(),
    1
);

macro_rules! single_qubit_rotation {
    ($(#[$meta:meta])*
    $qir_name:ident, $gate_matrix:expr) => {
        $(#[$meta])*
        #[no_mangle]
        pub extern "C" fn $qir_name(theta: c_double, qubit: *mut c_void) {
            let mut sim_lock = SIM.lock().expect("Unable to lock global simulator state.");
            let mut sim = sim_lock
                .take()
                .map_or_else(SparseStateQuantumSim::new, |s| s);
            ensure_sufficient_qubits(&mut sim, qubit as usize);

            sim.apply(&$gate_matrix(theta), &[qubit as usize], None);

            *sim_lock = Some(sim);
        }
    };
}

single_qubit_rotation!(
    /// QIR API for applying a global phase with the given angle and qubit.
    __quantum__qis__ri__body,
    common_matrices::g
);
single_qubit_rotation!(
    /// QIR API for applying a Pauli-X rotation with the given angle and qubit.
    __quantum__qis__rx__body,
    common_matrices::rx
);
single_qubit_rotation!(
    /// QIR API for applying a Pauli-Y rotation with the given angle and qubit.
    __quantum__qis__ry__body,
    common_matrices::ry
);
single_qubit_rotation!(
    /// QIR API for applying a Pauli-Z rotation with the given angle and qubit.
    __quantum__qis__rz__body,
    common_matrices::rz
);

macro_rules! multicontrolled_qubit_gate {
    ($(#[$meta:meta])*
    $qir_name:ident, $gate_matrix:expr) => {
        $(#[$meta])*
        /// # Safety
        ///
        /// This function should only be called with arrays and tuples created by the QIR runtime library.
        #[no_mangle]
        pub unsafe extern "C" fn $qir_name(ctls: *const (usize, Vec<u8>), qubit: *mut c_void) {
            let mut sim_lock = SIM.lock().expect("Unable to lock global simulator state.");
            let mut sim = sim_lock
                .take()
                .map_or_else(SparseStateQuantumSim::new, |s| s);
            ensure_sufficient_qubits(&mut sim, qubit as usize);
            let ctls_size = __quantum__rt__array_get_size_1d(ctls);
            let ctls_list: Vec<usize> = (0..ctls_size)
                .map(|index| {
                    let q = *__quantum__rt__array_get_element_ptr_1d(ctls, index)
                        .cast::<*mut c_void>() as usize;
                    ensure_sufficient_qubits(&mut sim, q);
                    q
                })
                .collect();

            sim.apply(&$gate_matrix, &[qubit as usize], Some(&ctls_list));

            *sim_lock = Some(sim);
        }
    };
}

multicontrolled_qubit_gate!(
    /// QIR API for performing the multicontrolled H gate with the given qubits.
    __quantum__qis__h__ctl,
    common_matrices::h()
);
multicontrolled_qubit_gate!(
    /// QIR API for performing the multicontrolled S gate with the given qubits.
    __quantum__qis__s__ctl,
    common_matrices::s()
);
multicontrolled_qubit_gate!(
    /// QIR API for performing the multicontrolled Adjoint S gate with the given qubits.
    __quantum__qis__s__ctladj,
    common_matrices::adjoint(&common_matrices::s())
);
multicontrolled_qubit_gate!(
    /// QIR API for performing the multicontrolled T gate with the given qubits.
    __quantum__qis__t__ctl,
    common_matrices::t()
);
multicontrolled_qubit_gate!(
    /// QIR API for performing the multicontrolled Adjoint T gate with the given qubits.
    __quantum__qis__t__ctladj,
    common_matrices::adjoint(&common_matrices::t())
);
multicontrolled_qubit_gate!(
    /// QIR API for performing the multicontrolled X gate with the given qubits.
    __quantum__qis__x__ctl,
    common_matrices::x()
);
multicontrolled_qubit_gate!(
    /// QIR API for performing the multicontrolled Y gate with the given qubits.
    __quantum__qis__y__ctl,
    common_matrices::y()
);
multicontrolled_qubit_gate!(
    /// QIR API for performing the multicontrolled Z gate with the given qubits.
    __quantum__qis__z__ctl,
    common_matrices::z()
);

#[derive(Copy, Clone)]
#[repr(C)]
struct RotationArgs {
    theta: c_double,
    qubit: *mut c_void,
}

macro_rules! multicontrolled_qubit_rotation {
    ($(#[$meta:meta])*
    $qir_name:ident, $gate_matrix:expr) => {
        $(#[$meta])*
        /// # Safety
        ///
        /// This function should only be called with arrays and tuples created by the QIR runtime library.
        #[no_mangle]
        pub unsafe extern "C" fn $qir_name(
            ctls: *const (usize, Vec<u8>),
            arg_tuple: *mut *const Vec<u8>,
        ) {
            let mut sim_lock = SIM.lock().expect("Unable to lock global simulator state.");
            let mut sim = sim_lock
                .take()
                .map_or_else(SparseStateQuantumSim::new, |s| s);

            let args = *arg_tuple.cast::<RotationArgs>();

            ensure_sufficient_qubits(&mut sim, args.qubit as usize);
            let ctls_size = __quantum__rt__array_get_size_1d(ctls);
            let ctls_list: Vec<usize> = (0..ctls_size)
                .map(|index| {
                    let q = *__quantum__rt__array_get_element_ptr_1d(ctls, index)
                        .cast::<*mut c_void>() as usize;
                    ensure_sufficient_qubits(&mut sim, q);
                    q
                })
                .collect();

            sim.apply(
                &$gate_matrix(args.theta),
                &[args.qubit as usize],
                Some(&ctls_list),
            );

            *sim_lock = Some(sim);
        }
    };
}

multicontrolled_qubit_rotation!(
    /// QIR API for applying a multicontrolled global phase rotation with the given angle and qubit.
    __quantum__qis__ri__ctl,
    common_matrices::g
);
multicontrolled_qubit_rotation!(
    /// QIR API for applying a multicontrolled Pauli-X rotation with the given angle and qubit.
    __quantum__qis__rx__ctl,
    common_matrices::rx
);
multicontrolled_qubit_rotation!(
    /// QIR API for applying a multicontrolled Pauli-Y rotation with the given angle and qubit.
    __quantum__qis__ry__ctl,
    common_matrices::ry
);
multicontrolled_qubit_rotation!(
    /// QIR API for applying a multicontrolled Pauli-Z rotation with the given angle and qubit.
    __quantum__qis__rz__ctl,
    common_matrices::rz
);

/// QIR API for applying a rotation about the given Pauli axis with the given angle and qubit.
#[no_mangle]
pub extern "C" fn __quantum__qis__r__body(pauli: Pauli, theta: c_double, qubit: *mut c_void) {
    match pauli {
        Pauli::I => __quantum__qis__ri__body(theta, qubit),
        Pauli::X => __quantum__qis__rx__body(theta, qubit),
        Pauli::Y => __quantum__qis__ry__body(theta, qubit),
        Pauli::Z => __quantum__qis__rz__body(theta, qubit),
    }
}

/// QIR API for applying an adjoint rotation about the given Pauli axis with the given angle and qubit.
#[no_mangle]
pub extern "C" fn __quantum__qis__r__adj(pauli: Pauli, theta: c_double, qubit: *mut c_void) {
    __quantum__qis__r__body(pauli, -theta, qubit);
}

#[derive(Copy, Clone)]
#[repr(C)]
struct PauliRotationArgs {
    pauli: Pauli,
    theta: c_double,
    qubit: *mut c_void,
}

/// QIR API for applying a controlled rotation about the given Pauli axis with the given angle and qubit.
/// # Safety
///
/// This function should only be called with arrays and tuples created by the QIR runtime library.
#[allow(clippy::cast_ptr_alignment)]
#[no_mangle]
pub unsafe extern "C" fn __quantum__qis__r__ctl(
    ctls: *const (usize, Vec<u8>),
    arg_tuple: *mut *const Vec<u8>,
) {
    let mut sim_lock = SIM.lock().expect("Unable to lock global simulator state.");
    let mut sim = sim_lock
        .take()
        .map_or_else(SparseStateQuantumSim::new, |s| s);

    let args = *arg_tuple.cast::<PauliRotationArgs>();

    ensure_sufficient_qubits(&mut sim, args.qubit as usize);
    let ctls_size = __quantum__rt__array_get_size_1d(ctls);
    let ctls_list: Vec<usize> = (0..ctls_size)
        .map(|index| {
            let q = *__quantum__rt__array_get_element_ptr_1d(ctls, index).cast::<*mut c_void>()
                as usize;
            ensure_sufficient_qubits(&mut sim, q);
            q
        })
        .collect();

    sim.apply(
        &(match args.pauli {
            Pauli::I => common_matrices::g,
            Pauli::X => common_matrices::rx,
            Pauli::Y => common_matrices::ry,
            Pauli::Z => common_matrices::rz,
        })(args.theta),
        &[args.qubit as usize],
        Some(&ctls_list),
    );

    *sim_lock = Some(sim);
}

/// QIR API for applying an adjoint controlled rotation about the given Pauli axis with the given angle and qubit.
/// # Safety
///
/// This function should only be called with arrays and tuples created by the QIR runtime library.
#[no_mangle]
pub unsafe extern "C" fn __quantum__qis__r__ctladj(
    ctls: *const (usize, Vec<u8>),
    arg_tuple: *mut *const Vec<u8>,
) {
    let args = *arg_tuple.cast::<PauliRotationArgs>();
    let new_args = PauliRotationArgs {
        pauli: args.pauli,
        theta: -args.theta,
        qubit: args.qubit,
    };
    let new_arg_tuple = __quantum__rt__tuple_create(size_of::<PauliRotationArgs>() as u64);
    *new_arg_tuple.cast::<PauliRotationArgs>() = new_args;
    __quantum__qis__r__ctl(ctls, new_arg_tuple);
    __quantum__rt__tuple_update_reference_count(new_arg_tuple, -1);
}

/// QIR API for applying a SWAP gate to the given qubits.
#[no_mangle]
pub extern "C" fn __quantum__qis__swap__body(qubit0: *mut c_void, qubit1: *mut c_void) {
    let mut sim_lock = SIM.lock().expect("Unable to lock global simulator state.");
    let mut sim = sim_lock
        .take()
        .map_or_else(SparseStateQuantumSim::new, |s| s);
    ensure_sufficient_qubits(&mut sim, qubit0 as usize);
    ensure_sufficient_qubits(&mut sim, qubit1 as usize);

    sim.apply(
        &common_matrices::swap(),
        &[qubit0 as usize, qubit1 as usize],
        None,
    );

    *sim_lock = Some(sim);
}

/// QIR API for performing the exponential of a multi-qubit Pauli operator with the given angle.
#[no_mangle]
pub extern "C" fn __quantum__qis__exp__body(
    _paulis: *const (usize, Vec<u8>),
    _theta: c_double,
    _qubits: *const (usize, Vec<u8>),
) {
    unimplemented!("Exp is not implemented.")
}

/// QIR API for performing the adjoint exponential of a multi-qubit Pauli operator with the given angle.
#[no_mangle]
pub extern "C" fn __quantum__qis__exp__adj(
    paulis: *const (usize, Vec<u8>),
    theta: c_double,
    qubits: *const (usize, Vec<u8>),
) {
    __quantum__qis__exp__body(paulis, -theta, qubits);
}

/// QIR API for performing the multicontrolled exponential of a multi-qubit Pauli operator with the given angle.
#[no_mangle]
pub extern "C" fn __quantum__qis__exp__ctl(
    _ctls: *const (usize, Vec<u8>),
    _arg_tuple: *mut *const Vec<u8>,
) {
    unimplemented!("Controlled Exp is not implemented.")
}

/// QIR API for performing the adjoint multicontrolled exponential of a multi-qubit Pauli operator with the given angle.
#[no_mangle]
pub extern "C" fn __quantum__qis__exp__ctladj(
    _ctls: *const (usize, Vec<u8>),
    _arg_tuple: *mut *const Vec<u8>,
) {
    unimplemented!("Controlled Exp is not implemented.")
}

/// QIR API for resetting the given qubit in the computational basis.
#[no_mangle]
pub extern "C" fn __quantum__qis__reset__body(qubit: *mut c_void) {
    let mut sim_lock = SIM.lock().expect("Unable to lock global simulator state.");
    let mut sim = sim_lock
        .take()
        .map_or_else(SparseStateQuantumSim::new, |s| s);
    ensure_sufficient_qubits(&mut sim, qubit as usize);

    if sim.measure(qubit as usize) {
        sim.apply(&common_matrices::x(), &[qubit as usize], None);
    }

    *sim_lock = Some(sim);
}

/// QIR API for measuring the given qubit in the computation basis and storing the measured value with the given result identifier.
#[no_mangle]
pub extern "C" fn __quantum__qis__mz__body(qubit: *mut c_void, result: *mut c_void) {
    let mut sim_lock = SIM.lock().expect("Unable to lock global simulator state.");
    let mut sim = sim_lock
        .take()
        .map_or_else(SparseStateQuantumSim::new, |s| s);
    let mut res = RESULTS.lock().expect("Unable to lock global result state.");
    let res_id = result as usize;
    ensure_sufficient_qubits(&mut sim, qubit as usize);

    if res.len() < res_id + 1 {
        res.resize(res_id + 1, false);
    }

    *res.get_mut(res_id)
        .expect("Result with given id missing after expansion.") = sim.measure(qubit as usize);

    *sim_lock = Some(sim);
}

/// QIR API that reads the Boolean value corresponding to the given result identifier, where true
/// indicates a |1⟩ state and false indicates a |0⟩ state.
#[no_mangle]
pub extern "C" fn __quantum__qis__read_result__body(result: *mut c_void) -> bool {
    let mut res = RESULTS.lock().expect("Unable to lock global result state.");
    let res_id = result as usize;
    if res.len() < res_id + 1 {
        res.resize(res_id + 1, false);
    }

    let b = *res
        .get(res_id)
        .expect("Result with given id missing after expansion.");
    b
}

/// QIR API that measures a given qubit in the computational basis, returning a runtime managed result value.
/// # Panics
///
#[no_mangle]
pub extern "C" fn __quantum__qis__m__body(qubit: *mut c_void) -> *mut c_void {
    let mut sim_lock = SIM.lock().expect("Unable to lock global simulator state.");
    let mut sim = sim_lock
        .take()
        .map_or_else(SparseStateQuantumSim::new, |s| s);
    ensure_sufficient_qubits(&mut sim, qubit as usize);

    let res = sim.measure(qubit as usize);

    *sim_lock = Some(sim);
    if res {
        __quantum__rt__result_get_one()
    } else {
        __quantum__rt__result_get_zero()
    }
}

/// QIR API that performs joint measurement of the given qubits in the corresponding Pauli bases, returning the parity as a runtime managed result value.
/// # Safety
///
/// This function should only be called with arrays created by the QIR runtime library.
/// # Panics
///
/// This function will panic if the provided paulis and qubits arrays are not of the same size.
#[allow(clippy::cast_ptr_alignment)]
#[no_mangle]
pub unsafe extern "C" fn __quantum__qis__measure__body(
    paulis: *const (usize, Vec<u8>),
    qubits: *const (usize, Vec<u8>),
) -> *mut c_void {
    let mut sim_lock = SIM.lock().expect("Unable to lock global simulator state.");
    let mut sim = sim_lock
        .take()
        .map_or_else(SparseStateQuantumSim::new, |s| s);

    let combined_list = map_paulis(&mut sim, paulis, qubits);

    let res = sim.joint_measure(
        &combined_list
            .iter()
            .map(|(_, q)| *q)
            .collect::<Vec<usize>>(),
    );

    unmap_paulis(&mut sim, combined_list);

    *sim_lock = Some(sim);
    if res {
        __quantum__rt__result_get_one()
    } else {
        __quantum__rt__result_get_zero()
    }
}

/// QIR API for checking internal simulator state and verifying the probability of the given parity measurement result
/// for the given qubits in the given Pauli bases is equal to the expected probability, within the given tolerance.
/// # Safety
///
/// This function should only be called with arrays created by the QIR runtime library.
#[no_mangle]
pub unsafe extern "C" fn __quantum__qis__assertmeasurementprobability__body(
    paulis: *const (usize, Vec<u8>),
    qubits: *const (usize, Vec<u8>),
    result: *mut c_void,
    prob: c_double,
    msg: *const CString,
    tol: c_double,
) {
    let mut sim_lock = SIM.lock().expect("Unable to lock global simulator state.");
    let mut sim = sim_lock
        .take()
        .map_or_else(SparseStateQuantumSim::new, |s| s);

    let combined_list = map_paulis(&mut sim, paulis, qubits);

    let mut actual_prob = sim.joint_probability(
        &combined_list
            .iter()
            .map(|(_, q)| *q)
            .collect::<Vec<usize>>(),
    );

    if __quantum__rt__result_equal(result, __quantum__rt__result_get_zero()) {
        actual_prob = 1.0 - actual_prob;
    }

    if (actual_prob - (prob as f64)).abs() > tol as f64 {
        __quantum__rt__fail(msg);
    }

    unmap_paulis(&mut sim, combined_list);

    *sim_lock = Some(sim);
}

#[derive(Copy, Clone)]
#[repr(C)]
struct AssertMeasurementProbabilityArgs {
    paulis: *const (usize, Vec<u8>),
    qubits: *const (usize, Vec<u8>),
    result: *mut c_void,
    prob: c_double,
    msg: *const CString,
    tol: c_double,
}

/// QIR API for checking internal simulator state and verifying the probability of the given parity measurement result
/// for the given qubits in the given Pauli bases is equal to the expected probability, within the given tolerance.
/// Note that control qubits are ignored.
/// # Safety
///
/// This function should only be called with arrays created by the QIR runtime library.
#[no_mangle]
pub unsafe extern "C" fn __quantum__qis__assertmeasurementprobability__ctl(
    _ctls: *const (usize, Vec<u8>),
    arg_tuple: *mut *const Vec<u8>,
) {
    let args = *arg_tuple.cast::<AssertMeasurementProbabilityArgs>();
    __quantum__qis__assertmeasurementprobability__body(
        args.paulis,
        args.qubits,
        args.result,
        args.prob,
        args.msg,
        args.tol,
    );
}

/// QIR API for recording the given result into the program output.
#[no_mangle]
pub extern "C" fn __quantum__rt__result_record_output(result: *mut c_void) {
    let mut res = RESULTS.lock().expect("Unable to lock global result state.");
    let res_id = result as usize;
    let b = if res.len() == 0 {
        // No static measurements have been used, so default to dynamic handling.
        __quantum__rt__result_equal(result, __quantum__rt__result_get_one())
    } else {
        if res.len() < res_id + 1 {
            res.resize(res_id + 1, false);
        }
        *res.get(res_id)
            .expect("Result with given id missing after expansion.")
    };

    println!("RESULT\t{}", if b { "1" } else { "0" });
}

/// QIR API that allocates the next available qubit in the simulation.
#[no_mangle]
pub extern "C" fn __quantum__rt__qubit_allocate() -> *mut c_void {
    let mut sim_lock = SIM.lock().expect("Unable to lock global simulator state.");
    let mut sim = sim_lock
        .take()
        .map_or_else(SparseStateQuantumSim::new, |s| s);
    let qubit_id = sim.allocate();

    // Increase the max qubit id global so that `ensure_sufficient_qubits` wont trigger more allocations.
    // NOTE: static allocation and dynamic allocation shouldn't be used together, so this is safe to do.
    (*MAX_QUBIT_ID).fetch_max(qubit_id + 1, Relaxed);

    *sim_lock = Some(sim);
    qubit_id as *mut c_void
}

/// QIR API for allocating the given number of qubits in the simulation, returning them as a runtime managed array.
/// # Panics
///
/// This function will panic if the underlying platform has a pointer size that cannot be described in
/// a `u32`.
#[allow(clippy::cast_ptr_alignment)]
#[no_mangle]
pub extern "C" fn __quantum__rt__qubit_allocate_array(size: u64) -> *const (usize, Vec<u8>) {
    let arr = __quantum__rt__array_create_1d(size_of::<usize>().try_into().unwrap(), size);
    for index in 0..size {
        unsafe {
            let elem = __quantum__rt__array_get_element_ptr_1d(arr, index).cast::<*mut c_void>();
            *elem = __quantum__rt__qubit_allocate();
        }
    }
    arr
}

/// QIR API for releasing the given runtime managed qubit array.
/// # Safety
///
/// This function should only be called with arrays created by `__quantum__rt__qubit_allocate_array`.
#[allow(clippy::cast_ptr_alignment)]
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__qubit_release_array(arr: *const (usize, Vec<u8>)) {
    for index in 0..__quantum__rt__array_get_size_1d(arr) {
        let elem = __quantum__rt__array_get_element_ptr_1d(arr, index).cast::<*mut c_void>();
        __quantum__rt__qubit_release(*elem);
    }
    __quantum__rt__array_update_alias_count(arr, -1);
}

/// QIR API for releasing the given qubit from the simulation.
#[no_mangle]
pub extern "C" fn __quantum__rt__qubit_release(qubit: *mut c_void) {
    let mut sim_lock = SIM.lock().expect("Unable to lock global simulator state.");
    let mut sim = sim_lock
        .take()
        .map_or_else(SparseStateQuantumSim::new, |s| s);
    sim.release(qubit as usize);
    *sim_lock = Some(sim);
}

/// API for viewing the current global result and quantum state for the simulator.
#[no_mangle]
pub extern "C" fn dump_state() {
    let mut sim_lock = SIM.lock().expect("Unable to lock global simulator state.");
    let mut sim = sim_lock
        .take()
        .map_or_else(SparseStateQuantumSim::new, |s| s);
    let res = RESULTS.lock().expect("Unable to lock global result state.");

    if !(*res).is_empty() {
        println!("Global Results: {}", *res);
    }
    sim.dump();

    *sim_lock = Some(sim);
}

/// QIR API for dumping full internal simulator state.
#[no_mangle]
pub extern "C" fn __quantum__qis__dumpmachine__body(location: *mut c_void) {
    if !location.is_null() {
        unimplemented!("Dump to location is not implemented.")
    }
    dump_state();
}

/// QIR API for dumping the internal simulator state for the given qubits.
#[no_mangle]
pub extern "C" fn __quantum__qis__dumpregister__body(
    _location: *mut c_void,
    _qubits: *const (usize, Vec<u8>),
) {
    unimplemented!("Dump of qubit register is not implemented.")
}

#[cfg(test)]
mod tests {
    use std::ffi::c_void;

    use super::{
        __quantum__qis__cnot__body, __quantum__qis__h__body, __quantum__qis__m__body,
        __quantum__qis__mz__body, __quantum__qis__read_result__body, __quantum__qis__x__body,
        __quantum__rt__qubit_allocate, __quantum__rt__qubit_allocate_array,
        __quantum__rt__qubit_release, __quantum__rt__qubit_release_array,
        __quantum__rt__result_equal, __quantum__rt__result_get_one, dump_state,
    };
    use crate::arrays::__quantum__rt__array_get_element_ptr_1d;

    // TODO(swernli): Split and expand simulator unit tests.
    #[allow(clippy::cast_ptr_alignment)]
    #[test]
    fn basic_test() {
        let q0 = 5 as *mut c_void;
        let r0 = std::ptr::null_mut();
        let r1 = 1 as *mut c_void;
        __quantum__qis__mz__body(q0, r0);
        assert!(!__quantum__qis__read_result__body(r0));
        __quantum__qis__x__body(q0);
        __quantum__qis__mz__body(q0, r1);
        assert!(__quantum__qis__read_result__body(r1));
        __quantum__qis__x__body(q0);
        __quantum__qis__mz__body(q0, r0);
        assert!(!__quantum__qis__read_result__body(r0));
        assert!(!__quantum__qis__read_result__body(3 as *mut c_void));
        dump_state();

        // Dynamic qubits can be used after static, but not the other way around. Keep test cases
        // together to avoid issues with global state.
        let q1 = __quantum__rt__qubit_allocate();
        let q2 = __quantum__rt__qubit_allocate();
        __quantum__qis__h__body(q1);
        __quantum__qis__cnot__body(q1, q2);
        let r1 = __quantum__qis__m__body(q1);
        let r2 = __quantum__qis__m__body(q2);
        assert!(__quantum__rt__result_equal(r1, r2));
        dump_state();
        __quantum__rt__qubit_release(q2);
        __quantum__rt__qubit_release(q1);
        let qs = __quantum__rt__qubit_allocate_array(4);
        unsafe {
            let q_elem = __quantum__rt__array_get_element_ptr_1d(qs, 3).cast::<*mut c_void>();
            __quantum__qis__x__body(*q_elem);
            dump_state();
            let r = __quantum__qis__m__body(*q_elem);
            assert!(__quantum__rt__result_equal(
                r,
                __quantum__rt__result_get_one()
            ));
            __quantum__rt__qubit_release_array(qs);
        }
    }
}
