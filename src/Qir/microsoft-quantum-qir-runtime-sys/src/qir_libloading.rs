// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use libloading::{library_filename, Library};
use log;
use std::error::Error;
use std::path::Path;
use tempfile::tempdir;

pub(crate) fn write_library<P: AsRef<Path>>(
    path: P,
    lib: &'static [u8],
) -> Result<(), Box<dyn Error>> {
    log::debug!("Writing {}", path.as_ref().display());
    std::fs::write(path, lib)?;
    Ok(())
}

pub(crate) unsafe fn load_library_bytes(
    base_name: &str,
    lib: &'static [u8],
) -> Result<Library, Box<dyn Error>> {
    let name = library_filename(base_name)
        .into_string()
        .expect("Could not get library name as string");
    let path = tempdir().expect("");
    let filepath = path.as_ref().join(name);
    write_library(&filepath, lib)?;
    let library = load_library(&filepath)?;
    Ok(library)
}

pub(crate) unsafe fn load_library<P: AsRef<Path>>(path: P) -> Result<Library, Box<dyn Error>> {
    log::debug!("Loading {}", path.as_ref().display());
    let library = Library::new(path.as_ref().as_os_str())?;
    
    #[cfg(feature = "llvm-libloading")]
    load_library_with_llvm(path);

    Ok(library)
}

#[cfg(feature = "llvm-libloading")]
fn load_library_with_llvm<P: AsRef<Path>>(path: P) {
    let library_path = path
        .as_ref()
        .to_str()
        .expect("Could not convert library path to &str");
    let was_loaded_by_llvm = inkwell::support::load_library_permanently(library_path);
    if was_loaded_by_llvm {
        log::error!("Failed to load {} into LLVM", library_path);
    } else {
        log::debug!("Loaded {} into LLVM", library_path);
    }
}
