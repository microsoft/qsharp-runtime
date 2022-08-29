// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
#![deny(clippy::all, clippy::pedantic)]

// Rust Implementation for Quantum Intermediate Representation

pub mod arrays;
pub mod bigints;
pub mod callables;
pub mod math;
pub mod output_recording;
pub mod range_support;
pub mod strings;
pub mod tuples;

#[cfg(feature = "sim")]
pub mod sim;

use std::{
    ffi::CString,
    rc::{Rc, Weak},
};

/// Utility used for managing refcounted items.
unsafe fn update_counts<T>(raw_rc: *const T, update: i32, is_alias: bool) {
    let mut remaining = update;
    while remaining != 0 {
        let rc = Rc::from_raw(raw_rc);
        if remaining > 0 {
            // Create and leak new instances to increment the count on the contained item.
            if is_alias {
                let _ = Weak::into_raw(Rc::downgrade(&rc));
            } else {
                let _ = Rc::into_raw(Rc::clone(&rc));
            }

            remaining -= 1;
        } else {
            // Create and drop instances to decrement the count on contained item.
            if is_alias {
                let w = Weak::into_raw(Rc::downgrade(&rc));

                // Need to drop two for a net decrement, since above line increments.
                drop(Weak::from_raw(w));
                drop(Weak::from_raw(w));
            } else {
                drop(Rc::from_raw(raw_rc));
            }

            remaining += 1;
        }

        let _ = Rc::into_raw(rc);
    }
}

#[derive(Debug, Copy, Clone)]
#[repr(i8)]
pub enum Pauli {
    I = 0,
    X = 1,
    Z = 2,
    Y = 3,
}

/// # Panics
///
/// Will panic if unable to allocate memory.
#[no_mangle]
pub extern "C" fn __quantum__rt__memory_allocate(size: u64) -> *mut u8 {
    (vec![0_u8; size.try_into().unwrap()]).leak().as_mut_ptr()
}

/// # Safety
///
/// This function should only be called with a string created by `__quantum__rt__string_*` functions.
/// # Panics
///
/// Panics unconditionally with the given message.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__fail(str: *const CString) {
    panic!("{}", (*str).to_str().expect("Unable to convert string"));
}

/// # Safety
///
/// This function should only be called with a string created by `__quantum__rt__string_*` functions.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__message(str: *const CString) {
    println!("{}", (*str).to_str().expect("Unable to convert string"));
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_memory_allocate() {
        let size = 10;
        let mem = __quantum__rt__memory_allocate(size as u64);
        unsafe {
            for val in Vec::from_raw_parts(mem, size, size) {
                assert_eq!(val, 0);
            }
        }
    }

    #[test]
    #[should_panic(expected = "FAIL")]
    fn test_fail() {
        let str = CString::new("FAIL").unwrap();
        unsafe {
            __quantum__rt__fail(&str);
        }
    }

    #[test]
    fn test_message() {
        let str = CString::new("Message").unwrap();
        unsafe {
            __quantum__rt__message(&str);
        }
        // message should not consume string, so check that it's value is still correct.
        assert_eq!(str.to_str().unwrap(), "Message");
    }
}
