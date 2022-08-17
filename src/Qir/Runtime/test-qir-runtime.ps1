# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

. (Join-Path $PSScriptRoot .. qir-utils.ps1)

Push-Location (Join-Path $PSScriptRoot lib QIR)
try {
    $releaseFlag = "$Env:BUILD_CONFIGURATION" -eq "Release" ? @("--release") : @();

    # Enable control flow guard (see https://github.com/microsoft/qsharp-runtime/pull/647)
    # for interoperating Rust and C.
    # NB: CFG is only supported on Windows, but the Rust flag is supported on
    #     all platforms; it's ignored on platforms without CFG functionality.
    $Env:RUSTFLAGS = "-C control-flow-guard";

    # Actually run the test.
    cargo +nightly test @releaseFlag
    if ($LASTEXITCODE -ne 0) { throw "Failed cargo test on QIR Runtime." }

    # When building in CI, free disk space by cleaning up.
    # Note that this takes longer, but saves ~1 GB of space.
    if ($IsCI) {
        cargo clean;
    }
}
finally {
    Pop-Location
}

# TODO: macOS: `ASAN_OPTIONS=detect_leaks=1` (https://clang.llvm.org/docs/AddressSanitizer.html#memory-leak-detection).
$env:ASAN_OPTIONS = "check_initialization_order=true:detect_stack_use_after_return=true:" `
    + "alloc_dealloc_mismatch=true:new_delete_type_mismatch=true:strict_init_order=true:strict_string_checks=true:" `
    + "detect_invalid_pointer_pairs=2"

if (-not (Test-CTest (Join-Path $PSScriptRoot bin $Env:BUILD_CONFIGURATION unittests) "QIR Runtime")) {
    throw "At least one project failed testing. Check the logs."
}
