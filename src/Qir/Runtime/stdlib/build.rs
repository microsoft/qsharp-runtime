// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use std::env;
use std::path::PathBuf;
use std::process::Command;

use llvm_tools::LlvmTools;

fn main() -> Result<(), String> {
    // Compile the LLVM IR bridge file. Requires the llvm-tools-preview component.
    // This is only needed for range support, and this entire build.rs can be dropped when that functionality is
    // no longer needed.
    let out_dir = env::var_os("OUT_DIR")
        .map(PathBuf::from)
        .ok_or_else(|| "Environment variable OUT_DIR not defined.".to_string())?;

    let llvm_tools = LlvmTools::new().map_err(|err| {
        format!(
            "Failed to locate llvm tools: {:?}. Is the llvm-tools-preview component installed? Try using `rustup component add llvm-tools-preview`.",
            err
        )
    })?;

    let llc_path = llvm_tools
        .tool(llvm_tools::exe("llc").to_string().as_str())
        .ok_or_else(|| "Failed to find llc.".to_string())?;
    let llvm_ar_path = llvm_tools
        .tool(llvm_tools::exe("llvm-ar").to_string().as_str())
        .ok_or_else(|| "Failed to find llvm-ar.".to_string())?;
    let lib_name = if cfg!(target_os = "windows") {
        "bridge-rt.lib"
    } else {
        "libbridge-rt.a"
    };

    Command::new(llc_path)
        .args(&[
            "--filetype=obj",
            "./src/bridge-rt.ll",
            "-o",
            &format!("{}/bridge-rt.o", out_dir.display()),
        ])
        .status()
        .map_err(|err| format!("llc failed: {}.", err))?;
    Command::new(llvm_ar_path)
        .args(&[
            "-r",
            &format!("{}/{}", out_dir.display(), lib_name),
            &format!("{}/bridge-rt.o", out_dir.display()),
        ])
        .status()
        .map_err(|err| format!("llvm-ar failed: {}.", err))?;

    println!("cargo:rustc-link-lib=static=bridge-rt");
    println!("cargo:rustc-link-search=native={}", out_dir.display());

    Ok(())
}
