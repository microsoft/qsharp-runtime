// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
#![deny(clippy::all, clippy::pedantic)]
#![allow(clippy::missing_safety_doc)]
#![allow(clippy::missing_panics_doc)]

//! # Rust Implementation for Quantum Intermediate Representation
//! This library implements the classical runtime functions described in the [QIR specification](https://github.com/qir-alliance/qir-spec).

// FUTURE: We should add microbenchmarks to verify behavior of these APIs and have a baseline on how changes affect
// peformance of the APIs.

pub mod arrays;
pub mod bigints;
pub mod callables;
pub mod math;
pub mod output_recording;
pub mod range_support;
pub mod strings;
pub mod tuples;

use std::{
    ffi::CString,
    mem::{self, ManuallyDrop},
    rc::{Rc, Weak},
};

/// Utility used for managing refcounted items.
unsafe fn update_counts<T>(raw_rc: *const T, update: i32, is_alias: bool) {
    let mut remaining = update;
    while remaining != 0 {
        let rc = ManuallyDrop::new(Rc::from_raw(raw_rc));
        if remaining > 0 {
            if is_alias {
                // Create and leak new downgraded instances to increment the weak count on the contained item.
                mem::forget(Rc::downgrade(&rc));
            } else {
                Rc::increment_strong_count(raw_rc);
            }

            remaining -= 1;
        } else {
            if is_alias {
                // Create and drop downgraded instances to decrement the weak count on contained item.
                let w = Weak::into_raw(Rc::downgrade(&rc));

                // Need to drop two for a net decrement, since above line increments.
                drop(Weak::from_raw(w));
                drop(Weak::from_raw(w));
            } else {
                Rc::decrement_strong_count(raw_rc);
            }

            remaining += 1;
        }
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

#[no_mangle]
pub extern "C" fn __quantum__rt__memory_allocate(size: u64) -> *mut u8 {
    (vec![
        0_u8;
        size.try_into()
            .expect("Memory size is too large for `usize` type on this platform.")
    ])
    .leak()
    .as_mut_ptr()
}

#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__fail(str: *const CString) {
    __quantum__rt__message(str);
    panic!("{}", (*str).to_str().expect("Unable to convert string"));
}

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
