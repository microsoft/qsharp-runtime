& (Join-Path $PSScriptRoot ".." ".." ".." "build" "set-env.ps1");
$IsCI = "$Env:TF_BUILD" -ne "" -or "$Env:CI" -eq "true";

Push-Location $PSScriptRoot
    $releaseFlag = "$Env:BUILD_CONFIGURATION" -eq "Release" ? @("--release") : @();

    # Enable control flow guard (see https://github.com/microsoft/qsharp-runtime/pull/647)
    # for interoperating Rust and C.
    # NB: CFG is only supported on Windows, but the Rust flag is supported on
    #     all platforms; it's ignored on platforms without CFG functionality.
    $Env:RUSTFLAGS = "-C control-flow-guard";

    # Actually run the build.
    cargo +nightly build -Z unstable-options @releaseFlag --out-dir "drop";

    # Make sure docs are complete.
    $Env:RUSTDOCFLAGS = "--html-in-header $(Resolve-Path docs-includes/header.html) " + `
                        "--html-after-content $(Resolve-Path docs-includes/after.html)"
    cargo +nightly doc;

    # When building in CI, free disk space by cleaning up.
    # Note that this takes longer, but saves ~1 GB of space.
    if ($IsCI) {
        cargo clean;
    }
Pop-Location
