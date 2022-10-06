#Requires -PSEdition Core

Include (Join-Path $PSScriptRoot .. .. .. build set-env.ps1)
Include (Join-Path $PSScriptRoot "prerequisites.ps1")

task default -depends build-qdk-sim-rs

task build-qdk-sim-rs -depends set-env, qdk-sim-rs-prerequisites {
 
    # Start with the quick check first and make sure that Rust sources
    # meet formatting and style guide rules.
    exec -workingDirectory $PSScriptRoot {
        cargo fmt -- --check
    }

    # Check linting rules defined by clippy, a linting tool provided with the
    # Rust toolchain. Please see https://github.com/rust-lang/rust-clippy
    # and https://rust-lang.github.io/rust-clippy/master/index.html
    # for more information.
    # If there's a false positive, that check should be explicitly disabled
    # at the point where the false positive occurs with an explanation as to
    # why it's OK.
    exec -workingDirectory $PSScriptRoot {
        cargo clippy --all-targets -- -D warnings
    }

    $releaseFlag = "$Env:BUILD_CONFIGURATION" -eq "Release" ? @("--release") : @()

    # Actually run the build.
    exec -workingDirectory $PSScriptRoot {
        cargo build -Z unstable-options @releaseFlag --out-dir "drop"
    }

    # Make sure docs are complete.
    $Env:RUSTDOCFLAGS = "--html-in-header $(Resolve-Path docs-includes/header.html) " + `
                        "--html-after-content $(Resolve-Path docs-includes/after.html)"
    exec -workingDirectory $PSScriptRoot {
        cargo doc
    }

    # When building in CI, free disk space by cleaning up.
    # Note that this takes longer, but saves ~1 GB of space.
    if ($IsCI) {
        exec -workingDirectory $PSScriptRoot {
            cargo clean;
        }
    }
}
