# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

. (Join-Path $PSScriptRoot .. qir-utils.ps1)

Write-Host "##[info]Compile QIR Runtime"

& (Join-Path $PSScriptRoot ".." check-sources-formatted.ps1) -Path $PSScriptRoot
& (Join-Path $PSScriptRoot ".." check-sources-formatted.ps1) -Path (Join-Path $PSScriptRoot ".." Common)

$IsCI = "$Env:TF_BUILD" -ne "" -or "$Env:CI" -eq "true";

Push-Location (Join-Path $PSScriptRoot lib QIR)
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

    # Enable control flow guard (see https://github.com/microsoft/qsharp-runtime/pull/647)
    # for interoperating Rust and C.
    # NB: CFG is only supported on Windows, but the Rust flag is supported on
    #     all platforms; it's ignored on platforms without CFG functionality.
    $Env:RUSTFLAGS = "-C control-flow-guard";

    # Actually run the build.
    cargo +nightly build @releaseFlag -Z unstable-options --out-dir (Join-Path $PSScriptRoot bin $Env:BUILD_CONFIGURATION bin)
    if ($LASTEXITCODE -ne 0) { throw "Failed cargo build on QIR Runtime." }
    Remove-Item (Join-Path $PSScriptRoot bin $Env:BUILD_CONFIGURATION bin *.rlib)

    # When building in CI, free disk space by cleaning up.
    # Note that this takes longer, but saves ~1 GB of space.
    if ($IsCI) {
        cargo clean;
    }
}
finally {
    Pop-Location
}

if (-not (Build-CMakeProject $PSScriptRoot "QIR Runtime")) {
    throw "At least one project failed to compile. Check the logs."
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
$qirDropsInclude = (Join-Path $Env:QIR_DROPS include)
if (-not (Test-Path $Env:QIR_DROPS)) {
    New-Item -Path $Env:QIR_DROPS -ItemType "directory"
    New-Item -Path $qirDropsBin -ItemType "directory"
    New-Item -Path $qirDropsInclude -ItemType "directory"
}
$qirBinaries = (Join-Path $PSScriptRoot bin $Env:BUILD_CONFIGURATION bin *)
$qirIncludes = (Join-Path $PSScriptRoot public *)
Copy-Item $qirBinaries $qirDropsBin -Exclude "*unittests*","*.Tracer.*"
Copy-Item $qirIncludes $qirDropsInclude -Exclude "*.md","Tracer*"
