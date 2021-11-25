# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

Write-Host "##[info]Build Native simulator for $Env:BUILD_CONFIGURATION"


$nativeBuild = (Join-Path $PSScriptRoot "build")
if (-not (Test-Path $nativeBuild)) {
    New-Item -Path $nativeBuild -ItemType "directory"
}
Push-Location $nativeBuild

$SANITIZE_FLAGS="-fsanitize=undefined -fsanitize=float-divide-by-zero " `
    + "-fsanitize=unsigned-integer-overflow -fsanitize=implicit-conversion -fsanitize=local-bounds -fsanitize=nullability " `
    + "-fsanitize=address " `
    + "-fsanitize-blacklist=/Users/runner/work/1/s/src/Qir/Common/cmake/../../UBSan.ignore " `
    + "-fno-omit-frame-pointer -fno-optimize-sibling-calls"

# There should be no space after -D CMAKE_BUILD_TYPE= but if we provide the environment variable inline, without
# the space it doesn't seem to get substituted... With invalid -D CMAKE_BUILD_TYPE argument cmake silently produces
# a DEBUG build.
if (($IsWindows) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Win"))))
{
    Write-Host "On Windows build native simulator using the default C/C++ compiler (should be MSVC)"
    cmake -D BUILD_SHARED_LIBS:BOOL="1" -D CMAKE_BUILD_TYPE="$Env:BUILD_CONFIGURATION" ..
    # TODO(rokuzmin): Switch to clang.
}
elseif (($IsLinux) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Lin"))))
{
    Write-Host "On Linux build native simulator using gcc (needed for OpenMP)"
    cmake -D BUILD_SHARED_LIBS:BOOL="1" -D CMAKE_C_COMPILER=clang-11 -D CMAKE_CXX_COMPILER=clang++-11 `
        -D CMAKE_C_FLAGS_DEBUG="$SANITIZE_FLAGS" `
        -D CMAKE_CXX_FLAGS_DEBUG="$SANITIZE_FLAGS" `
        -D CMAKE_BUILD_TYPE="$Env:BUILD_CONFIGURATION" -D CMAKE_VERBOSE_MAKEFILE:BOOL="1" ..
    # TODO(rokuzmin): Updte prerequisites.
}
elseif (($IsMacOS) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Darwin"))))
{
    # Write-Host "On MacOS build native simulator using gcc (needed for OpenMP)"
    # # `gcc`on Darwin seems to be a shim that redirects to AppleClang, to get real gcc, must point to the specific
    # # version of gcc we've installed.
    # # cmake -D BUILD_SHARED_LIBS:BOOL="1" -D CMAKE_C_COMPILER=gcc-7 -D CMAKE_CXX_COMPILER=g++-7 -D CMAKE_BUILD_TYPE="$Env:BUILD_CONFIGURATION" ..

    $OPENMP_PATH="/usr/local/opt/libomp"
    $OPENMP_COMPILER_FLAGS="-Xpreprocessor -fopenmp -I$OPENMP_PATH/include -lomp -L$OPENMP_PATH/lib"
    $OPENMP_LIB_NAME="omp"
    cmake -D BUILD_SHARED_LIBS:BOOL="1" `
        -D OpenMP_CXX_FLAGS="$OPENMP_COMPILER_FLAGS" -D OpenMP_CXX_LIB_NAMES="$OPENMP_LIB_NAME" `
        -D   OpenMP_C_FLAGS="$OPENMP_COMPILER_FLAGS" -D   OpenMP_C_LIB_NAMES="$OPENMP_LIB_NAME" `
        -D OpenMP_omp_LIBRARY=$OPENMP_PATH/lib/libomp.dylib `
        -D CMAKE_C_FLAGS_DEBUG="$SANITIZE_FLAGS" `
        -D CMAKE_CXX_FLAGS_DEBUG="$SANITIZE_FLAGS" `
        -D CMAKE_BUILD_TYPE="$Env:BUILD_CONFIGURATION" -D CMAKE_VERBOSE_MAKEFILE:BOOL="1" ..
    # TODO(rokuzmin): Updte prerequisites.
}
else {
    cmake -D BUILD_SHARED_LIBS:BOOL="1" -D CMAKE_BUILD_TYPE="$Env:BUILD_CONFIGURATION" ..
}
cmake --build . --config "$Env:BUILD_CONFIGURATION" --target install

Pop-Location


if ($LastExitCode -ne 0) {
    Write-Host "##vso[task.logissue type=error;]Failed to build Native simulator."
}
