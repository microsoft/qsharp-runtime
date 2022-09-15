// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use crate::update_counts;
use std::{mem::size_of, rc::Rc, usize};

#[allow(clippy::cast_ptr_alignment)]
#[no_mangle]
pub extern "C" fn __quantum__rt__tuple_create(size: u64) -> *mut *const Vec<u8> {
    let mut mem = vec![
        0_u8;
        <usize as std::convert::TryFrom<u64>>::try_from(size)
            .expect("Tuple size too large for `usize` type on this platform.")
            + size_of::<*const Vec<u8>>()
    ];

    unsafe {
        let header = mem.as_mut_ptr().cast::<*const Vec<u8>>();
        *header = Rc::into_raw(Rc::new(mem));
        header.wrapping_add(1)
    }
}

#[allow(clippy::cast_ptr_alignment)]
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__tuple_copy(
    raw_tup: *mut *const Vec<u8>,
    force: bool,
) -> *mut *const Vec<u8> {
    let rc = Rc::from_raw(*(raw_tup).wrapping_sub(1));
    if force || Rc::weak_count(&rc) > 0 {
        let mut copy = rc.as_ref().clone();
        let _ = Rc::into_raw(rc);
        let header = copy.as_mut_ptr().cast::<*const Vec<u8>>();
        *header = Rc::into_raw(Rc::new(copy));
        header.wrapping_add(1)
    } else {
        let _ = Rc::into_raw(Rc::clone(&rc));
        let _ = Rc::into_raw(rc);
        raw_tup
    }
}

#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__tuple_update_reference_count(
    raw_tup: *mut *const Vec<u8>,
    update: i32,
) {
    update_counts(*raw_tup.wrapping_sub(1), update, false);
}

#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__tuple_update_alias_count(
    raw_tup: *mut *const Vec<u8>,
    update: i32,
) {
    update_counts(*raw_tup.wrapping_sub(1), update, true);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_tuple_create() {
        let tup = __quantum__rt__tuple_create(size_of::<u32>() as u64);
        unsafe {
            *tup.cast::<u32>() = 42;
            __quantum__rt__tuple_update_reference_count(tup, -1);
        }
    }

    #[test]
    fn test_tuple_update_reference_count() {
        let tup = __quantum__rt__tuple_create(size_of::<u32>() as u64);
        unsafe {
            let rc = Rc::from_raw(*tup.cast::<*const Vec<u8>>().wrapping_sub(1));
            assert_eq!(Rc::strong_count(&rc), 1);
            __quantum__rt__tuple_update_reference_count(tup, 2);
            assert_eq!(Rc::strong_count(&rc), 3);
            __quantum__rt__tuple_update_reference_count(tup, -2);
            assert_eq!(Rc::strong_count(&rc), 1);
            let _ = Rc::into_raw(rc);
            __quantum__rt__tuple_update_reference_count(tup, -1);
        }
    }

    #[test]
    fn test_tuple_update_alias_count() {
        let tup = __quantum__rt__tuple_create(size_of::<u32>() as u64);
        unsafe {
            let rc = Rc::from_raw(*tup.cast::<*const Vec<u8>>().wrapping_sub(1));
            assert_eq!(Rc::strong_count(&rc), 1);
            assert_eq!(Rc::weak_count(&rc), 0);
            __quantum__rt__tuple_update_alias_count(tup, 2);
            assert_eq!(Rc::weak_count(&rc), 2);
            __quantum__rt__tuple_update_alias_count(tup, -2);
            assert_eq!(Rc::weak_count(&rc), 0);
            let _ = Rc::into_raw(rc);
            __quantum__rt__tuple_update_reference_count(tup, -1);
        }
    }

    #[test]
    fn test_tuple_copy() {
        let tup1 = __quantum__rt__tuple_create(size_of::<u32>() as u64);
        unsafe {
            *tup1.cast::<u32>() = 42;
            let tup2 = __quantum__rt__tuple_copy(tup1, false);
            assert_eq!(tup2, tup1);
            assert_eq!(*tup2.cast::<u32>(), 42);
            __quantum__rt__tuple_update_reference_count(tup2, -1);
            assert_eq!(*tup1.cast::<u32>(), 42);
            let tup3 = __quantum__rt__tuple_copy(tup1, true);
            assert_ne!(tup3, tup1);
            assert_eq!(*tup3.cast::<u32>(), 42);
            __quantum__rt__tuple_update_reference_count(tup3, -1);
            assert_eq!(*tup1.cast::<u32>(), 42);
            __quantum__rt__tuple_update_alias_count(tup1, 1);
            let tup4 = __quantum__rt__tuple_copy(tup1, false);
            assert_ne!(tup4, tup1);
            assert_eq!(*tup4.cast::<u32>(), 42);
            __quantum__rt__tuple_update_reference_count(tup4, -1);
            assert_eq!(*tup1.cast::<u32>(), 42);
            __quantum__rt__tuple_update_alias_count(tup1, -1);
            __quantum__rt__tuple_update_reference_count(tup1, -1);
        }
    }
}
