# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

Write-Host "##[info]Build Native simulator for $Env:BUILD_CONFIGURATION"


$nativeBuild = (Join-Path $PSScriptRoot "build")
if (-not (Test-Path $nativeBuild)) {
    New-Item -Path $nativeBuild -ItemType "directory"
}
Push-Location $nativeBuild

$SANITIZE_FLAGS=`
    "-fsanitize=undefined " `
    + "-fsanitize=shift -fsanitize=shift-base " `
    + "-fsanitize=integer-divide-by-zero -fsanitize=float-divide-by-zero " `
    + "-fsanitize=unreachable " `
    + "-fsanitize=vla-bound -fsanitize=null -fsanitize=return " `
    + "-fsanitize=signed-integer-overflow -fsanitize=bounds -fsanitize=alignment -fsanitize=object-size " `
    + "-fsanitize=float-cast-overflow -fsanitize=nonnull-attribute -fsanitize=returns-nonnull-attribute -fsanitize=bool -fsanitize=enum " `
    + "-fsanitize=pointer-overflow -fsanitize=builtin " `
    + "-fsanitize=implicit-conversion -fsanitize=local-bounds -fsanitize=nullability " `
    `
    + "-fsanitize=address " `
    + "-fsanitize=pointer-compare -fsanitize=pointer-subtract " `
    + "-fsanitize-address-use-after-scope " `
    + "-fno-omit-frame-pointer -fno-optimize-sibling-calls"

    #+ "-fsanitize=unsigned-integer-overflow "
    #  -fsanitize=bounds-strict    clang: error: unsupported argument 'bounds-strict' to option 'fsanitize='  (as opposed to gcc)

$NON_WIN_SANITIZE_FLAGS=`
    "-fsanitize=vptr "


# There should be no space after -D CMAKE_BUILD_TYPE= but if we provide the environment variable inline, without
# the space it doesn't seem to get substituted... With invalid -D CMAKE_BUILD_TYPE argument cmake silently produces
# a DEBUG build.
if (($IsWindows) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Win"))))
{
    #Write-Host "On Windows build native simulator using the default C/C++ compiler (should be MSVC)"

    $CMAKE_C_COMPILER = "-DCMAKE_C_COMPILER=clang.exe"
    $CMAKE_CXX_COMPILER = "-DCMAKE_CXX_COMPILER=clang++.exe"

    if ((!(Get-Command clang -ErrorAction SilentlyContinue) -and (choco find --idonly -l llvm) -contains "llvm") -or `
        (Test-Path Env:/AGENT_OS)) {
        # LLVM was installed by Chocolatey, so add the install location to the path.
        $env:PATH = "$($env:SystemDrive)\Program Files\LLVM\bin;$env:Path"
    }

    #cmake -D BUILD_SHARED_LIBS:BOOL="1" -D CMAKE_BUILD_TYPE="$Env:BUILD_CONFIGURATION" `
    #    -D CMAKE_VERBOSE_MAKEFILE:BOOL="1" ..
    #cmake -G Ninja $CMAKE_C_COMPILER $CMAKE_CXX_COMPILER $clangTidy -D CMAKE_BUILD_TYPE="$buildType" -D CMAKE_VERBOSE_MAKEFILE:BOOL="1" ../.. | Write-Host
    cmake -G Ninja $CMAKE_C_COMPILER $CMAKE_CXX_COMPILER -D CMAKE_BUILD_TYPE="$Env:BUILD_CONFIGURATION" `
        -D CMAKE_VERBOSE_MAKEFILE:BOOL="1" ..
        # Without `-G Ninja` fail to switch from MSVC to Clang.
}
elseif (($IsLinux) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Lin"))))
{
    Write-Host "On Linux build native simulator using gcc (needed for OpenMP)"
    cmake -D BUILD_SHARED_LIBS:BOOL="1" -D CMAKE_C_COMPILER=clang-11 -D CMAKE_CXX_COMPILER=clang++-11 `
        -D CMAKE_C_FLAGS_DEBUG="$SANITIZE_FLAGS $NON_WIN_SANITIZE_FLAGS" `
        -D CMAKE_CXX_FLAGS_DEBUG="$SANITIZE_FLAGS $NON_WIN_SANITIZE_FLAGS" `
        -D CMAKE_BUILD_TYPE="$Env:BUILD_CONFIGURATION" -D CMAKE_VERBOSE_MAKEFILE:BOOL="1" ..
}
elseif (($IsMacOS) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Darwin"))))
{
    # Write-Host "On MacOS build native simulator using gcc (needed for OpenMP)"
    # # `gcc`on Darwin seems to be a shim that redirects to AppleClang, to get real gcc, must point to the specific
    # # version of gcc we've installed.
    # # cmake -D BUILD_SHARED_LIBS:BOOL="1" -D CMAKE_C_COMPILER=gcc-7 -D CMAKE_CXX_COMPILER=g++-7 -D CMAKE_BUILD_TYPE="$Env:BUILD_CONFIGURATION" ..
    Write-Host "On MacOS build using the default C/C++ compiler (should be AppleClang)"

    $OPENMP_PATH="/usr/local/opt/libomp"
    $OPENMP_COMPILER_FLAGS="-Xpreprocessor -fopenmp -I$OPENMP_PATH/include -lomp -L$OPENMP_PATH/lib"
    $OPENMP_LIB_NAME="omp"
    cmake -D BUILD_SHARED_LIBS:BOOL="1" `
        -D OpenMP_CXX_FLAGS="$OPENMP_COMPILER_FLAGS" -D OpenMP_CXX_LIB_NAMES="$OPENMP_LIB_NAME" `
        -D   OpenMP_C_FLAGS="$OPENMP_COMPILER_FLAGS" -D   OpenMP_C_LIB_NAMES="$OPENMP_LIB_NAME" `
        -D OpenMP_omp_LIBRARY=$OPENMP_PATH/lib/libomp.dylib `
        -D CMAKE_C_FLAGS_DEBUG="$SANITIZE_FLAGS $NON_WIN_SANITIZE_FLAGS" `
        -D CMAKE_CXX_FLAGS_DEBUG="$SANITIZE_FLAGS $NON_WIN_SANITIZE_FLAGS" `
        -D CMAKE_BUILD_TYPE="$Env:BUILD_CONFIGURATION" -D CMAKE_VERBOSE_MAKEFILE:BOOL="1" ..
}
else {
    cmake -D BUILD_SHARED_LIBS:BOOL="1" -D CMAKE_BUILD_TYPE="$Env:BUILD_CONFIGURATION" ..
}
cmake --build . --config "$Env:BUILD_CONFIGURATION" --target install

Pop-Location


if ($LastExitCode -ne 0) {
    Write-Host "##vso[task.logissue type=error;]Failed to build Native simulator."
}
