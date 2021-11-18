# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

Write-Host "##[info]Build Native simulator for $Env:BUILD_CONFIGURATION"


$nativeBuild = (Join-Path $PSScriptRoot "build")
if (-not (Test-Path $nativeBuild)) {
    New-Item -Path $nativeBuild -ItemType "directory"
}
Push-Location $nativeBuild

    $sanitizeFlags = ""

    #$sanitizeFlags += " -fsanitize=undefined -fsanitize=float-divide-by-zero -fsanitize=unsigned-integer-overflow -fsanitize=implicit-conversion -fsanitize=local-bounds -fsanitize=nullability"
    #$sanitizeFlags += " -fsanitize=undefined -fsanitize=float-divide-by-zero -fsanitize=signed-integer-overflow "
    #$sanitizeFlags += " -fsanitize=address"
    #$sanitizeFlags += " -fno-omit-frame-pointer"
    #$sanitizeFlags += " -fno-optimize-sibling-calls"

    $sanitizeFlags += " -fsanitize=undefined -fsanitize=shift -fsanitize=shift-exponent -fsanitize=shift-base -fsanitize=integer-divide-by-zero -fsanitize=unreachable -fsanitize=vla-bound "
    $sanitizeFlags +=   " -fsanitize=null -fsanitize=return -fsanitize=signed-integer-overflow -fsanitize=bounds -fsanitize=bounds-strict -fsanitize=alignment -fsanitize=object-size "
    $sanitizeFlags +=   " -fsanitize=float-divide-by-zero -fsanitize=float-cast-overflow -fsanitize=nonnull-attribute -fsanitize=returns-nonnull-attribute -fsanitize=bool -fsanitize=enum "
    $sanitizeFlags +=   " -fsanitize=vptr -fsanitize=pointer-overflow -fsanitize=builtin "

    #$sanitizeFlags +=   " -fsanitize=address -fsanitize=pointer-compare -fsanitize=pointer-subtract "



# There should be no space after -D CMAKE_BUILD_TYPE= but if we provide the environment variable inline, without
# the space it doesn't seem to get substituted... With invalid -D CMAKE_BUILD_TYPE argument cmake silently produces
# a DEBUG build.
if (($IsWindows) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Win"))))
{
    Write-Host "On Windows build native simulator using the default C/C++ compiler (should be MSVC)"
    cmake -D BUILD_SHARED_LIBS:BOOL="1" -D CMAKE_BUILD_TYPE="$Env:BUILD_CONFIGURATION" ..
}
elseif (($IsLinux) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Lin"))))
{
    Write-Host "On Linux build native simulator using gcc (needed for OpenMP)"
    cmake -D BUILD_SHARED_LIBS:BOOL="1" -D CMAKE_C_COMPILER=gcc -D CMAKE_CXX_COMPILER=g++ -D CMAKE_BUILD_TYPE="$Env:BUILD_CONFIGURATION" ..
    #cmake -D BUILD_SHARED_LIBS:BOOL="1" -D CMAKE_C_COMPILER=gcc -D CMAKE_CXX_COMPILER=g++ -D CMAKE_BUILD_TYPE="$Env:BUILD_CONFIGURATION" -D CMAKE_CXX_FLAGS_DEBUG="$sanitizeFlags" -D CMAKE_C_FLAGS_DEBUG="$sanitizeFlags" -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON ..
}
elseif (($IsMacOS) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Darwin"))))
{
    Write-Host "On MacOS build native simulator using gcc (needed for OpenMP)"
    # `gcc`on Darwin seems to be a shim that redirects to AppleClang, to get real gcc, must point to the specific
    # version of gcc we've installed.
    #cmake -D BUILD_SHARED_LIBS:BOOL="1" -D CMAKE_C_COMPILER=gcc-7 -D CMAKE_CXX_COMPILER=g++-7 -D CMAKE_BUILD_TYPE="$Env:BUILD_CONFIGURATION" ..
    #cmake -D BUILD_SHARED_LIBS:BOOL="1" -D CMAKE_C_COMPILER=gcc-11 -D CMAKE_CXX_COMPILER=g++-11 -D CMAKE_BUILD_TYPE="$Env:BUILD_CONFIGURATION" -D CMAKE_CXX_FLAGS_DEBUG="$sanitizeFlags" -D CMAKE_C_FLAGS_DEBUG="$sanitizeFlags" ..
    cmake -D BUILD_SHARED_LIBS:BOOL="1" -D CMAKE_C_COMPILER=gcc-11 -D CMAKE_CXX_COMPILER=g++-11 -D CMAKE_BUILD_TYPE="$Env:BUILD_CONFIGURATION" -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON ..
}
else {
    cmake -D BUILD_SHARED_LIBS:BOOL="1" -D CMAKE_BUILD_TYPE="$Env:BUILD_CONFIGURATION" ..
}
cmake --build . --config "$Env:BUILD_CONFIGURATION" --target install

Pop-Location


if ($LastExitCode -ne 0) {
    Write-Host "##vso[task.logissue type=error;]Failed to build Native simulator."
}
