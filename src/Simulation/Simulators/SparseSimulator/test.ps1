# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

& (Join-Path $PSScriptRoot .. .. .. .. build set-env.ps1)

$FailureCommands = 'Write-Host "##vso[task.logissue type=error;] Failed to test SparseSimulator. See errors below or above." ;  Pop-Location ; Exit 1'

Push-Location $PSScriptRoot
    ( dotnet test . --configuration $Env:BUILD_CONFIGURATION ) || `
        ( Invoke-Expression $FailureCommands )
Pop-Location
