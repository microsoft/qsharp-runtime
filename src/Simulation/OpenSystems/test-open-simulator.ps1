Push-Location (Join-Path $PSScriptRoot runtime)
    cargo test
Pop-Location
