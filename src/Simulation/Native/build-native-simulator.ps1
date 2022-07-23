# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

Write-Host "##[info]Build Native simulator for $Env:BUILD_CONFIGURATION"

if ($IsMacOS) {
    # To ensure loading succeeds on Mac the install id of the library needs to be updated to use 
    # paths relative to target dynamic load path. Otherwise it will keep the full path encoding in the
    # library from when it was built by homebrew.
    # See https://stackoverflow.com/questions/52981210/linking-with-dylib-library-from-the-command-line-using-clang
    Write-Host "##[info]Fixing binary dependencies with install_name_tool..."
    install_name_tool -id "@rpath/libomp.dylib" (Join-Path $PSScriptRoot osx libomp.dylib)
}


$nativeBuild = (Join-Path $PSScriptRoot "build")
if (-not (Test-Path $nativeBuild)) {
    New-Item -Path $nativeBuild -ItemType "directory"
}
Push-Location $nativeBuild

# Search for "sanitize" in 
# https://clang.llvm.org/docs/ClangCommandLineReference.html
# https://man7.org/linux/man-pages/man1/gcc.1.html
$SANITIZE_FLAGS=`
    "-fsanitize=undefined " `
    + "-fsanitize=shift -fsanitize=shift-base " `
    + "-fsanitize=integer-divide-by-zero -fsanitize=float-divide-by-zero " `
    + "-fsanitize=unreachable " `
    + "-fsanitize=vla-bound -fsanitize=null -fsanitize=return " `
    + "-fsanitize=signed-integer-overflow -fsanitize=bounds -fsanitize=alignment -fsanitize=object-size " `
    + "-fsanitize=float-cast-overflow -fsanitize=nonnull-attribute -fsanitize=returns-nonnull-attribute -fsanitize=bool -fsanitize=enum " `
    + "-fsanitize=vptr -fsanitize=pointer-overflow -fsanitize=builtin " `
    + "-fsanitize=implicit-conversion -fsanitize=local-bounds -fsanitize=nullability " `
    `
    + "-fsanitize=address " `
    + "-fsanitize=pointer-compare -fsanitize=pointer-subtract " `
    + "-fsanitize-address-use-after-scope " `
    + "-fno-omit-frame-pointer -fno-optimize-sibling-calls"

    #+ "-fsanitize=unsigned-integer-overflow "      # TODO(rokuzmin, #884): Disable this option for _specific_ lines 
                                                    # of code, but not for the whole binary.
# There should be no space after -D CMAKE_BUILD_TYPE= but if we provide the environment variable inline, without
# the space it doesn't seem to get substituted... With invalid -D CMAKE_BUILD_TYPE argument cmake silently produces
# a DEBUG build.

$buildType = $Env:BUILD_CONFIGURATION
if ($buildType -eq "Release") {
    $buildType = "RelWithDebInfo"
}

if (($IsWindows) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Win"))))
{
    $CMAKE_C_COMPILER = "-DCMAKE_C_COMPILER=clang.exe"
    $CMAKE_CXX_COMPILER = "-DCMAKE_CXX_COMPILER=clang++.exe"

    if ((!(Get-Command clang -ErrorAction SilentlyContinue) -and (choco find --idonly -l llvm) -contains "llvm") -or `
        (Test-Path Env:/AGENT_OS)) {
        # LLVM was installed by Chocolatey, so add the install location to the path.
        $env:PATH = "$($env:SystemDrive)\Program Files\LLVM\bin;$env:Path"
    }

    cmake -G Ninja -D BUILD_SHARED_LIBS:BOOL="1" $CMAKE_C_COMPILER $CMAKE_CXX_COMPILER `
        -D CMAKE_BUILD_TYPE="$buildType"  ..
        # Without `-G Ninja` we fail to switch from MSVC to Clang.
        # Sanitizers are not supported on Windows at the moment. Check again after migrating from Clang-11.
}
elseif (($IsLinux) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Lin"))))
{
    cmake -G Ninja -D BUILD_SHARED_LIBS:BOOL="1" -D CMAKE_C_COMPILER=clang-14 -D CMAKE_CXX_COMPILER=clang++-14 `
        -D CMAKE_C_FLAGS_DEBUG="$SANITIZE_FLAGS" `
        -D CMAKE_CXX_FLAGS_DEBUG="$SANITIZE_FLAGS" `
        -D CMAKE_BUILD_TYPE="$buildType" ..
}
elseif (($IsMacOS) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Darwin"))))
{
    Write-Host "On MacOS build using the default C/C++ compiler (should be AppleClang)"

    cmake -G Ninja -D BUILD_SHARED_LIBS:BOOL="1" `
        -D CMAKE_C_FLAGS_DEBUG="$SANITIZE_FLAGS" `
        -D CMAKE_CXX_FLAGS_DEBUG="$SANITIZE_FLAGS" `
        -D CMAKE_BUILD_TYPE="$buildType" ..
}
else {
    cmake -D BUILD_SHARED_LIBS:BOOL="1" -D CMAKE_BUILD_TYPE="$buildType" ..
}
cmake --build . --config "$buildType" --target install

if ($IsMacOS) {
    Write-Host "##[info]Copying libomp..."
    Copy-Item -Verbose (Join-Path $PSScriptRoot osx libomp.dylib) (Join-Path $PSScriptRoot build)
    Copy-Item -Verbose (Join-Path $PSScriptRoot osx libomp.dylib) (Join-Path $PSScriptRoot build drop)
}

Pop-Location


if ($LastExitCode -ne 0) {
    Write-Host "##vso[task.logissue type=error;]Failed to build Native simulator."
}
