#Requires -PSEdition Core

param (
    [Parameter()]
    [String]
    $DirPath = "$PSScriptRoot"
)

$tmpFile = "format.log"

#Write-Host "1"
#"$DirPath/*.cpp","$DirPath/*.c","$DirPath/*.h","$DirPath/*.hpp" | get-childitem -Recurse `
#    | ?{$_.fullname -notlike "*\Externals\*"} | ?{$_.fullname -notlike "*\drops\*"} | ?{$_.fullname -notlike "*\bin\*"} `
#    | %{clang-format -n -style=file $_.fullname}
#
#Write-Host "2"
#"$DirPath/*.cpp","$DirPath/*.c","$DirPath/*.h","$DirPath/*.hpp" | get-childitem -Recurse `
#    | ?{$_.fullname -notlike "*\Externals\*"} | ?{$_.fullname -notlike "*\drops\*"} | ?{$_.fullname -notlike "*\bin\*"} `
#    | %{clang-format -n -style=file $_.fullname} 2>format.log

#Write-Host "3"
#$filesRequireFormatting = get-content $tmpFile | ?{$_ -like "*: warning:*"} `
#                            | %{[string]::join(":",($_.split("warning:")[0].split(":") | select -SkipLast 3))} `
#                            | sort | unique
#Remove-Item $tmpFile

Write-Host "1"
&{
   Write-Warning "warning"
   Write-Error "error"
   Write-Output "output"
} *>$tmpFile

Write-Host "2"
type $tmpFile

Write-Host "3"
throw "Formatting check failed for QIR Runtime sources"

if (! ("$filesRequireFormatting" -eq ""))
{
    Write-Host "##vso[task.logissue type=error;]Formatting check failed. The following files need to be formatted before compiling: "
    Write-Host "(You may use Clang-Format extension in VSCode or clang-format in command line or see https://clang.llvm.org/docs/ClangFormat.html)"
    $filesRequireFormatting | Format-Table
    clang-format --version
    throw "Formatting check failed for QIR Runtime sources"
}
