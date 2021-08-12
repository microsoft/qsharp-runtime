#Requires -PSEdition Core

$tmpFile = "format.log"

"*.cpp","*.c","*.h","*.hpp" | get-childitem -Recurse `
    | ?{$_.fullname -notlike "*\Externals\*"} | ?{$_.fullname -notlike "*\drops\*"} | ?{$_.fullname -notlike "*\bin\*"} `
    | %{clang-format -n -Werror -style=file $_.fullname} 2> $tmpFile

$filesRequireFormatting = get-content $tmpFile | ?{$_ -like "*: error:*"} `
                            | %{[string]::join(":",($_.split("error:")[0].split(":") | select -SkipLast 3))} `
                            | sort | unique
Remove-Item $tmpFile

if (! ("$filesRequireFormatting" -eq ""))
{
    Write-Host "##vso[task.logissue type=error;]Formatting check failed. The following files need to be formatted before compiling: "
    Write-Host "(You may use Clang-Format extension in VSCode or clang-format in command line or see https://clang.llvm.org/docs/ClangFormat.html)"
    $filesRequireFormatting | Format-Table
    throw "Formatting check failed for QIR sources"
}
