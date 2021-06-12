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
    $oldCC = $env:CC
    $oldCXX = $env:CXX
    $oldRC = $env:RC
    $oldCCFLAGS  = $env:CCFLAGS
    $oldCXXFLAGS = $env:CXXFLAGS

    $clangTidy = ""

    $warningFlags = "-Werror"

    # -Wall
    #   -Wmisleading-indentation, 
    #   -Wmost, 
    #       -Wcast-of-sel-type,         -Winfinite-recursion,            -Woverloaded-virtual,       -Wstring-plus-int,      
    #       -Wchar-subscripts,          -Wint-in-bool-context,           -Wprivate-extern,           -Wtautological-compare, 
    #       -Wcomment,                  -Wmismatched-tags,               -Wrange-loop-construct,     -Wtrigraphs,            
    #       -Wdelete-non-virtual-dtor,  -Wmissing-braces,                -Wreorder,                  -Wuninitialized,        
    #       -Wextern-c-compat,          -Wmove,                          -Wreturn-type,              -Wunknown-pragmas,      
    #       -Wfor-loop-analysis,        -Wmultichar,                     -Wself-assign,              -Wunused,               
    #       -Wformat,                   -Wobjc-designated-initializers,  -Wself-move,                -Wuser-defined-warnings,
    #       -Wframe-address,            -Wobjc-flexible-array,           -Wsizeof-array-argument,    -Wvolatile-register-var.
    #       -Wimplicit,                 -Wobjc-missing-super-calls,      -Wsizeof-array-decay,       
    #   -Wparentheses, 
    #   -Wswitch, 
    #   -Wswitch-bool.
    $warningFlags += " -Wall"       # https://clang.llvm.org/docs/DiagnosticsReference.html#wall

    # -Wextra
    #   -Wdeprecated-copy, -Wempty-init-stmt, -Wfuse-ld-path, -Wignored-qualifiers, -Winitializer-overrides, 
    #   -Wmissing-field-initializers, -Wmissing-method-return-type, -Wnull-pointer-arithmetic, 
    #   -Wsemicolon-before-method-body, -Wsign-compare, -Wstring-concatenation, -Wunused-but-set-parameter, 
    #   -Wunused-parameter.
    $warningFlags += " -Wextra"     # https://clang.llvm.org/docs/DiagnosticsReference.html#wextra

    #$warningFlags += " -Wno-error=unused "   # Treat unused entities as warnings rather than errors.  https://clang.llvm.org/docs/DiagnosticsReference.html#wunused
    #$warningFlags += " -Wno-error=unused-parameter"

    $env:CFLAGS   += $warningFlags
    $env:CXXFLAGS += $warningFlags

    if (($IsMacOS) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Darwin"))))
    {
        Write-Host "On MacOS build $Name using the default C/C++ compiler (should be AppleClang)"
    }
    elseif (($IsLinux) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Lin"))))
    {
        Write-Host "On Linux build $Name using Clang"
        $env:CC = "clang-11"
        $env:CXX = "clang++-11"
        $env:RC = "clang++-11"
        $clangTidy = "-DCMAKE_CXX_CLANG_TIDY=clang-tidy-11"
    }
    elseif (($IsWindows) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Win"))))
    {
        Write-Host "On Windows build $Name using Clang"
        $env:CC = "clang.exe"
        $env:CXX = "clang++.exe"
        $env:RC = "clang++.exe"

        if (!(Get-Command clang -ErrorAction SilentlyContinue) -and (choco find --idonly -l llvm) -contains "llvm") {
            # LLVM was installed by Chocolatey, so add the install location to the path.
            $env:PATH += ";$($env:SystemDrive)\Program Files\LLVM\bin"
        }

        if (Get-Command clang-tidy -ErrorAction SilentlyContinue) {
            # Only run clang-tidy if it's installed. This is because the package used by chocolatey on
            # the build pipeline doesn't include clang-tidy, so we allow skipping that there and let
            # the Linux build catch tidy issues.
            $clangTidy = "-DCMAKE_CXX_CLANG_TIDY=clang-tidy"
        }
    } else {
        Write-Host "##vso[task.logissue type=warning;]Failed to identify the OS. Will use default CXX compiler"
    }

    $cmakeBuildFolder = (Join-Path $Path bin $Env:BUILD_CONFIGURATION)
    if (-not (Test-Path $cmakeBuildFolder)) {
        New-Item -Path $cmakeBuildFolder -ItemType "directory"
    }

    $all_ok = $true

    Push-Location $cmakeBuildFolder

    $buildType = $Env:BUILD_CONFIGURATION
    if ($buildType -eq "Release"){
        $buildType = "RelWithDebInfo"
    }

    cmake -G Ninja $clangTidy -D CMAKE_BUILD_TYPE="$buildType" ../.. | Write-Host
    if ($LastExitCode -ne 0) {
        Write-Host "##vso[task.logissue type=error;]Failed to generate $Name."
        $all_ok = $false
    } else {
        cmake --build . --target install | Write-Host
        if ($LastExitCode -ne 0) {
            Write-Host "##vso[task.logissue type=error;]Failed to build $Name."
            $all_ok = $false
        }
    }

    Pop-Location

    $env:CXXFLAGS = $oldCXXFLAGS
    $env:CCFLAGS  = $oldCCFLAGS

    $env:CC = $oldCC
    $env:CXX = $oldCXX
    $env:RC = $oldRC

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