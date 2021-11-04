#Requires -PSEdition Core

& (Join-Path $PSScriptRoot .. .. build set-env.ps1)

function Build-QirProject {
    param (
        [string]
        $FolderPath,
        
        [Switch]
        $SkipQSharpBuild
    )

    if (!$SkipQSharpBuild) {
        Write-Host "##[info]Build Q# project for $Name '$FolderPath'"
        dotnet build $FolderPath -c $Env:BUILD_CONFIGURATION -v $Env:BUILD_VERBOSITY
        if ($LastExitCode -ne 0) {
            Write-Host "##vso[task.logissue type=error;]Failed to compile Q# project at '$FolderPath' into QIR."
            throw "Failed to compile Q# project at '$FolderPath' into QIR."
        }
    }
}

function Build-CMakeProject {
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        $Path,

        [Parameter()]
        [String]
        $Name
    )

    Write-Host "##[info]Build $Name"
    $CMAKE_C_COMPILER = ""
    $CMAKE_CXX_COMPILER = ""

    $oldCFLAGS = $env:CFLAGS
    $oldCXXFLAGS = $env:CXXFLAGS

    $clangTidy = ""

    if ($Env:BUILD_CONFIGURATION -eq "Debug") { 
        # Sanitizers (https://clang.llvm.org/docs/UsersManual.html#controlling-code-generation):
        if (-not ($IsWindows)) {
            # Common for all sanitizers:
            $sanitizeFlags = " -fsanitize-blacklist="      # https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html#suppressing-errors-in-recompiled-code-ignorelist
            # https://releases.llvm.org/11.0.1/tools/clang/docs/SanitizerSpecialCaseList.html
            $sanitizeFlags += (Join-Path $Path .. UBSan.ignore)
            $env:CFLAGS += $sanitizeFlags
            $env:CXXFLAGS += $sanitizeFlags
        } # if (-not ($IsWindows))

    } # if ($Env:BUILD_CONFIGURATION -eq "Debug") 


    if (($IsMacOS) -or ((Test-Path Env:/AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Darwin")))) {
        Write-Host "On MacOS build $Name using the default C/C++ compiler (should be AppleClang)"
    }
    elseif (($IsLinux) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Lin")))) {
        Write-Host "On Linux build $Name using Clang"
        $CMAKE_C_COMPILER = "-DCMAKE_C_COMPILER=clang-11"
        $CMAKE_CXX_COMPILER = "-DCMAKE_CXX_COMPILER=clang++-11"
        $clangTidy = "-DCMAKE_CXX_CLANG_TIDY=clang-tidy-11"
    }
    elseif (($IsWindows) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Win")))) {
        Write-Host "On Windows build $Name using Clang"
        $CMAKE_C_COMPILER = "-DCMAKE_C_COMPILER=clang.exe"
        $CMAKE_CXX_COMPILER = "-DCMAKE_CXX_COMPILER=clang++.exe"

        if ((!(Get-Command clang -ErrorAction SilentlyContinue) -and (choco find --idonly -l llvm) -contains "llvm") -or `
            (Test-Path Env:/AGENT_OS)) {
            # LLVM was installed by Chocolatey, so add the install location to the path.
            $env:PATH = "$($env:SystemDrive)\Program Files\LLVM\bin;$env:Path"
        }

        if (Get-Command clang-tidy -ErrorAction SilentlyContinue) {
            # Only run clang-tidy if it's installed. This is because the package used by chocolatey on
            # the build pipeline doesn't include clang-tidy, so we allow skipping that there and let
            # the Linux build catch tidy issues.
            $clangTidy = "-DCMAKE_CXX_CLANG_TIDY=clang-tidy"
        }
    }
    else {
        Write-Host "##vso[task.logissue type=warning;]Failed to identify the OS. Will use default CXX compiler"
    }

    $cmakeBuildFolder = (Join-Path $Path bin $Env:BUILD_CONFIGURATION)
    if (-not (Test-Path $cmakeBuildFolder)) {
        New-Item -Path $cmakeBuildFolder -ItemType "directory"
    }

    $all_ok = $true

    Push-Location $cmakeBuildFolder

    $buildType = $Env:BUILD_CONFIGURATION
    if ($buildType -eq "Release") {
        $buildType = "RelWithDebInfo"
    }

    cmake -G Ninja $CMAKE_C_COMPILER $CMAKE_CXX_COMPILER $clangTidy -D CMAKE_BUILD_TYPE="$buildType" ../.. | Write-Host
    if ($LastExitCode -ne 0) {
        Write-Host "##vso[task.logissue type=error;]Failed to generate $Name."
        $all_ok = $false
    }
    else {
        cmake --build . --target install | Write-Host
        if ($LastExitCode -ne 0) {
            Write-Host "##vso[task.logissue type=error;]Failed to build $Name."
            $all_ok = $false
        }
    }

    Pop-Location

    $env:CXXFLAGS = $oldCXXFLAGS
    $env:CFLAGS = $oldCFLAGS

    return $all_ok
}

function Test-CTest {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Path,

        [Parameter()]
        [string]
        $Name
    )
    
    Write-Host "##[info]Test $Name"

    $all_ok = $true
    Push-Location $Path

    ctest --verbose | Write-Host
    
    if ($LastExitCode -ne 0) {
        Write-Host "##vso[task.logissue type=error;]Failed to test $Name"
        $all_ok = $False
    }
    
    Pop-Location

    return $all_ok
}
