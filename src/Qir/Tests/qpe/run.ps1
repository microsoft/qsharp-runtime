$OldLD_LIBRARY_PATH = $Env:LD_LIBRARY_PATH
    $Env:LD_LIBRARY_PATH = "$PSScriptRoot/build:$Env:LD_LIBRARY_PATH"
    #Write-Host "$Env:LD_LIBRARY_PATH"
    Invoke-Expression "./build/qpe py_out.json"
$Env:LD_LIBRARY_PATH = $OldLD_LIBRARY_PATH