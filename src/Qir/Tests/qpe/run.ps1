$OldLD_LIBRARY_PATH = $Env:LD_LIBRARY_PATH
    $Env:LD_LIBRARY_PATH = "$PSScriptRoot/build:$Env:LD_LIBRARY_PATH"
    #Write-Host "$Env:LD_LIBRARY_PATH"
    #Invoke-Expression "./build/qpe py_out.json"
    date
    Invoke-Expression "./build/qpe 1e_0.181287518_-0.181287518.json"
    date
$Env:LD_LIBRARY_PATH = $OldLD_LIBRARY_PATH
