// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
#![deny(clippy::all, clippy::pedantic)]

use crate::update_counts;
use std::{rc::Rc, usize};

/// # Panics
///
/// This function panics if the passed in sizes do not fit into the usize type for the
/// current platform.
#[no_mangle]
pub extern "C" fn __quantum__rt__array_create_1d(
    elem_size: u32,
    size: u64,
) -> *const (usize, Vec<u8>) {
    let elem_size_size: usize = elem_size.try_into().unwrap();
    let size_size: usize = size.try_into().unwrap();
    let array = vec![0_u8; elem_size_size * size_size];
    Rc::into_raw(Rc::new((elem_size_size, array)))
}

/// # Safety
///
/// This function should only be called with an array created by `__quantum__rt__array_*` functions.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__array_copy(
    arr: *const (usize, Vec<u8>),
    force: bool,
) -> *const (usize, Vec<u8>) {
    let rc = Rc::from_raw(arr);
    if force || Rc::weak_count(&rc) > 0 {
        let copy = rc.as_ref().clone();
        let _ = Rc::into_raw(rc);
        Rc::into_raw(Rc::new(copy))
    } else {
        let _ = Rc::into_raw(Rc::clone(&rc));
        let _ = Rc::into_raw(rc);
        arr
    }
}

/// # Safety
///
/// This function should only be called with arrays created by `__quantum__rt__array_*` functions.
/// # Panics
///
/// This function will panic if the given arrays use different element sizes.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__array_concatenate(
    arr1: *const (usize, Vec<u8>),
    arr2: *const (usize, Vec<u8>),
) -> *const (usize, Vec<u8>) {
    let array1 = Rc::from_raw(arr1);
    let array2 = Rc::from_raw(arr2);
    assert!(
        array1.0 == array2.0,
        "Cannot concatenate arrays with differing element sizes: {} vs {}",
        array1.0,
        array2.0
    );

    let mut new_array = (array1.0, Vec::new());
    new_array.1.resize(array1.1.len(), 0_u8);
    new_array.1.copy_from_slice(array1.1.as_slice());

    let mut copy = Vec::new();
    copy.resize(array2.1.len(), 0_u8);
    copy.copy_from_slice(array2.1.as_slice());

    new_array.1.append(&mut copy);
    let _ = Rc::into_raw(array1);
    let _ = Rc::into_raw(array2);
    Rc::into_raw(Rc::new(new_array))
}

/// # Safety
///
/// This function should only be called with an array created by `__quantum__rt__array_*` functions.
/// # Panics
///
/// This function panics if the array size is larger than u64. This shouldn't happen.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__array_get_size_1d(arr: *const (usize, Vec<u8>)) -> u64 {
    let array = Rc::from_raw(arr);
    let size = array.1.len() / array.0;
    let _ = Rc::into_raw(array);
    size.try_into().unwrap()
}

/// # Safety
///
/// This function should only be called with an array created by `__quantum__rt__array_*` functions.
/// # Panics
///
/// This function panics if the given index is larger than the usize type for the current platform.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__array_get_element_ptr_1d(
    arr: *const (usize, Vec<u8>),
    index: u64,
) -> *mut i8 {
    let array = Rc::from_raw(arr);
    let i: usize = index.try_into().unwrap();
    let ptr = array.1.as_ptr().wrapping_add(array.0 * i) as *mut i8;
    let _ = Rc::into_raw(array);
    ptr
}

/// # Safety
///
/// This function should only be called with an array created by `__quantum__rt__array_*` functions.
/// If the reference count after update is less than or equal to zero, the array is cleaned up
/// and the pointer is no longer valid.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__array_update_reference_count(
    arr: *const (usize, Vec<u8>),
    update: i32,
) {
    update_counts(arr, update, false);
}

/// # Safety
///
/// This function should only be called with an array created by `__quantum__rt__array_*` functions.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__array_update_alias_count(
    arr: *const (usize, Vec<u8>),
    update: i32,
) {
    update_counts(arr, update, true);
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::range_support::{quantum__rt__array_slice_1d, Range};

    #[test]
    fn test_array_1d_basics() {
        let arr = __quantum__rt__array_create_1d(1, 3);
        unsafe {
            assert_eq!(__quantum__rt__array_get_size_1d(arr), 3);
            let first = __quantum__rt__array_get_element_ptr_1d(arr, 0);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr, 0), 0);
            *first = 42;
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr, 0), 42);
            let second = __quantum__rt__array_get_element_ptr_1d(arr, 1);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr, 1), 0);
            *second = 31;
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr, 1), 31);
            let arr2 = __quantum__rt__array_copy(arr, true);
            assert_eq!(__quantum__rt__array_get_size_1d(arr2), 3);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr2, 0), 42);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr2, 1), 31);
            let arr3 = __quantum__rt__array_concatenate(arr, arr2);
            assert_eq!(__quantum__rt__array_get_size_1d(arr3), 6);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr3, 0), 42);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr3, 1), 31);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr3, 2), 0);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr3, 3), 42);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr3, 4), 31);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr3, 5), 0);
            let arr4 = quantum__rt__array_slice_1d(
                arr3,
                Range {
                    start: 0,
                    step: 2,
                    end: 5,
                },
            );
            assert_eq!(__quantum__rt__array_get_size_1d(arr4), 3);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr4, 0), 42);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr4, 1), 0);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr4, 2), 31);
            let arr5 = quantum__rt__array_slice_1d(
                arr3,
                Range {
                    start: 4,
                    step: -2,
                    end: 0,
                },
            );
            assert_eq!(__quantum__rt__array_get_size_1d(arr5), 3);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr5, 0), 31);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr5, 1), 0);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr5, 2), 42);
            let arr6 = quantum__rt__array_slice_1d(
                arr5,
                Range {
                    start: 0,
                    step: 1,
                    end: -1,
                },
            );
            assert_eq!(__quantum__rt__array_get_size_1d(arr6), 0);
            __quantum__rt__array_update_reference_count(arr, -1);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr2, 1), 31);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr3, 0), 42);
            __quantum__rt__array_update_reference_count(arr2, -1);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr3, 0), 42);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr3, 1), 31);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr3, 2), 0);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr3, 3), 42);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr3, 4), 31);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr3, 5), 0);
            __quantum__rt__array_update_reference_count(arr3, -1);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr4, 0), 42);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr4, 1), 0);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr4, 2), 31);
            __quantum__rt__array_update_reference_count(arr4, -1);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr5, 0), 31);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr5, 1), 0);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr5, 2), 42);
            __quantum__rt__array_update_reference_count(arr5, -1);
            __quantum__rt__array_update_reference_count(arr6, -1);
        }
    }
}
