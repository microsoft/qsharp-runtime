# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

. (Join-Path $PSScriptRoot .. qir-utils.ps1)

$oldLSAN_OPTIONS    = $env:LSAN_OPTIONS
$oldASAN_OPTIONS    = $env:ASAN_OPTIONS     # Colon-separated list of options (https://github.com/google/sanitizers/wiki/AddressSanitizerFlags#run-time-flags).

$env:LSAN_OPTIONS   = ""
$env:ASAN_OPTIONS   = ""

if ($Env:BUILD_CONFIGURATION -eq "Debug") 
{ 
    # Sanitizers (https://clang.llvm.org/docs/UsersManual.html#controlling-code-generation):

    if (-not ($IsWindows))
    {
        $env:LSAN_OPTIONS += "suppressions=../../../../LSan.ignore"    # https://clang.llvm.org/docs/AddressSanitizer.html#suppressing-memory-leaks
        if (-not ($IsMacOS))
        {
            $env:ASAN_OPTIONS += "check_initialization_order=1"    # https://clang.llvm.org/docs/AddressSanitizer.html#initialization-order-checking
        }
        else
        {
            $env:ASAN_OPTIONS += "detect_leaks=1"      # https://clang.llvm.org/docs/AddressSanitizer.html#memory-leak-detection
        }
    }
}

$all_ok = $true

if (-not (Test-CTest (Join-Path $PSScriptRoot bin $Env:BUILD_CONFIGURATION) "QIR Tests")) {
    $all_ok = $false
}

$env:ASAN_OPTIONS    = $oldASAN_OPTIONS
$env:LSAN_OPTIONS    = $oldLSAN_OPTIONS

if (-not $all_ok)
{
    throw "At least one project failed testing. Check the logs."
}
