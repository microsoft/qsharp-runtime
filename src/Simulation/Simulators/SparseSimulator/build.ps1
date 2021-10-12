# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#Requires -Version 7.1

Write-Host "##[info]Build SparseSimulator"

& (Join-Path $PSScriptRoot .. .. .. .. build set-env.ps1)
$FailureCommands = 'Write-Host "##vso[task.logissue type=error;] Failed to build SparseSimulator. See errors below or above." ;  Pop-Location ; Exit 1'

# BULD NATIVE PART

# mkdir Native\build\(Debug|Release)
$BuildDir = (Join-Path $PSScriptRoot "Native" "build" $Env:BUILD_CONFIGURATION)
if (-not (Test-Path $BuildDir)) {
    New-Item -Path $BuildDir -ItemType "directory" | Out-Null
}

# pushd Native\build\(Debug|Release)
Push-Location $BuildDir

    $CmakeConfigCommand = "cmake -G Ninja -D CMAKE_VERBOSE_MAKEFILE:BOOL=ON -D CMAKE_BUILD_TYPE=$Env:BUILD_CONFIGURATION -S ..\.. "  # Without `-G Ninja` the compiler chosen is always `cl.exe`.
    
    if (($IsMacOS) -or ((Test-Path Env:/AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Darwin"))))
    {
        Write-Host "On MacOS build using the default C/C++ compiler (should be AppleClang)"
    }
    else {
        if (($IsLinux) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Lin"))))
        {
            Write-Host "On Linux build using Clang"
            $CC = "clang-11"
            $CXX = "clang++-11"
            #$clangTidy = "-DCMAKE_CXX_CLANG_TIDY=clang-tidy-11"
        }
        elseif (($IsWindows) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Win"))))
        {
            Write-Host "On Windows build using Clang"
            $CC = "clang.exe"
            $CXX = "clang++.exe"

            if (!(Get-Command clang -ErrorAction SilentlyContinue) -and (choco find --idonly -l llvm) -contains "llvm") {
                # LLVM was installed by Chocolatey, so add the install location to the path.
                $env:PATH += ";$($env:SystemDrive)\Program Files\LLVM\bin"
            }

            #if (Get-Command clang-tidy -ErrorAction SilentlyContinue) {
            #    # Only run clang-tidy if it's installed. This is because the package used by chocolatey on
            #    # the build pipeline doesn't include clang-tidy, so we allow skipping that there and let
            #    # the Linux build catch tidy issues.
            #    $clangTidy = "-DCMAKE_CXX_CLANG_TIDY=clang-tidy"
            #}
        } 

        $CmakeConfigCommand += " -D CMAKE_C_COMPILER=$CC -D CMAKE_CXX_COMPILER=$CXX "
    }

    # Generate the build scripts:
    ( Invoke-Expression $CmakeConfigCommand ) || ( Invoke-Expression $FailureCommands )

    # Invoke the build scripts:
    ( cmake --build . ) || ( Invoke-Expression $FailureCommands )

# popd
Pop-Location


# BUILD C# PART AND TESTS

Push-Location $PSScriptRoot
    ( dotnet build . --configuration $Env:BUILD_CONFIGURATION ) || ( Invoke-Expression $FailureCommands )
Pop-Location
