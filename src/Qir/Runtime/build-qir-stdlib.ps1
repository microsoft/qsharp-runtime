# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#Requires -PSEdition Core

Include (Join-Path $PSScriptRoot .. .. .. build set-env.ps1)

task default -depends stdlib

task stdlib -depends set-env {
    # Start with the quick check first and make sure that Rust sources
    # meet formatting and style guide rules.
    exec -workingDirectory (Join-Path $PSScriptRoot stdlib) -errorMessage "Failed cargo fmt check on QIR stdlib."  {
        cargo fmt -- --check
    }

    # Check linting rules defined by clippy, a linting tool provided with the
    # Rust toolchain. Please see https://github.com/rust-lang/rust-clippy
    # and https://rust-lang.github.io/rust-clippy/master/index.html
    # for more information.
    # If there's a false positive, that check should be explicitly disabled
    # at the point where the false positive occurs with an explanation as to
    # why it's OK.
    exec -workingDirectory (Join-Path $PSScriptRoot stdlib) -errorMessage "Failed clippy linting check on QIR stdlib."  {
        cargo clippy --all-targets -- -D warnings
    }

    $releaseFlag = "$Env:BUILD_CONFIGURATION" -eq "Release" ? @("--release") : @();

    # Actually run the build.
    exec -workingDirectory (Join-Path $PSScriptRoot stdlib) -errorMessage "Failed cargo build on QIR stdlib."  {
        cargo build @releaseFlag
    }
    
    # Copy the results of compilation and the corresponding headers to the QIR drops folder so
    # they can be included in pipeline artifacts.
    $qirDropsBin = (Join-Path $Env:QIR_DROPS bin $env:BUILD_PLATFORM native)
    $qirDropsInclude = (Join-Path $Env:QIR_DROPS include)
    if (-not (Test-Path $Env:QIR_DROPS)) {
        New-Item -Path $Env:QIR_DROPS -ItemType "directory"
    }
    if (-not (Test-Path $qirDropsBin)) {
        New-Item -Path $qirDropsBin -ItemType "directory"
    }
    if (-not (Test-Path $qirDropsInclude)) {
        New-Item -Path $qirDropsInclude -ItemType "directory"
    }
    $qirBinaries = (Join-Path $PSScriptRoot .. .. .. target "$Env:BUILD_CONFIGURATION".ToLower() *)
    Copy-Item $qirBinaries $qirDropsBin -Include "*qir_stdlib*" -Exclude "*.rlib","*.d","*.exp"

    # Copy the C API header and def file
    Copy-Item (Join-Path $PSScriptRoot stdlib include qir_stdlib.h) (Join-Path $Env:QIR_DROPS include)
    Copy-Item (Join-Path $PSScriptRoot stdlib include qir_stdlib.def) (Join-Path $Env:QIR_DROPS include)

    # When building in CI, free disk space by cleaning up.
    # Note that this takes longer, but saves ~1 GB of space.
    if ($IsCI) {
        exec -workingDirectory (Join-Path $PSScriptRoot stdlib) -errorMessage "Failed cargo clean on QIR stdlib."  {
            cargo clean;
        }
    }
}