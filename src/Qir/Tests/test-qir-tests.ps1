# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

. (Join-Path $PSScriptRoot .. qir-utils.ps1)

# TODO: `ASAN_OPTIONS=check_initialization_order=1` (https://clang.llvm.org/docs/AddressSanitizer.html#initialization-order-checking).
# TODO: macOS: `ASAN_OPTIONS=detect_leaks=1` (https://clang.llvm.org/docs/AddressSanitizer.html#memory-leak-detection).

if (-not (Test-CTest (Join-Path $PSScriptRoot bin $Env:BUILD_CONFIGURATION) "QIR Tests")) {
    throw "At least one project failed testing. Check the logs."
}
