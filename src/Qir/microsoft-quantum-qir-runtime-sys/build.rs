// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use cmake::Config;
use std::boxed::Box;
use std::error::Error;

fn main() -> Result<(), Box<dyn Error>> {
    println!("cargo:rerun-if-env-changed=TARGET");
    println!("cargo:rerun-if-changed=build.rs");

    let path_to_runtime_src = "../Runtime";
    compile_runtime_libraries(path_to_runtime_src)?;

    Ok(())
}

fn compile_runtime_libraries(path_to_runtime_src: &str) -> Result<(), Box<dyn Error>> {
    let mut config = Config::new(path_to_runtime_src);

    set_compiler(&mut config);
    set_profile(&mut config)?;

    config.generator("Ninja").no_build_target(true);

    let _ = config.build();
    Ok(())
}

// https://gitlab.kitware.com/cmake/community/-/wikis/FAQ#how-do-i-use-a-different-compiler
// We set this here as setting it in the cmakefile is discouraged
fn set_compiler(config: &mut Config) {
    if cfg!(target_os = "linux") {
        config.define("CMAKE_C_COMPILER", "clang-11");
        config.define("CMAKE_CXX_COMPILER", "clang++-11");
    } else if cfg!(target_os = "windows") {
        config.define("CMAKE_C_COMPILER", "clang");
        config.define("CMAKE_CXX_COMPILER", "clang++");
    } else if cfg!(target_os = "macos") {
        todo!("Identify the clang compiler on macos")
    } else {
        panic!("Unsupported platform")
    }
}

fn set_profile(config: &mut Config) -> Result<(), Box<dyn Error>> {
    config.define("CMAKE_BUILD_TYPE", "RelWithDebInfo");
    Ok(())
}
