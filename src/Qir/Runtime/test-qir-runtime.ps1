# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

. (Join-Path $PSScriptRoot .. qir-utils.ps1)

# TODO: `ASAN_OPTIONS=check_initialization_order=1` (https://clang.llvm.org/docs/AddressSanitizer.html#initialization-order-checking).
# TODO: macOS: `ASAN_OPTIONS=detect_leaks=1` (https://clang.llvm.org/docs/AddressSanitizer.html#memory-leak-detection).

$env:ASAN_OPTIONS = "check_initialization_order=true:detect_stack_use_after_return=true:" `
    + "alloc_dealloc_mismatch=true:new_delete_type_mismatch=true:strict_init_order=true:strict_string_checks=true:" `
    + "detect_invalid_pointer_pairs=2"

if (-not (Test-CTest (Join-Path $PSScriptRoot bin $Env:BUILD_CONFIGURATION unittests) "QIR Runtime")) {
    throw "At least one project failed testing. Check the logs."
}
