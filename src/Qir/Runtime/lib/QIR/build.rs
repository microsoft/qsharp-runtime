// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

fn main() {
    // Compile the LLVM IR bridge file.
    let mut clang = cc::Build::new();
    if cfg!(target_os = "linux") {
        clang.compiler(which::which("clang-13").expect("Failed to find clang-13 in path!"));
        println!("cargo:rustc-cdylib-link-arg=-undefined=__quantum__rt__array_slice_1d");
        println!("cargo:rustc-cdylib-link-arg=-undefined=__quantum__rt__range_to_string");
    } else if cfg!(target_os = "windows") {
        clang.compiler(which::which("clang.exe").expect("Failed to find clang.exe in path!"));
        println!("cargo:rustc-cdylib-link-arg=/export:__quantum__rt__array_slice_1d");
        println!("cargo:rustc-cdylib-link-arg=/export:__quantum__rt__range_to_string");
    } else if cfg!(target_os = "macos") {
        // Use default compiler on MacOS
        println!("cargo:rustc-cdylib-link-arg=-u __quantum__rt__array_slice_1d");
        println!("cargo:rustc-cdylib-link-arg=-u __quantum__rt__range_to_string");
        println!("cargo:rustc-cdylib-link-arg=-lbridge-rt");
    }
    clang
        .file("src/bridge-rt.ll")
        .flag("-Wno-override-module")
        .compile("bridge-rt");
}
