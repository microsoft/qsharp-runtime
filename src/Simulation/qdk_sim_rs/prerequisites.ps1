# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.


#Requires -PSEdition Core

task qdk-sim-rs-prerequisites -depends set-env, install-rust {
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

        Assert (Test-CommandExists rustup) "After running rustup-init, rustup was not available. Please check logs above to see if something went wrong."
    }


    if (-not "$(cargo install --list)".contains("cargo-set-version")) {
        exec {
            cargo install cargo-edit
        }
    }
    if ($IsCI) {
        exec {
            cargo set-version $Env:NUGET_VERSION
        }
    }
    else {
        #NUGET_VERSION default for local fails, but we don't want the
        #bootstrapping to fail because of it.
        cargo set-version $Env:NUGET_VERSION
    }
}