# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#Requires -PSEdition Core

Include (Join-Path $PSScriptRoot "set-env.ps1")
Include (Join-Path $PSScriptRoot "../src/Qir/Runtime/prerequisites.ps1")
Include (Join-Path $PSScriptRoot "../src/Simulation/Native/prerequisites.ps1")
Include (Join-Path $PSScriptRoot "../src/Simulation/qdk_sim_rs/prerequisites.ps1")

task default -depends qir-runtime-prerequisites, native-simulator-prerequisites, qdk-sim-rs-prerequisites

task install-rust {
    if (-not (Get-Command rustup -ErrorAction SilentlyContinue)) {
        if ($IsWindows -or $PSVersionTable.PSEdition -eq "Desktop") {
            Invoke-WebRequest "https://win.rustup.rs" -OutFile rustup-init.exe
            Unblock-File rustup-init.exe;
            ./rustup-init.exe -y
        }
        elseif ($IsLinux -or $IsMacOS) {
            Invoke-WebRequest "https://sh.rustup.rs" | Select-Object -ExpandProperty Content | sh -s -- -y;
        }
        else {
            Write-Error "Host operating system not recognized as being Windows, Linux, or macOS; please download Rust manually from https://rustup.rs/."
        }

        if (-not (Get-Command rustup -ErrorAction SilentlyContinue)) {
            Write-Error "After running rustup-init, rustup was not available. Please check logs above to see if something went wrong.";
            exit -1;
        }
    }
}

task install-rust-toolchains -depends install-rust {
    # Now that rustup is available, go on and make sure that nightly support for
    # rustfmt and clippy is available.
    exec {
        rustup install nightly
    }
    exec {
        rustup toolchain install nightly
    }
    exec {
        rustup component add rustfmt clippy llvm-tools-preview
    }
    exec {
        rustup component add rustfmt clippy llvm-tools-preview --toolchain nightly
    }
}