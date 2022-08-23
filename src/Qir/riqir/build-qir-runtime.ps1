# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#Requires -PSEdition Core

& (Join-Path $PSScriptRoot .. .. .. build set-env.ps1)

$IsCI = "$Env:TF_BUILD" -ne "" -or "$Env:CI" -eq "true";

Push-Location $PSScriptRoot
try {
    # Start with the quick check first and make sure that Rust sources
    # meet formatting and style guide rules.
    cargo fmt -- --check
    if ($LASTEXITCODE -ne 0) { throw "Failed cargo fmt check on QIR Runtime." }

    # Check linting rules defined by clippy, a linting tool provided with the
    # Rust toolchain. Please see https://github.com/rust-lang/rust-clippy
    # and https://rust-lang.github.io/rust-clippy/master/index.html
    # for more information.
    # If there's a false positive, that check should be explicitly disabled
    # at the point where the false positive occurs with an explanation as to
    # why it's OK.
    cargo clippy -- -D warnings
    if ($LASTEXITCODE -ne 0) { throw "Failed clippy linting check on QIR Runtime." }

    $releaseFlag = "$Env:BUILD_CONFIGURATION" -eq "Release" ? @("--release") : @();

    # Actually run the build.
    cargo build @releaseFlag
    if ($LASTEXITCODE -ne 0) { throw "Failed cargo build on QIR Runtime." }

    # When building in CI, free disk space by cleaning up.
    # Note that this takes longer, but saves ~1 GB of space.
    if ($IsCI) {
        cargo clean;
    }

    # Copy the results of runtime compilation and the corresponding headers to the QIR drops folder so
    # they can be included in pipeline artifacts.
    $osDir = "win-x64"
    if ($IsLinux) {
        $osDir = "linux-x64"
    } elseif ($IsMacOS) {
        $osDir = "osx-x64"
    }
    $qirDropsBin = (Join-Path $Env:QIR_DROPS bin $osDir native)
    if (-not (Test-Path $Env:QIR_DROPS)) {
        New-Item -Path $Env:QIR_DROPS -ItemType "directory"
    }
    if (-not (Test-Path $qirDropsBin)) {
        New-Item -Path $qirDropsBin -ItemType "directory"
    }
    $qirBinaries = (Join-Path $PSScriptRoot .. .. .. target "$Env:BUILD_CONFIGURATION".ToLower() *)
    Copy-Item $qirBinaries $qirDropsBin -Include "qir_runtime*" -Exclude "*.rlib","*.d","*.exp"

    # For Windows platforms, make sure to update the extension of the lib file used for linking
    # from *.dll.lib to just .lib
    $rustlib = (Join-Path $qirDropsBin qir_runtime.dll.lib)
    if (Test-Path $rustlib) {
        Remove-Item (Join-Path $qirDropsBin qir_runtime.lib) -ErrorAction SilentlyContinue
        Rename-Item $rustlib qir_runtime.lib
    }

}
finally {
    Pop-Location
}