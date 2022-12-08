# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#Requires -PSEdition Core

& (Join-Path $PSScriptRoot .. .. .. build set-env.ps1)

$IsCI = "$Env:TF_BUILD" -ne "" -or "$Env:CI" -eq "true";

Push-Location (Join-Path $PSScriptRoot stdlib)
try {
    # Start with the quick check first and make sure that Rust sources
    # meet formatting and style guide rules.
    cargo fmt -- --check
    if ($LASTEXITCODE -ne 0) { throw "Failed cargo fmt check on QIR stdlib." }

    # Check linting rules defined by clippy, a linting tool provided with the
    # Rust toolchain. Please see https://github.com/rust-lang/rust-clippy
    # and https://rust-lang.github.io/rust-clippy/master/index.html
    # for more information.
    # If there's a false positive, that check should be explicitly disabled
    # at the point where the false positive occurs with an explanation as to
    # why it's OK.
    cargo clippy --all-targets -- -D warnings
    if ($LASTEXITCODE -ne 0) { throw "Failed clippy linting check on QIR stdlib." }

    $releaseFlag = "$Env:BUILD_CONFIGURATION" -eq "Release" ? @("--release") : @();

    # Actually run the build.
    cargo build @releaseFlag
    if ($LASTEXITCODE -ne 0) { throw "Failed cargo build on QIR stdlib." }

    # Copy the results of compilation and the corresponding headers to the QIR drops folder so
    # they can be included in pipeline artifacts.
    $qirDropsInclude = (Join-Path $Env:QIR_DROPS include)
    if (-not (Test-Path $Env:QIR_DROPS)) {
        New-Item -Path $Env:QIR_DROPS -ItemType "directory"
    }
    if (-not (Test-Path $qirDropsInclude)) {
        New-Item -Path $qirDropsInclude -ItemType "directory"
    }
    $qirBinaries = (Join-Path $PSScriptRoot .. .. .. target "$Env:BUILD_CONFIGURATION".ToLower() *)
    Copy-Item $qirBinaries $Env:QIR_DROPS -Include "*qir_stdlib*" -Exclude "*.rlib","*.d","*.exp"

    # Copy the C API header and def file
    $qirIncludes = (Join-Path $PSScriptRoot .. .. .. target "$Env:BUILD_CONFIGURATION".ToLower() build include *)
    Copy-Item $qirIncludes $qirDropsInclude

    # When building in CI, free disk space by cleaning up.
    # Note that this takes longer, but saves ~1 GB of space.
    if ($IsCI) {
        cargo clean;
    }
}
finally {
    Pop-Location
}
