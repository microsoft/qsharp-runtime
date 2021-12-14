use cmake::Config;
use std::boxed::Box;
use std::error::Error;
use std::process::Command;

fn main() -> Result<(), Box<dyn Error>> {
    println!("cargo:rerun-if-env-changed=TARGET");

    if cfg!(feature = "install-prereqs") {
        install_prereqs()?;
    }

    let mut config = Config::new("..");
    if cfg!(target_os = "windows") {
        config.static_crt(true);
    }
    config.profile("RelWithDebInfo");

    config.generator("Ninja");
    set_compiler(&mut config)?;
    config.cflag("-Wno-everything");
    config.cxxflag("-Wno-everything");

    config.define("BUILD_TESTS", "OFF");

    let mut sim_link_type = "dylib";
    if cfg!(feature = "staticsim") {
        if !cfg!(target_os = "macos") {
            config.define("BUILD_SHARED_LIBS", "OFF");
            config.define("ENABLE_OPENMP", "OFF");
            sim_link_type = "static";
        } else {
            println!(
                "cargo:warning='Static simulator not supported on MacOS! Built dynamic instead.'"
            )
        }
    }

    let dst = config.build();
    println!(
        "cargo:rustc-link-search=native={}",
        dst.join("build").join("src").display()
    );
    println!(
        "cargo:rustc-link-search=native={}",
        dst.join("build").display()
    );

    println!(
        "cargo:rustc-link-lib={}=Microsoft.Quantum.Simulator.Runtime",
        sim_link_type
    );
    if cfg!(target_os = "linux") {
        println!("cargo:rustc-link-lib=dylib=stdc++");
    } else if cfg!(target_os = "macos") {
        println!("cargo:rustc-link-lib=dylib=c++");
        println!("cargo:rustc-env=MACOSX_DEPLOYMENT_TARGET=11.6")
    }

    Ok(())
}

// https://gitlab.kitware.com/cmake/community/-/wikis/FAQ#how-do-i-use-a-different-compiler
// We set this here as setting it in the cmakefile is discouraged
fn set_compiler(config: &mut Config) -> Result<(), Box<dyn Error>> {
    if cfg!(target_os = "linux") {
        let mut c_cfg = cc::Build::new();
        let clang_11 = which::which("clang-11")?;
        c_cfg.compiler(clang_11);
        config.init_c_cfg(c_cfg);

        let mut cxx_cfg = cc::Build::new();
        let clangpp_11 = which::which("clang++-11")?;
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

fn install_prereqs() -> Result<(), Box<dyn Error>> {
    if cfg!(target_os = "windows") {
        if let Err(_) = which::which("clang.exe") {
            Command::new("choco")
                .args(&["install", "llvm", "--version=11.1.0", "--allow-downgrade"])
                .status()?;
        }
        if let Err(_) = which::which("ninja") {
            Command::new("choco").args(&["install", "ninja"]).status()?;
        }
        if let Err(_) = which::which("cmake") {
            Command::new("choco").args(&["install", "cmake"]).status()?;
        }
    } else if cfg!(target_os = "linux") {
        if let Ok(_) = which::which("sudo") {
            Command::new("sudo").args(&["apt", "update"]).status()?;
            Command::new("sudo")
                .args(&["apt-get", "install", "-y", "ninja-build", "clang-11"])
                .status()?;
        } else {
            Command::new("apt").args(&["update"]).status()?;
            Command::new("apt-get")
                .args(&["install", "-y", "ninja-build", "clang-11"])
                .status()?;
        }
    } else if cfg!(target_os = "macos") {
        Command::new("brew").args(&["update"]).status()?;
        Command::new("brew").args(&["install", "libomp"]).status()?;
        Command::new("brew").args(&["install", "ninja"]).status()?;
    }

    Ok(())
}
