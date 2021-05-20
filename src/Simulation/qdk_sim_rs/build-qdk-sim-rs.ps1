& (Join-Path $PSScriptRoot ".." ".." ".." "build" "set-env.ps1");

$DropPath = Join-Path $Env:DROP_NATIVE "qdk_sim_rs";

Push-Location $PSScriptRoot
    $releaseFlag = "$Env:BUILD_CONFIGURATION" -eq "Release" ? @("--release") : @();
    cargo +nightly build -Z unstable-options @releaseFlag --out-dir $DropPath;

    # Make sure docs are complete.
    $Env:RUSTDOCFLAGS = "--html-in-header $(Resolve-Path docs-includes/header.html) " + `
                        "--html-after-content $(Resolve-Path docs-includes/after.html)"
    cargo +nightly doc --features doc;

    # Free disk space by cleaning up.
    # Note that this takes longer, but saves ~1 GB of space, which is
    # exceptionally helpful in CI builds.
    cargo clean;
Pop-Location
