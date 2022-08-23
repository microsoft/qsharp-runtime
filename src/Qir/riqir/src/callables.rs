// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
#![deny(clippy::all, clippy::pedantic)]

use crate::{
    arrays::{__quantum__rt__array_concatenate, __quantum__rt__array_update_reference_count},
    tuples::{__quantum__rt__tuple_copy, __quantum__rt__tuple_update_reference_count},
    update_counts,
};
use std::{cell::RefCell, rc::Rc, usize};

#[derive(Clone)]
pub struct Callable {
    func_table: *mut *mut u8,
    mem_table: *mut *mut u8,
    cap_tuple: *mut u8,
    is_adj: RefCell<bool>,
    is_ctl: RefCell<u32>,
}

#[no_mangle]
pub extern "C" fn __quantum__rt__callable_create(
    func_table: *mut *mut u8,
    mem_table: *mut *mut u8,
    cap_tuple: *mut u8,
) -> *const Callable {
    Rc::into_raw(Rc::new(Callable {
        func_table,
        mem_table,
        cap_tuple,
        is_adj: RefCell::new(false),
        is_ctl: RefCell::new(0),
    }))
}

/// # Safety
///
/// This function should only be called with a callable created by `__quantum__rt__callable_*` functions.
#[no_mangle]
#[allow(clippy::cast_ptr_alignment)]
pub unsafe extern "C" fn __quantum__rt__callable_invoke(
    callable: *const Callable,
    args_tup: *mut u8,
    res_tup: *mut u8,
) {
    let call = Rc::from_raw(callable);
    let index = (if *call.is_adj.borrow() { 1 } else { 0 })
        + (if *call.is_ctl.borrow() > 0 { 2 } else { 0 });

    // Collect any nested controls into a single control list.
    let mut args_copy: *mut *const Vec<u8> = std::ptr::null_mut();
    if !args_tup.is_null() {
        // Copy the tuple so we can potentially edit it.
        args_copy = __quantum__rt__tuple_copy(args_tup.cast::<*const Vec<u8>>(), true);

        if *call.is_ctl.borrow() > 0 {
            // If there are any controls, increment the reference count on the control list. This is just
            // to balance the decrement that will happen in the loop and at the end of invoking the callable
            // to ensure the original, non-owned list does not get incorrectly cleaned up.
            __quantum__rt__array_update_reference_count(
                *args_copy.cast::<*const (usize, Vec<u8>)>(),
                1,
            );

            let mut ctl_count = *call.is_ctl.borrow();
            while ctl_count > 1 {
                let ctls = *args_copy.cast::<*const (usize, Vec<u8>)>();
                let inner_tuple = *args_copy
                    .cast::<*const (usize, Vec<u8>)>()
                    .wrapping_add(1)
                    .cast::<*mut *const Vec<u8>>();
                let inner_ctls = *inner_tuple.cast::<*const (usize, Vec<u8>)>();
                let new_ctls = __quantum__rt__array_concatenate(ctls, inner_ctls);
                let new_args = __quantum__rt__tuple_copy(inner_tuple, true);
                *new_args.cast::<*const (usize, Vec<u8>)>() = new_ctls;

                // Decrementing the reference count is either the extra count added above or the new
                // list created when performing concatenate above. In the latter case, the concatenated
                // list will get cleaned up, preventing memory from leaking.
                __quantum__rt__array_update_reference_count(
                    *args_copy.cast::<*const (usize, Vec<u8>)>(),
                    -1,
                );
                // Decrement the count on the copy to clean it up as well, since we created a new copy
                // with the updated controls list.
                __quantum__rt__tuple_update_reference_count(args_copy, -1);
                args_copy = new_args;
                ctl_count -= 1;
            }
        }
    }

    (*call
        .func_table
        .wrapping_add(index)
        .cast::<extern "C" fn(*mut u8, *mut u8, *mut u8)>())(
        call.cap_tuple,
        args_copy.cast::<u8>(),
        res_tup,
    );
    if *call.is_ctl.borrow() > 0 {
        __quantum__rt__array_update_reference_count(
            *args_copy.cast::<*const (usize, Vec<u8>)>(),
            -1,
        );
    }
    if !args_copy.is_null() {
        __quantum__rt__tuple_update_reference_count(args_copy, -1);
    }
    let _ = Rc::into_raw(call);
}

/// # Safety
///
/// This function should only be called with a callable created by `__quantum__rt__callable_*` functions.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__callable_copy(
    callable: *const Callable,
    force: bool,
) -> *const Callable {
    let rc = Rc::from_raw(callable);
    if force || Rc::weak_count(&rc) > 0 {
        let copy = rc.as_ref().clone();
        let _ = Rc::into_raw(rc);
        Rc::into_raw(Rc::new(copy))
    } else {
        let _ = Rc::into_raw(Rc::clone(&rc));
        let _ = Rc::into_raw(rc);
        callable
    }
}

/// # Safety
///
/// This function should only be called with a callable created by `__quantum__rt__callable_*` functions.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__callable_make_adjoint(callable: *const Callable) {
    let call = Rc::from_raw(callable);
    let _ = call.is_adj.replace_with(|&mut old| !old);
    let _ = Rc::into_raw(call);
}

/// # Safety
///
/// This function should only be called with a callable created by `__quantum__rt__callable_*` functions.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__callable_make_controlled(callable: *const Callable) {
    let call = Rc::from_raw(callable);
    let _ = call.is_ctl.replace_with(|&mut old| old + 1);
    let _ = Rc::into_raw(call);
}

/// # Safety
///
/// This function should only be called with a callable created by `__quantum__rt__callable_*` functions.
/// If the reference count after update is less than or equal to zero, the callable is cleaned up
/// and the pointer is no longer valid.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__callable_update_reference_count(
    callable: *const Callable,
    update: i32,
) {
    update_counts(callable, update, false);
}

/// # Safety
///
/// This function should only be called with a callable created by `__quantum__rt__callable_*` functions.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__callable_update_alias_count(
    callable: *const Callable,
    update: i32,
) {
    update_counts(callable, update, true);
}

/// # Safety
///
/// This function should only be called with a callable created by `__quantum__rt__callable_*` functions.
/// If the reference count after update is less than or equal to zero, the capture tuple is cleaned up
/// and the pointer is no longer valid.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__capture_update_reference_count(
    callable: *const Callable,
    update: i32,
) {
    let call = Rc::from_raw(callable);
    if !call.mem_table.is_null() && !(*(call.mem_table)).is_null() {
        (*call.mem_table.cast::<extern "C" fn(*mut u8, i32)>())(call.cap_tuple, update);
    }
    let _ = Rc::into_raw(call);
}

/// # Safety
///
/// This function should only be called with a callable created by `__quantum__rt__callable_*` functions.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__capture_update_alias_count(
    callable: *const Callable,
    update: i32,
) {
    let call = Rc::from_raw(callable);
    if !call.mem_table.is_null() && !(*(call.mem_table.wrapping_add(1))).is_null() {
        let _val = **(call.mem_table.cast::<*mut usize>().wrapping_add(1));
        (*call
            .mem_table
            .wrapping_add(1)
            .cast::<extern "C" fn(*mut u8, i32)>())(call.cap_tuple, update);
    }
    let _ = Rc::into_raw(call);
}
