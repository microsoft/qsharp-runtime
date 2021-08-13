#Requires -PSEdition Core
#Requires -Version 7.1

param (
    [Parameter()]
    [String]
    $DirPath = "$PSScriptRoot"
)

$tmpFile = "format.log"

$OldErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference='Continue'
"$DirPath/*.cpp","$DirPath/*.c","$DirPath/*.h","$DirPath/*.hpp" | get-childitem -Recurse `
    | ?{$_.fullname -notlike "*\Externals\*"} | ?{$_.fullname -notlike "*\drops\*"} | ?{$_.fullname -notlike "*\bin\*"} `
    | %{clang-format -n -style=file $_.fullname} 2>format.log
$ErrorActionPreference=$OldErrorActionPreference

$filesRequireFormatting = get-content $tmpFile | ?{$_ -like "*: warning:*"} `
                            | %{[string]::join(":",($_.split("warning:")[0].split(":") | select -SkipLast 3))} `
                            | sort | unique
Remove-Item $tmpFile

if (! ("$filesRequireFormatting" -eq ""))
{
    Write-Host "##vso[task.logissue type=error;]Formatting check failed. The following files need to be formatted before compiling: "
    Write-Host "(You may use Clang-Format extension in VSCode or clang-format in command line or see https://clang.llvm.org/docs/ClangFormat.html)"
    $filesRequireFormatting | Format-Table
    clang-format --version
    throw "Formatting check failed for QIR Runtime sources"
}
