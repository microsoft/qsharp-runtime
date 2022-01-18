// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

fn main() {
    // Compile the LLVM IR bridge file.
    let mut clang = cc::Build::new();
    if cfg!(target_os = "linux") {
        clang.compiler(which::which("clang-13").expect("Failed to find clang-11 in path!"));
    } else if cfg!(target_os = "windows") {
        clang.compiler(which::which("clang.exe").expect("Failed to find clang.exe in path!"));
    } else if cfg!(target_os = "macos") {
        // Use default compiler on MacOS
    }
    clang
        .file("src/bridge-rt.ll")
        .flag("-Wno-override-module")
        .compile("bridge-rt");
}
