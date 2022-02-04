// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use cmake::Config;
use std::boxed::Box;
use std::env;
use std::error::Error;

fn main() -> Result<(), Box<dyn Error>> {
    println!("cargo:rerun-if-env-changed=TARGET");
    println!("cargo:rerun-if-changed=build.rs");

    for (key, value) in env::vars() {
        println!("{}: {}", key, value);
    }
    if cfg!(target_os = "windows") {
        let path_to_runtime_src = "..\\Runtime";
        compile_runtime_libraries(path_to_runtime_src)?;     
    } else {
        let path_to_runtime_src = "../Runtime";
        compile_runtime_libraries(path_to_runtime_src)?;
    }

    Ok(())
}

fn compile_runtime_libraries(path_to_runtime_src: &str) -> Result<(), Box<dyn Error>> {
    let mut config = Config::new(path_to_runtime_src);
    
    if cfg!(target_os = "windows") {
        config.static_crt(true);
    }

    set_compiler(&mut config)?;
    set_profile(&mut config)?;

    config.generator("Ninja");

    let _ = config.build();
    Ok(())
}

// https://gitlab.kitware.com/cmake/community/-/wikis/FAQ#how-do-i-use-a-different-compiler
// We set this here as setting it in the cmakefile is discouraged
fn set_compiler(config: &mut Config) -> Result<(), Box<dyn Error>>{
    if cfg!(target_os = "linux") {
        let mut c_cfg = cc::Build::new();
        let clang_11 = which::which("clang-13")?;
        c_cfg.compiler(clang_11);
        config.init_c_cfg(c_cfg);

        let mut cxx_cfg = cc::Build::new();
        let clangpp_11 = which::which("clang++-13")?;
        cxx_cfg.compiler(clangpp_11);
        config.init_cxx_cfg(cxx_cfg);
    } else if cfg!(target_os = "windows") {
        let mut c_cfg = cc::Build::new();
        let clang = which::which("clang.exe")?;
        c_cfg.compiler(clang);
        config.init_c_cfg(c_cfg);
        
        let mut cxx_cfg = cc::Build::new();
        let clangpp = which::which("clang++.exe")?;
        cxx_cfg.compiler(clangpp);
        config.init_cxx_cfg(cxx_cfg);
    } else if cfg!(target_os = "macos") {
        // Use macos default
    } else {
        panic!("Unsupported platform")
    }
    Ok(())
}

fn set_profile(config: &mut Config) -> Result<(), Box<dyn Error>> {
    config.define("CMAKE_BUILD_TYPE", "RelWithDebInfo");
    config.define("CMAKE_C_COMPILER_WORKS", "1");
    config.define("CMAKE_CXX_COMPILER_WORKS", "1");
    Ok(())
}
