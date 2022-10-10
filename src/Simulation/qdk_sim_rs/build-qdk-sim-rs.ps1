#Requires -PSEdition Core

Include (Join-Path $PSScriptRoot .. .. .. build set-env.ps1)

task default -depends qdk-sim-rs-fmt, qdk-sim-rs-clippy, qdk-sim-rs-build, qdk-sim-rs-docs, qdk-sim-rs-clean

task qdk-sim-rs-fmt {
    # Start with the quick check first and make sure that Rust sources
    # meet formatting and style guide rules.
    exec {
        cargo fmt -- --check
    }
}

task qdk-sim-rs-clippy {
    # Check linting rules defined by clippy, a linting tool provided with the
    # Rust toolchain. Please see https://github.com/rust-lang/rust-clippy
    # and https://rust-lang.github.io/rust-clippy/master/index.html
    # for more information.
    # If there's a false positive, that check should be explicitly disabled
    # at the point where the false positive occurs with an explanation as to
    # why it's OK.
    exec {
        cargo clippy --all-targets -- -D warnings
    }
}

task qdk-sim-rs-build -depends set-env {
    $releaseFlag = "$Env:BUILD_CONFIGURATION" -eq "Release" ? @("--release") : @()

    # Actually run the build.
    exec {
        cargo build -Z unstable-options @releaseFlag --out-dir "drop"
    }
}

task qdk-sim-rs-docs {
    # Make sure docs are complete.
    $Env:RUSTDOCFLAGS = "--html-in-header $(Resolve-Path docs-includes/header.html) " + `
                        "--html-after-content $(Resolve-Path docs-includes/after.html)"
    exec -workingDirectory $PSScriptRoot {
        cargo doc
    }
}

task qdk-sim-rs-clean -precondition { ($IsCI) } {
    # When building in CI, free disk space by cleaning up.
    # Note that this takes longer, but saves ~1 GB of space.
    exec -workingDirectory $PSScriptRoot {
        cargo clean;
    }
}
