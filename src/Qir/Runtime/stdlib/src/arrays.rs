// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
#![deny(clippy::all, clippy::pedantic)]

use crate::update_counts;
use std::{rc::Rc, usize};

#[derive(Debug, Clone)]
pub struct QirArray {
    pub(crate) elem_size: usize,
    pub(crate) data: Vec<u8>,
}

/// # Panics
///
/// This function panics if the passed in sizes do not fit into the usize type for the
/// current platform.
#[no_mangle]
pub extern "C" fn __quantum__rt__array_create_1d(elem_size: u32, size: u64) -> *const QirArray {
    let elem_size = elem_size.try_into().unwrap();
    let size: usize = size.try_into().unwrap();
    let data = vec![0_u8; elem_size * size];
    Rc::into_raw(Rc::new(QirArray { elem_size, data }))
}

/// # Safety
///
/// This function should only be called with an array created by `__quantum__rt__array_*` functions.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__array_copy(
    arr: *const QirArray,
    force: bool,
) -> *const QirArray {
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
    arr1: *const QirArray,
    arr2: *const QirArray,
) -> *const QirArray {
    let array1 = Rc::from_raw(arr1);
    let array2 = Rc::from_raw(arr2);
    assert!(
        array1.elem_size == array2.elem_size,
        "Cannot concatenate arrays with differing element sizes: {} vs {}",
        array1.elem_size,
        array2.elem_size
    );

    let mut new_array = QirArray {
        elem_size: array1.elem_size,
        data: Vec::new(),
    };
    new_array.data.resize(array1.data.len(), 0_u8);
    new_array.data.copy_from_slice(array1.data.as_slice());

    let mut copy = Vec::new();
    copy.resize(array2.data.len(), 0_u8);
    copy.copy_from_slice(array2.data.as_slice());

    new_array.data.append(&mut copy);
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
pub unsafe extern "C" fn __quantum__rt__array_get_size_1d(arr: *const QirArray) -> u64 {
    let array = Rc::from_raw(arr);
    let size = array.data.len() / array.elem_size;
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
    arr: *const QirArray,
    index: u64,
) -> *mut i8 {
    let array = Rc::from_raw(arr);
    let i: usize = index.try_into().unwrap();
    let ptr = array.data.as_ptr().add(array.elem_size * i) as *mut i8;
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
    arr: *const QirArray,
    update: i32,
) {
    update_counts(arr, update, false);
}

/// # Safety
///
/// This function should only be called with an array created by `__quantum__rt__array_*` functions.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__array_update_alias_count(
    arr: *const QirArray,
    update: i32,
) {
    update_counts(arr, update, true);
}

#[cfg(test)]
mod tests {
    use std::{mem::size_of, convert::TryInto};

    use super::*;
    use crate::range_support::{quantum__rt__array_slice_1d, Range};

    #[test]
    fn test_array_creation_simple() {
        let arr = __quantum__rt__array_create_1d(1, 3);
        unsafe {
            assert_eq!(__quantum__rt__array_get_size_1d(arr), 3);
            // Note: array reference counts must be decremented to prevent leaking array from test
            // and failing address sanitized runs.
            __quantum__rt__array_update_reference_count(arr, -1);
        }
    }

    #[test]
    fn test_array_item_zero_init() {
        let arr = __quantum__rt__array_create_1d(1, 3);
        unsafe {
            assert_eq!(__quantum__rt__array_get_size_1d(arr), 3);
            // Array contents should always be zero initialized.
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr, 0), 0);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr, 1), 0);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr, 2), 0);
            __quantum__rt__array_update_reference_count(arr, -1);
        }
    }

    #[test]
    fn test_array_item_updates() {
        let arr = __quantum__rt__array_create_1d(1, 3);
        unsafe {
            assert_eq!(__quantum__rt__array_get_size_1d(arr), 3);
            // Confirm that array contents can be updated.
            let first = __quantum__rt__array_get_element_ptr_1d(arr, 0);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr, 0), 0);
            *first = 42;
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr, 0), 42);
            let second = __quantum__rt__array_get_element_ptr_1d(arr, 1);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr, 1), 0);
            *second = 31;
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr, 1), 31);
            let third = __quantum__rt__array_get_element_ptr_1d(arr, 2);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr, 2), 0);
            *third = 20;
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr, 2), 20);
            __quantum__rt__array_update_reference_count(arr, -1);
        }
    }

    #[test]
    fn test_array_copy() {
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
            // First array has contents [42, 31, 0], copy to second array and confirm contents.
            let arr2 = __quantum__rt__array_copy(arr, true);
            assert_eq!(__quantum__rt__array_get_size_1d(arr2), 3);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr2, 0), 42);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr2, 1), 31);
            // Update first array to [42, 31, 20], confirm second array is independent copy that still
            // has original value.
            let third = __quantum__rt__array_get_element_ptr_1d(arr, 2);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr, 2), 0);
            *third = 20;
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr, 2), 20);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr2, 2), 0);
            // Decrement ref count on first array to trigger deletion, confirm the second array is
            // independent copy with original values.
            __quantum__rt__array_update_reference_count(arr, -1);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr2, 0), 42);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr2, 1), 31);
            __quantum__rt__array_update_reference_count(arr2, -1);
        }
    }

    #[test]
    fn test_array_concat() {
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
            // First array has contents [42, 31, 0], copy to second array and confirm contents.
            let arr2 = __quantum__rt__array_copy(arr, true);
            assert_eq!(__quantum__rt__array_get_size_1d(arr2), 3);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr2, 0), 42);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr2, 1), 31);
            // Create third array with concatenated contents [42, 31, 0, 42, 31, 0].
            let arr3 = __quantum__rt__array_concatenate(arr, arr2);
            assert_eq!(__quantum__rt__array_get_size_1d(arr3), 6);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr3, 0), 42);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr3, 1), 31);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr3, 2), 0);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr3, 3), 42);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr3, 4), 31);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr3, 5), 0);
            // Decrement counts on first and secon array to trigger deletion, confirm third array
            // maintains contents.
            __quantum__rt__array_update_reference_count(arr, -1);
            __quantum__rt__array_update_reference_count(arr2, -1);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr3, 0), 42);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr3, 1), 31);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr3, 2), 0);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr3, 3), 42);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr3, 4), 31);
            assert_eq!(*__quantum__rt__array_get_element_ptr_1d(arr3, 5), 0);
            __quantum__rt__array_update_reference_count(arr3, -1);
        }
    }

    #[test]
    fn test_array_slicing() {
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
            // Third array crated via concatenation has contents [42, 31, 0, 42, 31, 0], create
            // fourth array via slicing with step size 2, expected contents [42, 0, 31].
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
            // Create fifth array via slicing with reverse iteration, expected contents
            // [31, 0, 42].
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
            // Create sixth array with range end less than range start, should succeed and create
            // an empty array.
            let arr6 = quantum__rt__array_slice_1d(
                arr5,
                Range {
                    start: 0,
                    step: 1,
                    end: -1,
                },
            );
            // Confirm each copy, concatenation, and slice is independent of others.
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

    #[allow(clippy::cast_ptr_alignment)]
    #[test]
    fn test_array_creation_large_size() {
        // Use a struct that is known to have a size greater than 1.
        struct Data {
            first: i64,
            second: i64,
            third: i64,
        }
        let arr = __quantum__rt__array_create_1d(size_of::<Data>().try_into().unwrap(), 3);
        unsafe {
            assert_eq!(__quantum__rt__array_get_size_1d(arr), 3);
            let first = __quantum__rt__array_get_element_ptr_1d(arr, 0).cast::<Data>();
            *first = Data{first: 1, second: 2, third: 3};
            let second = __quantum__rt__array_get_element_ptr_1d(arr, 1).cast::<Data>();
            *second = Data{first: 10, second: 20, third: 30};
            let third = __quantum__rt__array_get_element_ptr_1d(arr, 2).cast::<Data>();
            *third = Data{first: 100, second: 200, third: 300};
            assert_eq!((*(__quantum__rt__array_get_element_ptr_1d(arr, 0).cast::<Data>())).first, 1);
            assert_eq!((*(__quantum__rt__array_get_element_ptr_1d(arr, 0).cast::<Data>())).second, 2);
            assert_eq!((*(__quantum__rt__array_get_element_ptr_1d(arr, 0).cast::<Data>())).third, 3);
            assert_eq!((*(__quantum__rt__array_get_element_ptr_1d(arr, 1).cast::<Data>())).first, 10);
            assert_eq!((*(__quantum__rt__array_get_element_ptr_1d(arr, 1).cast::<Data>())).second, 20);
            assert_eq!((*(__quantum__rt__array_get_element_ptr_1d(arr, 1).cast::<Data>())).third, 30);
            assert_eq!((*(__quantum__rt__array_get_element_ptr_1d(arr, 2).cast::<Data>())).first, 100);
            assert_eq!((*(__quantum__rt__array_get_element_ptr_1d(arr, 2).cast::<Data>())).second, 200);
            assert_eq!((*(__quantum__rt__array_get_element_ptr_1d(arr, 2).cast::<Data>())).third, 300);
            __quantum__rt__array_update_reference_count(arr, -1);
        }
    }
}
