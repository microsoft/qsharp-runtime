// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Functionality in this file can be removed when range support is dropped from the QIR runtime.

use crate::{arrays::QirArray, strings::convert};
use std::{ffi::CString, rc::Rc};

#[repr(C)]
pub struct Range {
    pub start: i64,
    pub step: i64,
    pub end: i64,
}

#[no_mangle]
pub extern "C" fn quantum__rt__range_to_string(input: Range) -> *const CString {
    let mut range_str = input.start.to_string() + "..";
    if input.step != 1 {
        range_str += &(input.step.to_string() + "..");
    }
    range_str += &input.end.to_string();

    convert(&range_str)
}

#[no_mangle]
pub unsafe extern "C" fn quantum__rt__array_slice_1d(
    arr: *const QirArray,
    range: Range,
) -> *const QirArray {
    let array = &*arr;
    let item_size: i64 = array
        .elem_size
        .try_into()
        .expect("Array element size too large for `usize` type on this platform.");
    let mut slice = QirArray {
        elem_size: array.elem_size,
        data: Vec::new(),
    };
    let iter: Box<dyn Iterator<Item = i64>> = if range.step > 0 {
        Box::new(range.start * item_size..=range.end * item_size)
    } else {
        Box::new((range.end * item_size..=range.start * item_size).rev())
    };

    let step: i64 = range.step.abs();
    for i in iter.step_by((step * item_size).try_into().expect(
        "Range step multiplied by item size is too large for `usize` type on this platform",
    )) {
        let index = i
            .try_into()
            .expect("Item index too large for `usize` type on this platform.");
        let mut copy = Vec::new();
        copy.resize(array.elem_size, 0_u8);
        copy.copy_from_slice(&array.data[index..index + array.elem_size]);
        slice.data.append(&mut copy);
    }

    Rc::into_raw(Rc::new(slice))
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::{
        arrays::{
            __quantum__rt__array_concatenate, __quantum__rt__array_copy,
            __quantum__rt__array_create_1d, __quantum__rt__array_get_element_ptr_1d,
            __quantum__rt__array_get_size_1d, __quantum__rt__array_update_reference_count,
        },
        strings::{__quantum__rt__string_get_data, __quantum__rt__string_update_reference_count},
    };
    use std::ffi::CStr;

    #[test]
    fn test_range_to_string() {
        let input4 = Range {
            start: 0,
            step: 1,
            end: 9,
        };
        let str4 = quantum__rt__range_to_string(input4);
        unsafe {
            assert_eq!(
                CStr::from_ptr(__quantum__rt__string_get_data(str4))
                    .to_str()
                    .unwrap(),
                "0..9"
            );
        }
        let input5 = Range {
            start: 0,
            step: 2,
            end: 12,
        };
        let str5 = quantum__rt__range_to_string(input5);
        unsafe {
            assert_eq!(
                CStr::from_ptr(__quantum__rt__string_get_data(str5))
                    .to_str()
                    .unwrap(),
                "0..2..12"
            );
        }
        unsafe {
            __quantum__rt__string_update_reference_count(str4, -1);
            __quantum__rt__string_update_reference_count(str5, -1);
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
}
