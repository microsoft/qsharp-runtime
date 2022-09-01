// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
#![deny(clippy::all, clippy::pedantic)]

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

/// # Safety
///
/// This function should only be called with an array created by `__quantum__rt__array_*` functions.
/// # Panics
///
/// This function will panic if the item size in the array or the range step size is larger than what can be stored in an
/// u64. This should never happen.
#[no_mangle]
pub unsafe extern "C" fn quantum__rt__array_slice_1d(
    arr: *const QirArray,
    range: Range,
) -> *const QirArray {
    let array = Rc::from_raw(arr);
    let item_size: i64 = array.elem_size.try_into().unwrap();
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
    for i in iter.step_by((step * item_size).try_into().unwrap()) {
        let index = i.try_into().unwrap();
        let mut copy = Vec::new();
        copy.resize(array.elem_size, 0_u8);
        copy.copy_from_slice(&array.data[index..index + array.elem_size]);
        slice.data.append(&mut copy);
    }

    let _ = Rc::into_raw(array);
    Rc::into_raw(Rc::new(slice))
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::strings::{
        __quantum__rt__string_get_data, __quantum__rt__string_update_reference_count,
    };
    use std::ffi::CStr;

    #[test]
    fn test_to_string() {
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
}
