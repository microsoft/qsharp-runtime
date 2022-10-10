# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#Requires -Version 6.0

Write-Host "##[info] Runtime/prerequisites.ps1"

if ($Env:ENABLE_QIRRUNTIME -ne "false") {
    if (($IsWindows) -or ((Test-Path Env:/AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Win")))) {
        if (!(Get-Command clang        -ErrorAction SilentlyContinue) -or `
            !(Get-Command clang-format -ErrorAction SilentlyContinue) -or `
            (Test-Path Env:/AGENT_OS)) {
            Write-Output "Installing llvm@14"
            choco install --accept-license -y llvm --version=14.0.6 --allow-downgrade
            Write-Host "##vso[task.setvariable variable=PATH;]$($env:SystemDrive)\Program Files\LLVM\bin;$Env:PATH"
        }
        if (!(Get-Command ninja -ErrorAction SilentlyContinue)) {
            Write-Output "Installing ninja"
            choco install --accept-license -y ninja
        }
        if (!(Get-Command cmake -ErrorAction SilentlyContinue)) {
            Write-Output "Installing cmake"
            choco install --accept-license -y cmake
        }
        if (!(Get-Command sccache -ErrorAction SilentlyContinue)) {
            Write-Output "Installing sccache"
            choco install --accept-license -y sccache
        }
        refreshenv
    } elseif ($IsMacOS) {
        # temporary workaround for Bintray sunset
        # remove this after Homebrew is updated to 3.1.1 on MacOS image, see:
        # https://github.com/actions/virtual-environments/blob/main/images/macos/macos-10.15-Readme.md
        brew update
        
        if (!(Get-Command ninja -ErrorAction SilentlyContinue)) {
            brew install ninja
        }
        if (!(Get-Command ccache -ErrorAction SilentlyContinue)) {
            brew install ccache
        }
        brew install llvm@14
        if (!(Get-Command clang-format -ErrorAction SilentlyContinue)) {
            brew install clang-format@14    # Still needed after the LLVM is installed.
        }
    } else {
        $needClang = !(Get-Command clang-14 -ErrorAction SilentlyContinue)
        if (Get-Command sudo -ErrorAction SilentlyContinue) {
            if ($needClang) { 
                wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|sudo apt-key add -
                sudo add-apt-repository "deb https://apt.llvm.org/focal/ llvm-toolchain-focal-14 main"
            }
            sudo apt update
            
            if (!(Get-Command ninja -ErrorAction SilentlyContinue)) {
                Write-Output "Installing ninja-build"
                sudo apt-get install -y --no-install-recommends ninja-build
            }
            if (!(Get-Command ccache -ErrorAction SilentlyContinue)) {
                Write-Output "Installing ccache"
                sudo apt-get install -y --no-install-recommends ccache
            }
            sudo apt-get install -y --no-install-recommends clang-14 clang-tidy-14 clang-format-14
        } else {
            if ($needClang) {
                wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|apt-key add -
                add-apt-repository "deb https://apt.llvm.org/focal/ llvm-toolchain-focal-14 main"
            }
            apt update
            if (!(Get-Command ninja -ErrorAction SilentlyContinue)) {
                Write-Output "Installing ninja-build"
                apt-get install -y --no-install-recommends ninja-build
            }
            if (!(Get-Command ccache -ErrorAction SilentlyContinue)) {
                Write-Output "Installing ccache"
                apt-get install -y --no-install-recommends ccache
            }
            apt-get install -y --no-install-recommends clang-14 clang-tidy-14 clang-format-14
        }
    }

    if (-not (Get-Command rustup -ErrorAction SilentlyContinue)) {
        if ($IsWindows -or $PSVersionTable.PSEdition -eq "Desktop") {
            Invoke-WebRequest "https://win.rustup.rs" -OutFile rustup-init.exe
            Unblock-File rustup-init.exe;
            ./rustup-init.exe -y
        } elseif ($IsLinux -or $IsMacOS) {
            Invoke-WebRequest "https://sh.rustup.rs" | Select-Object -ExpandProperty Content | sh -s -- -y;
        } else {
            Write-Error "Host operating system not recognized as being Windows, Linux, or macOS; please download Rust manually from https://rustup.rs/."
        }
    
        if (-not (Get-Command rustup -ErrorAction SilentlyContinue)) {
            Write-Error "After running rustup-init, rustup was not available. Please check logs above to see if something went wrong.";
            exit -1;
        }
    }
    
    # Now that rustup is available, go on and make sure that nightly support for
    # rustfmt and clippy is available.
    rustup install nightly
    rustup toolchain install nightly
    rustup component add rustfmt clippy llvm-tools-preview
    rustup component add rustfmt clippy llvm-tools-preview --toolchain nightly
    }

