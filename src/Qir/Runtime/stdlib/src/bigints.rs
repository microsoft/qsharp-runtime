// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
#![deny(clippy::all, clippy::pedantic)]

use crate::update_counts;
use num_bigint::BigInt;
use std::{mem::ManuallyDrop, rc::Rc};

#[no_mangle]
pub extern "C" fn __quantum__rt__bigint_create_i64(input: i64) -> *const BigInt {
    Rc::into_raw(Rc::new(input.into()))
}

/// # Safety
///
/// This function expects the second argument to be a well-formed C-style array of signed big-endian bytes
/// with the size of that array passed as the first argument.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__bigint_create_array(
    size: u32,
    input: *const u8,
) -> *const BigInt {
    Rc::into_raw(Rc::new(BigInt::from_signed_bytes_be(
        std::slice::from_raw_parts(input, size as usize),
    )))
}

/// # Safety
///
/// This function should only be called with a QIR bigint created by the `__quantum__rt__bigint_*` functions.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__bigint_get_data(input: *const BigInt) -> *const u8 {
    ManuallyDrop::new((*input).to_signed_bytes_be()).as_ptr()
}

/// # Safety
///
/// This function should only be called with a QIR bigint created by the `__quantum__rt__bigint_*` functions.
/// # Panics
///
/// This function will panic if the length of the QIR bigint as an array is larger than can fit in a u32.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__bigint_get_length(input: *const BigInt) -> u32 {
    let size = (*input).to_signed_bytes_be().len();
    size.try_into().unwrap()
}

/// # Safety
///
/// This function should only be called with a QIR bigint created by the `__quantum__rt__bigint_*` functions.
/// If the reference count after update is less than or equal to zero, the QIR bigint is cleaned up
/// and the pointer is no longer valid.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__bigint_update_reference_count(
    input: *const BigInt,
    update: i32,
) {
    update_counts(input, update, false);
}

/// # Safety
///
/// This function should only be called with a QIR bigint created by the `__quantum__rt__bigint_*` functions.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__bigint_negate(input: *const BigInt) -> *const BigInt {
    Rc::into_raw(Rc::new(&(*input) * -1))
}

/// # Safety
///
/// This function should only be called with a QIR bigint created by the `__quantum__rt__bigint_*` functions.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__bigint_add(
    lhs: *const BigInt,
    rhs: *const BigInt,
) -> *const BigInt {
    Rc::into_raw(Rc::new(&(*lhs) + &(*rhs)))
}

/// # Safety
///
/// This function should only be called with a QIR bigint created by the `__quantum__rt__bigint_*` functions.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__bigint_subtract(
    lhs: *const BigInt,
    rhs: *const BigInt,
) -> *const BigInt {
    Rc::into_raw(Rc::new(&(*lhs) - &(*rhs)))
}

/// # Safety
///
/// This function should only be called with a QIR bigint created by the `__quantum__rt__bigint_*` functions.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__bigint_multiply(
    lhs: *const BigInt,
    rhs: *const BigInt,
) -> *const BigInt {
    Rc::into_raw(Rc::new(&(*lhs) * &(*rhs)))
}

/// # Safety
///
/// This function should only be called with a QIR bigint created by the `__quantum__rt__bigint_*` functions.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__bigint_divide(
    lhs: *const BigInt,
    rhs: *const BigInt,
) -> *const BigInt {
    Rc::into_raw(Rc::new(&(*lhs) / &(*rhs)))
}

/// # Safety
///
/// This function should only be called with a QIR bigint created by the `__quantum__rt__bigint_*` functions.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__bigint_modulus(
    lhs: *const BigInt,
    rhs: *const BigInt,
) -> *const BigInt {
    Rc::into_raw(Rc::new(&(*lhs) % &(*rhs)))
}

/// # Safety
///
/// This function should only be called with a QIR bigint created by the `__quantum__rt__bigint_*` functions.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__bigint_power(
    base: *const BigInt,
    exponent: u32,
) -> *const BigInt {
    Rc::into_raw(Rc::new((*base).pow(exponent)))
}

/// # Safety
///
/// This function should only be called with a QIR bigint created by the `__quantum__rt__bigint_*` functions.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__bigint_bitand(
    lhs: *const BigInt,
    rhs: *const BigInt,
) -> *const BigInt {
    Rc::into_raw(Rc::new(&(*lhs) & &(*rhs)))
}

/// # Safety
///
/// This function should only be called with a QIR bigint created by the `__quantum__rt__bigint_*` functions.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__bigint_bitor(
    lhs: *const BigInt,
    rhs: *const BigInt,
) -> *const BigInt {
    Rc::into_raw(Rc::new(&(*lhs) | &(*rhs)))
}

/// # Safety
///
/// This function should only be called with a QIR bigint created by the `__quantum__rt__bigint_*` functions.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__bigint_bitxor(
    lhs: *const BigInt,
    rhs: *const BigInt,
) -> *const BigInt {
    Rc::into_raw(Rc::new(&(*lhs) ^ &(*rhs)))
}

/// # Safety
///
/// This function should only be called with a QIR bigint created by the `__quantum__rt__bigint_*` functions.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__bigint_bitnot(input: *const BigInt) -> *const BigInt {
    Rc::into_raw(Rc::new(!&(*input)))
}

/// # Safety
///
/// This function should only be called with a QIR bigint created by the `__quantum__rt__bigint_*` functions.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__bigint_shiftleft(
    input: *const BigInt,
    amount: u64,
) -> *const BigInt {
    Rc::into_raw(Rc::new(&(*input) << amount))
}

/// # Safety
///
/// This function should only be called with a QIR bigint created by the `__quantum__rt__bigint_*` functions.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__bigint_shiftright(
    input: *const BigInt,
    amount: u64,
) -> *const BigInt {
    Rc::into_raw(Rc::new(&(*input) >> amount))
}

/// # Safety
///
/// This function should only be called with a QIR bigint created by the `__quantum__rt__bigint_*` functions.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__bigint_equal(
    lhs: *const BigInt,
    rhs: *const BigInt,
) -> bool {
    (*lhs) == (*rhs)
}

/// # Safety
///
/// This function should only be called with a QIR bigint created by the `__quantum__rt__bigint_*` functions.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__bigint_greater(
    lhs: *const BigInt,
    rhs: *const BigInt,
) -> bool {
    (*lhs) > (*rhs)
}

/// # Safety
///
/// This function should only be called with a QIR bigint created by the `__quantum__rt__bigint_*` functions.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__bigint_greater_eq(
    lhs: *const BigInt,
    rhs: *const BigInt,
) -> bool {
    (*lhs) >= (*rhs)
}

#[cfg(test)]
mod tests {
    use std::convert::TryInto;

    use super::*;

    #[test]
    fn test_bigint_create_from_int() {
        let bigint_0 = __quantum__rt__bigint_create_i64(42);
        unsafe {
            assert_eq!(*bigint_0, (42).try_into().unwrap());
            // Note that the test must decrement the reference count on any created items to ensure
            // they are cleaned up and tests can pass with address sanitizer.
            __quantum__rt__bigint_update_reference_count(bigint_0, -1);
        }
    }

    #[test]
    fn test_bigint_create_from_array() {
        let bytes = 42_i64.to_be_bytes();
        unsafe {
            let bigint_1 =
                __quantum__rt__bigint_create_array(bytes.len().try_into().unwrap(), bytes.as_ptr());
            assert_eq!(*bigint_1, (42).try_into().unwrap());
            __quantum__rt__bigint_update_reference_count(bigint_1, -1);
        }
    }

    #[test]
    fn test_bigint_arithmetic() {
        let bigint_0 = __quantum__rt__bigint_create_i64(42);
        let bigint_1 = __quantum__rt__bigint_create_i64(3);
        unsafe {
            let bigint_2 = __quantum__rt__bigint_add(bigint_0, bigint_1);
            assert_eq!(*bigint_2, (45).try_into().unwrap());
            let bigint_3 = __quantum__rt__bigint_subtract(bigint_2, bigint_1);
            assert_eq!(*bigint_3, (42).try_into().unwrap());
            let bigint_4 = __quantum__rt__bigint_divide(bigint_3, bigint_1);
            assert_eq!(*bigint_4, (14).try_into().unwrap());
            let bigint_5 = __quantum__rt__bigint_multiply(bigint_4, bigint_1);
            assert_eq!(*bigint_5, (42).try_into().unwrap());
            let bigint_6 = __quantum__rt__bigint_modulus(bigint_5, bigint_1);
            assert_eq!(*bigint_6, (0).try_into().unwrap());
            let bigint_7 = __quantum__rt__bigint_negate(bigint_5);
            assert_eq!(*bigint_7, (-42).try_into().unwrap());
            let bigint_8 = __quantum__rt__bigint_power(bigint_7, 3);
            assert_eq!(*bigint_8, (-74088).try_into().unwrap());
            __quantum__rt__bigint_update_reference_count(bigint_0, -1);
            __quantum__rt__bigint_update_reference_count(bigint_1, -1);
            __quantum__rt__bigint_update_reference_count(bigint_2, -1);
            __quantum__rt__bigint_update_reference_count(bigint_3, -1);
            __quantum__rt__bigint_update_reference_count(bigint_4, -1);
            __quantum__rt__bigint_update_reference_count(bigint_5, -1);
            __quantum__rt__bigint_update_reference_count(bigint_6, -1);
            __quantum__rt__bigint_update_reference_count(bigint_7, -1);
            __quantum__rt__bigint_update_reference_count(bigint_8, -1);
        }
    }

    #[test]
    fn test_bigint_bitops() {
        let bigint_0 = __quantum__rt__bigint_create_i64(42);
        let bigint_1 = __quantum__rt__bigint_create_i64(3);
        unsafe {
            let bigint_2 = __quantum__rt__bigint_bitand(bigint_0, bigint_1);
            assert_eq!(*bigint_2, (2).try_into().unwrap());
            let bigint_3 = __quantum__rt__bigint_bitor(bigint_0, bigint_1);
            assert_eq!(*bigint_3, (43).try_into().unwrap());
            let bigint_4 = __quantum__rt__bigint_bitxor(bigint_0, bigint_3);
            assert_eq!(*bigint_4, (1).try_into().unwrap());
            let bigint_5 = __quantum__rt__bigint_bitnot(bigint_4);
            assert_eq!(*bigint_5, (-2).try_into().unwrap());
            let bigint_6 = __quantum__rt__bigint_shiftleft(bigint_0, 2);
            assert_eq!(*bigint_6, (168).try_into().unwrap());
            let bigint_7 = __quantum__rt__bigint_shiftright(bigint_6, 3);
            assert_eq!(*bigint_7, (21).try_into().unwrap());
            __quantum__rt__bigint_update_reference_count(bigint_0, -1);
            __quantum__rt__bigint_update_reference_count(bigint_1, -1);
            __quantum__rt__bigint_update_reference_count(bigint_2, -1);
            __quantum__rt__bigint_update_reference_count(bigint_3, -1);
            __quantum__rt__bigint_update_reference_count(bigint_4, -1);
            __quantum__rt__bigint_update_reference_count(bigint_5, -1);
            __quantum__rt__bigint_update_reference_count(bigint_6, -1);
            __quantum__rt__bigint_update_reference_count(bigint_7, -1);
        }
    }

    #[test]
    fn test_bigint_comparisons() {
        let bigint_0 = __quantum__rt__bigint_create_i64(42);
        let bigint_1 = __quantum__rt__bigint_create_i64(43);
        let bigint_2 = __quantum__rt__bigint_create_i64(42);
        unsafe {
            assert!(__quantum__rt__bigint_greater(bigint_1, bigint_0));
            assert!(!__quantum__rt__bigint_greater(bigint_0, bigint_1));
            assert!(__quantum__rt__bigint_equal(bigint_0, bigint_2));
            assert!(__quantum__rt__bigint_greater_eq(bigint_0, bigint_2));
            assert!(__quantum__rt__bigint_greater_eq(bigint_1, bigint_2));
            assert!(!__quantum__rt__bigint_greater_eq(bigint_0, bigint_1));
            __quantum__rt__bigint_update_reference_count(bigint_0, -1);
            __quantum__rt__bigint_update_reference_count(bigint_1, -1);
            __quantum__rt__bigint_update_reference_count(bigint_2, -1);
        }
    }
}
