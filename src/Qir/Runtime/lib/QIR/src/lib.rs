#![deny(clippy::all, clippy::pedantic)]

use num_bigint::BigInt;
use std::{
    cell::RefCell,
    ffi::{CStr, CString},
    mem::{size_of, ManuallyDrop},
    os::raw::{c_char, c_double},
    rc::{Rc, Weak},
    usize,
};

// Rust Implementation for Quantum Intermediate Representation

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

#[derive(Copy, Clone)]
#[repr(i8)]
pub enum Pauli {
    I = 0,
    X = 1,
    Z = 2,
    Y = 3,
}

#[repr(C)]
pub struct Range {
    start: i64,
    step: i64,
    end: i64,
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
    panic!("{}", (&*str).to_str().expect("Unable to convert string"));
}

/// # Safety
///
/// This function should only be called with a string created by `__quantum__rt__string_*` functions.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__message(str: *const CString) {
    println!("{}", (&*str).to_str().expect("Unable to convert string"));
}

/// # Safety
///
/// This function should only be called with a valid, null-terminated, C-style string.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__string_create(str: *mut c_char) -> *const CString {
    let cstring = CString::new(CStr::from_ptr(str).to_owned()).expect("Failed to create %String");
    Rc::into_raw(Rc::new(cstring))
}

/// # Safety
///
/// This function should only be called with a string created by `__quantum__rt__string_*` functions.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__string_get_data(str: *const CString) -> *const c_char {
    (&*str).as_bytes_with_nul().as_ptr().cast::<i8>()
}

/// # Safety
///
/// This function should only be called with a string created by `__quantum__rt__string_*` functions.
/// # Panics
///
/// Will panic if length is larger than will fit in an 32-bit integer.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__string_get_length(str: *const CString) -> u32 {
    (&*str).as_bytes().len().try_into().unwrap()
}

/// # Safety
///
/// This function should only be called with a string created by `__quantum__rt__string_*` functions.
/// If the reference count after update is less than or equal to zero, the string is cleaned up
/// and the pointer is no longer valid.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__string_update_reference_count(
    str: *const CString,
    update: i32,
) {
    update_counts(str, update, false);
}

/// # Safety
///
/// This function should only be called with strings created by `__quantum__rt__string_*` functions.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__string_concatenate(
    s1: *const CString,
    s2: *const CString,
) -> *const CString {
    let mut new_str = (&*s1)
        .clone()
        .into_string()
        .expect("Unable to convert string");

    new_str.push_str(
        (&*s2)
            .clone()
            .into_string()
            .expect("Unable to convert string")
            .as_str(),
    );

    Rc::into_raw(Rc::new(
        CString::new(new_str.as_bytes()).expect("Unable to convert string"),
    ))
}

/// # Safety
///
/// This function should only be called with strings created by `__quantum__rt__string_*` functions.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__string_equal(
    s1: *const CString,
    s2: *const CString,
) -> bool {
    (&*s1).to_str().expect("Unable to convert string")
        == (&*s2).to_str().expect("Unable to convert string")
}

fn convert<T>(input: &T) -> *const CString
where
    T: Sized + ToString,
{
    unsafe {
        __quantum__rt__string_create(
            CString::new(input.to_string())
                .unwrap()
                .as_bytes_with_nul()
                .as_ptr() as *mut i8,
        )
    }
}

#[no_mangle]
pub extern "C" fn __quantum__rt__int_to_string(input: i64) -> *const CString {
    convert(&input)
}

#[no_mangle]
pub extern "C" fn __quantum__rt__double_to_string(input: c_double) -> *const CString {
    if (input.floor() - input.ceil()).abs() < c_double::EPSILON {
        convert(&format!("{:.1}", input))
    } else {
        convert(&input)
    }
}

#[no_mangle]
pub extern "C" fn __quantum__rt__bool_to_string(input: bool) -> *const CString {
    convert(&input)
}

#[no_mangle]
pub extern "C" fn __quantum__rt__pauli_to_string(input: Pauli) -> *const CString {
    match input {
        Pauli::I => convert(&"PauliI"),
        Pauli::X => convert(&"PauliX"),
        Pauli::Y => convert(&"PauliY"),
        Pauli::Z => convert(&"PauliZ"),
    }
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
/// This function should only be called with a QIR bigint created by the `__quantum__rt__bigint_*` functions.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__bigint_to_string(input: *const BigInt) -> *const CString {
    convert(&*input)
}

/// # Panics
///
/// Will panic if the given size is larger than pointer width for the platform.
#[allow(clippy::cast_ptr_alignment)]
#[no_mangle]
pub extern "C" fn __quantum__rt__tuple_create(size: u64) -> *mut *const Vec<u8> {
    let mut mem = vec![
        0_u8;
        <usize as std::convert::TryFrom<u64>>::try_from(size).unwrap()
            + size_of::<*const Vec<u8>>()
    ];

    unsafe {
        let header = mem.as_mut_ptr().cast::<*const std::vec::Vec<u8>>();
        *header = Rc::into_raw(Rc::new(mem));
        header.wrapping_add(1)
    }
}

/// # Safety
///
/// This function should only be called with a tuple created by `__quantum__rt__tuple_*` functions.
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
        let header = copy.as_mut_ptr().cast::<*const std::vec::Vec<u8>>();
        *header = Rc::into_raw(Rc::new(copy));
        header.wrapping_add(1)
    } else {
        let _ = Rc::into_raw(Rc::clone(&rc));
        let _ = Rc::into_raw(rc);
        raw_tup
    }
}

/// # Safety
///
/// This function should only be called with a tuple created by `__quantum__rt__tuple_*` functions.
/// If the reference count after update is less than or equal to zero, the tuple is be cleaned up
/// and the pointer is no longer be valid.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__tuple_update_reference_count(
    raw_tup: *mut *const Vec<u8>,
    update: i32,
) {
    update_counts(*raw_tup.wrapping_sub(1), update, false);
}

/// # Safety
///
/// This function should only be called with a tuple created by `__quantum__rt__tuple_*` functions.
#[no_mangle]
pub unsafe extern "C" fn __quantum__rt__tuple_update_alias_count(
    raw_tup: *mut *const Vec<u8>,
    update: i32,
) {
    update_counts(*raw_tup.wrapping_sub(1), update, true);
}

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
/// This function will panic if the item size in the array or the range step size is larger than what can be stored in an
/// u64. This should never happen.
#[no_mangle]
pub unsafe extern "C" fn quantum__rt__array_slice_1d(
    arr: *const (usize, Vec<u8>),
    range: Range,
) -> *const (usize, Vec<u8>) {
    let array = Rc::from_raw(arr);
    let item_size: i64 = array.0.try_into().unwrap();
    let mut slice = (array.0, Vec::new());
    let iter: Box<dyn Iterator<Item = i64>> = if range.step > 0 {
        Box::new(range.start * item_size..=range.end * item_size)
    } else {
        Box::new((range.end * item_size..=range.start * item_size).rev())
    };

    let step: i64 = range.step.abs();
    for i in iter.step_by((step * item_size).try_into().unwrap()) {
        let index = i.try_into().unwrap();
        let mut copy = Vec::new();
        copy.resize(array.0, 0_u8);
        copy.copy_from_slice(&array.1[index..index + array.0]);
        slice.1.append(&mut copy);
    }

    let _ = Rc::into_raw(array);
    Rc::into_raw(Rc::new(slice))
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

#[no_mangle]
pub extern "C" fn __quantum__rt__array_start_record_output() {
    println!("RESULT\tARRAY_START");
}

#[no_mangle]
pub extern "C" fn __quantum__rt__array_end_record_output() {
    println!("RESULT\tARRAY_END");
}

#[no_mangle]
pub extern "C" fn __quantum__rt__tuple_start_record_output() {
    println!("RESULT\tTUPLE_START");
}

#[no_mangle]
pub extern "C" fn __quantum__rt__tuple_end_record_output() {
    println!("RESULT\tTUPLE_END");
}

#[no_mangle]
pub extern "C" fn __quantum__rt__int_record_output(val: i64) {
    println!("RESULT\t{}", val);
}

#[no_mangle]
pub extern "C" fn __quantum__rt__double_record_output(val: c_double) {
    println!(
        "RESULT\t{}",
        if (val.floor() - val.ceil()).abs() < c_double::EPSILON {
            format!("{:.1}", val)
        } else {
            format!("{}", val)
        }
    );
}

#[no_mangle]
pub extern "C" fn __quantum__rt__bool_record_output(val: bool) {
    println!("RESULT\t{}", val);
}

#[cfg(test)]
mod tests {
    use crate::{
        Pauli, Range, __quantum__rt__array_concatenate, __quantum__rt__array_copy,
        __quantum__rt__array_create_1d, __quantum__rt__array_get_element_ptr_1d,
        __quantum__rt__array_get_size_1d, __quantum__rt__array_update_reference_count,
        __quantum__rt__bigint_add, __quantum__rt__bigint_create_array,
        __quantum__rt__bigint_create_i64, __quantum__rt__bigint_equal,
        __quantum__rt__bigint_greater, __quantum__rt__bigint_multiply,
        __quantum__rt__bigint_negate, __quantum__rt__bigint_shiftleft,
        __quantum__rt__bigint_shiftright, __quantum__rt__bigint_to_string,
        __quantum__rt__bigint_update_reference_count, __quantum__rt__bool_to_string,
        __quantum__rt__double_to_string, __quantum__rt__fail, __quantum__rt__int_to_string,
        __quantum__rt__memory_allocate, __quantum__rt__message, __quantum__rt__pauli_to_string,
        __quantum__rt__string_concatenate, __quantum__rt__string_create,
        __quantum__rt__string_equal, __quantum__rt__string_get_data,
        __quantum__rt__string_get_length, __quantum__rt__string_update_reference_count,
        __quantum__rt__tuple_copy, __quantum__rt__tuple_create,
        __quantum__rt__tuple_update_alias_count, __quantum__rt__tuple_update_reference_count,
        c_char, quantum__rt__array_slice_1d, quantum__rt__range_to_string, size_of,
    };
    use std::ffi::{CStr, CString};
    use std::rc::Rc;

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

    #[test]
    fn test_string_create() {
        let orig_str = CString::new("Test String").unwrap();
        let str = unsafe {
            __quantum__rt__string_create(orig_str.as_bytes_with_nul().as_ptr() as *mut c_char)
        };
        // string_create should make a copy, not consume original.
        assert_eq!(orig_str.to_str().unwrap(), "Test String");
        drop(orig_str);
        assert!(!str.is_null());
        unsafe {
            // Copy should be valid after original is dropped.
            assert_eq!(
                Rc::from_raw(str)
                    .to_str()
                    .expect("Unable to convert input string"),
                "Test String"
            );
        }
    }

    #[test]
    fn test_string_get_data() {
        let str = unsafe {
            __quantum__rt__string_create(
                CString::new("Data").unwrap().as_bytes_with_nul().as_ptr() as *mut i8
            )
        };
        unsafe {
            assert_eq!(
                CStr::from_ptr(__quantum__rt__string_get_data(str))
                    .to_str()
                    .unwrap(),
                "Data"
            );
        }
        unsafe {
            __quantum__rt__string_update_reference_count(str, -1);
        }
    }

    #[test]
    fn test_string_get_length() {
        let str = unsafe {
            __quantum__rt__string_create(
                CString::new("Data").unwrap().as_bytes_with_nul().as_ptr() as *mut i8
            )
        };
        assert_eq!(unsafe { __quantum__rt__string_get_length(str) }, 4);
        unsafe {
            __quantum__rt__string_update_reference_count(str, -1);
        }
    }

    #[test]
    fn test_string_update_reference_count() {
        unsafe {
            let str = __quantum__rt__string_create(
                CString::new("Data").unwrap().as_bytes_with_nul().as_ptr() as *mut i8,
            );
            let rc = Rc::from_raw(str);
            assert_eq!(Rc::strong_count(&rc), 1);
            __quantum__rt__string_update_reference_count(str, 2);
            assert_eq!(Rc::strong_count(&rc), 3);
            __quantum__rt__string_update_reference_count(str, -2);
            assert_eq!(Rc::strong_count(&rc), 1);
            let _ = Rc::into_raw(rc);
            __quantum__rt__string_update_reference_count(str, -1);
        }
    }

    #[test]
    fn test_string_concatenate() {
        unsafe {
            let str1 = __quantum__rt__string_create(
                CString::new("Hello").unwrap().as_bytes_with_nul().as_ptr() as *mut i8,
            );
            let str2 = __quantum__rt__string_create(
                CString::new(", World!")
                    .unwrap()
                    .as_bytes_with_nul()
                    .as_ptr() as *mut i8,
            );
            let str3 = __quantum__rt__string_concatenate(str1, str2);
            // Concatenated string should have combined value.
            let rc = Rc::from_raw(str3);
            assert_eq!(Rc::strong_count(&rc), 1);
            let _ = Rc::into_raw(rc);
            assert_eq!(
                CStr::from_ptr(__quantum__rt__string_get_data(str3))
                    .to_str()
                    .unwrap(),
                "Hello, World!"
            );
            __quantum__rt__string_update_reference_count(str3, -1);
            // After decrement and drop, original strings should still be valid.
            let rc = Rc::from_raw(str2);
            assert_eq!(Rc::strong_count(&rc), 1);
            let _ = Rc::into_raw(rc);
            assert_eq!(
                CStr::from_ptr(__quantum__rt__string_get_data(str2))
                    .to_str()
                    .unwrap(),
                ", World!"
            );
            __quantum__rt__string_update_reference_count(str2, -1);
            let rc = Rc::from_raw(str1);
            assert_eq!(Rc::strong_count(&rc), 1);
            let _ = Rc::into_raw(rc);
            assert_eq!(
                CStr::from_ptr(__quantum__rt__string_get_data(str1))
                    .to_str()
                    .unwrap(),
                "Hello"
            );
            __quantum__rt__string_update_reference_count(str1, -1);
        }
    }

    #[test]
    fn test_string_equal() {
        unsafe {
            let str1 = __quantum__rt__string_create(
                CString::new("Data").unwrap().as_bytes_with_nul().as_ptr() as *mut i8,
            );
            let str2 = __quantum__rt__string_create(
                CString::new("Data").unwrap().as_bytes_with_nul().as_ptr() as *mut i8,
            );
            let str3 = __quantum__rt__string_create(
                CString::new("Not Data")
                    .unwrap()
                    .as_bytes_with_nul()
                    .as_ptr() as *mut i8,
            );
            assert!(__quantum__rt__string_equal(str1, str2));
            assert!(!__quantum__rt__string_equal(str1, str3));
            // Confirm data is still valid and not consumed by the check.
            let rc = Rc::from_raw(str3);
            assert_eq!(Rc::strong_count(&rc), 1);
            let _ = Rc::into_raw(rc);
            assert_eq!(
                CStr::from_ptr(__quantum__rt__string_get_data(str3))
                    .to_str()
                    .unwrap(),
                "Not Data"
            );
            __quantum__rt__string_update_reference_count(str3, -1);
            let rc = Rc::from_raw(str2);
            assert_eq!(Rc::strong_count(&rc), 1);
            let _ = Rc::into_raw(rc);
            assert_eq!(
                CStr::from_ptr(__quantum__rt__string_get_data(str2))
                    .to_str()
                    .unwrap(),
                "Data"
            );
            __quantum__rt__string_update_reference_count(str2, -1);
            let rc = Rc::from_raw(str1);
            assert_eq!(Rc::strong_count(&rc), 1);
            let _ = Rc::into_raw(rc);
            assert_eq!(
                CStr::from_ptr(__quantum__rt__string_get_data(str1))
                    .to_str()
                    .unwrap(),
                "Data"
            );
            __quantum__rt__string_update_reference_count(str1, -1);
        }
    }

    #[test]
    fn test_to_string() {
        let input0 = 42;
        let str0 = __quantum__rt__int_to_string(input0);
        unsafe {
            assert_eq!(
                CStr::from_ptr(__quantum__rt__string_get_data(str0))
                    .to_str()
                    .unwrap(),
                "42"
            );
        }
        let input1 = 4.2;
        let str1 = __quantum__rt__double_to_string(input1);
        unsafe {
            assert_eq!(
                CStr::from_ptr(__quantum__rt__string_get_data(str1))
                    .to_str()
                    .unwrap(),
                "4.2"
            );
        }
        let input2 = false;
        let str2 = __quantum__rt__bool_to_string(input2);
        unsafe {
            assert_eq!(
                CStr::from_ptr(__quantum__rt__string_get_data(str2))
                    .to_str()
                    .unwrap(),
                "false"
            );
        }
        let input3 = Pauli::Z;
        let str3 = __quantum__rt__pauli_to_string(input3);
        unsafe {
            assert_eq!(
                CStr::from_ptr(__quantum__rt__string_get_data(str3))
                    .to_str()
                    .unwrap(),
                "PauliZ"
            );
        }
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
        let input6 = __quantum__rt__bigint_create_i64(400_002);
        unsafe {
            let str6 = __quantum__rt__bigint_to_string(input6);
            assert_eq!(
                CStr::from_ptr(__quantum__rt__string_get_data(str6))
                    .to_str()
                    .unwrap(),
                "400002"
            );

            __quantum__rt__string_update_reference_count(str0, -1);
            __quantum__rt__string_update_reference_count(str1, -1);
            __quantum__rt__string_update_reference_count(str2, -1);
            __quantum__rt__string_update_reference_count(str3, -1);
            __quantum__rt__string_update_reference_count(str4, -1);
            __quantum__rt__string_update_reference_count(str5, -1);
            __quantum__rt__string_update_reference_count(str6, -1);
            __quantum__rt__bigint_update_reference_count(input6, -1);
        }
    }

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
            let rc = Rc::from_raw(*tup.cast::<*const std::vec::Vec<u8>>().wrapping_sub(1));
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
            let rc = Rc::from_raw(*tup.cast::<*const std::vec::Vec<u8>>().wrapping_sub(1));
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
            let arr6 = quantum__rt__array_slice_1d(arr5, Range {start: 0, step: 1, end: -1});
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

    #[test]
    fn test_bigint_basics() {
        let bigint_0 = __quantum__rt__bigint_create_i64(42);
        let bytes = 42_i64.to_be_bytes();
        unsafe {
            let bigint_1 =
                __quantum__rt__bigint_create_array(bytes.len().try_into().unwrap(), bytes.as_ptr());
            assert!(__quantum__rt__bigint_equal(bigint_0, bigint_1));
            let bigint_2 = __quantum__rt__bigint_add(bigint_0, bigint_1);
            let bigint_3 = __quantum__rt__bigint_create_i64(84);
            assert!((*bigint_2) == 84.try_into().unwrap());
            assert!(__quantum__rt__bigint_equal(bigint_2, bigint_3));
            let bigint_4 = __quantum__rt__bigint_negate(bigint_0);
            assert!((*bigint_4) == (-42).try_into().unwrap());
            let bigint_5 = __quantum__rt__bigint_add(bigint_2, bigint_4);
            assert!((*bigint_5) == (42).try_into().unwrap());
            assert!(__quantum__rt__bigint_greater(bigint_2, bigint_5));
            assert!(__quantum__rt__bigint_greater(bigint_5, bigint_4));
            let bigint_6 = __quantum__rt__bigint_create_i64(2);
            let bigint_7 = __quantum__rt__bigint_multiply(bigint_5, bigint_6);
            assert!(__quantum__rt__bigint_equal(bigint_7, bigint_2));
            let bigint_8 = __quantum__rt__bigint_shiftleft(bigint_5, 1);
            assert!(__quantum__rt__bigint_equal(bigint_7, bigint_8));
            let bigint_9 = __quantum__rt__bigint_shiftright(bigint_8, 1);
            assert!(__quantum__rt__bigint_equal(bigint_9, bigint_0));
            __quantum__rt__bigint_update_reference_count(bigint_0, -1);
            __quantum__rt__bigint_update_reference_count(bigint_1, -1);
            __quantum__rt__bigint_update_reference_count(bigint_2, -1);
            __quantum__rt__bigint_update_reference_count(bigint_3, -1);
            __quantum__rt__bigint_update_reference_count(bigint_4, -1);
            __quantum__rt__bigint_update_reference_count(bigint_5, -1);
            __quantum__rt__bigint_update_reference_count(bigint_6, -1);
            __quantum__rt__bigint_update_reference_count(bigint_7, -1);
            __quantum__rt__bigint_update_reference_count(bigint_8, -1);
            __quantum__rt__bigint_update_reference_count(bigint_9, -1);
        }
    }
}
