& (Join-Path $PSScriptRoot ".." ".." ".." "build" "set-env.ps1");

$DropPath = Join-Path $Env:DROP_NATIVE "qdk_sim_rs";

Push-Location $PSScriptRoot
    $releaseFlag = "$Env:BUILD_CONFIGURATION" -eq "Release" ? @("--release") : @();

    # Enable control flow guard (see https://github.com/microsoft/qsharp-runtime/pull/647)
    # for interoperating Rust and C. This feature is stable (hence -C), but
    # only provides complete safety guarantees when the standard library is
    # also rebuilt with the same rustc flags.
    # NB: CFG is only supported on Windows, but the Rust flag is supported on
    #     all platforms; it's ignored on platforms without CFG functionality.
    $Env:RUSTFLAGS = "-C control-flow-guard";
    # To support rebuilding the Rust standard library with CFG enabled, we need
    # the Rust source code to be installed with rustup.
    rustup +nightly component add rust-src;

    # Actually run the build.
    # TODO: enable "-Z build-std" to fully support CFG.
    cargo +nightly build -Z unstable-options @releaseFlag --out-dir $DropPath;

    # Make sure docs are complete.
    $Env:RUSTDOCFLAGS = "--html-in-header $(Resolve-Path docs-includes/header.html) " + `
                        "--html-after-content $(Resolve-Path docs-includes/after.html)"
    cargo +nightly doc;

    # Free disk space by cleaning up.
    # Note that this takes longer, but saves ~1 GB of space, which is
    # exceptionally helpful in CI builds.
    cargo clean;
Pop-Location
