Push-Location (Join-Path $PSScriptRoot runtime)
    # TODO: Set debug/release flag.
    cargo build
Pop-Location
