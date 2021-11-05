// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use lazy_static::lazy_static;

use libloading::Library;

#[cfg(target_os = "linux")]
const FOUNDATION_BYTES: &'static [u8] = include_bytes!(concat!(
    env!("OUT_DIR"),
    "/build/lib/QSharpFoundation/libMicrosoft.Quantum.Qir.QSharp.Foundation.so"
));

#[cfg(target_os = "macos")]
const FOUNDATION_BYTES: &'static [u8] = include_bytes!(concat!(
    env!("OUT_DIR"),
    "/build/lib/QSharpFoundation/libMicrosoft.Quantum.Qir.QSharp.Foundation.dylib"
));

#[cfg(target_os = "windows")]
const FOUNDATION_BYTES: &'static [u8] = include_bytes!(concat!(
    env!("OUT_DIR"),
    "/build/lib/QSharpFoundation/Microsoft.Quantum.Qir.QSharp.Foundation.dll"
));

lazy_static! {
    pub(crate) static ref FOUNDATION_LIBRARY: Library = unsafe {
        crate::qir_libloading::load_library_bytes(
            "Microsoft.Quantum.Qir.QSharp.Foundation",
            FOUNDATION_BYTES,
        )
        .unwrap()
    };
}

pub struct QSharpFoundation {}

impl QSharpFoundation {
    pub fn new() -> QSharpFoundation {
        let _ = FOUNDATION_LIBRARY;
        QSharpFoundation {}
    }
}

#[cfg(test)]
mod tests {
    use crate::foundation::QSharpFoundation;

    #[test]
    fn library_loads_on_new() {
        let _ = QSharpFoundation::new();
    }
    #[test]
    fn library_can_be_initialized_multiple_times() {
        let _ = QSharpFoundation::new();
        let _ = QSharpFoundation::new();
        let _ = QSharpFoundation::new();
    }
}
