# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#Requires -Version 7.1

param (
    [Parameter()]
    [String]
    $Path = "$PSScriptRoot"
)

if (-not $IsMacOS) {   # We do not control the clang-format version on MacOS, and that version (12.0.1) requires formatting contradicting the version on Win and Linux (11.1.0).
    $tmpFile = "format.log"

    $clangFormatCommand = "clang-format"
    if(($IsLinux) -or ((Test-Path Env:/AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Lin")))) {
        $script:clangFormatCommand = "clang-format-14"
    }

    $OldErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference='Continue'
    "*.cpp", "*.c", "*.h", "*.hpp" `
        | ForEach-Object { Join-Path $Path $_ } `
        | Get-ChildItem -Recurse `
        <# The -notlike fragments below understand different path separators for Win and Unix. Unifying. #> `
        | ForEach-Object {$_.FullName -replace "\\", "/"} `
        | Where-Object { $_ -notlike "*/Externals/*" } `
        | Where-Object { $_ -notlike "*/drops/*" } `
        | Where-Object { $_ -notlike "*/bin/*" } `
        | Where-Object {$_ -notlike "*/FullStateDriverGenerator/*"} `
        | ForEach-Object {
            & $clangFormatCommand -n -style=file $_
        } 2>$tmpFile
    $ErrorActionPreference=$OldErrorActionPreference

    $filesRequireFormatting = get-content $tmpFile | ?{$_ -like "*: warning:*"} `
                                | %{[string]::join(":",($_.split("warning:")[0].split(":") | select -SkipLast 3))} `
                                | sort | unique
    Remove-Item $tmpFile

    if ("$filesRequireFormatting" -ne "")
    {
        Write-Host "##vso[task.logissue type=error;]Formatting check failed. The following files need to be formatted before compiling: "
        Write-Host ("(See https://github.com/microsoft/qsharp-runtime/tree/main/src/Qir/Runtime#coding-style-and-conventions " +
                    "or https://github.com/microsoft/qsharp-runtime/blob/main/src/Qir/.clang-format)")
        $filesRequireFormatting | Format-Table
        & $clangFormatCommand --version
        throw "Formatting check failed for QIR Runtime sources"
    }
}
