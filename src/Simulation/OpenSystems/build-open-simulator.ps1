& (Join-Path $PSScriptRoot ".." ".." ".." "build" "set-env.ps1");

Push-Location (Join-Path $PSScriptRoot runtime)
    $releaseFlag = "$Env:BUILD_CONFIGURATION" -eq "Release" ? @("--release") : @();
    cargo build @releaseFlag;
Pop-Location
