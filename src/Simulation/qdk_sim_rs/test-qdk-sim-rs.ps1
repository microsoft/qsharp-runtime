& (Join-Path $PSScriptRoot ".." ".." ".." "build" "set-env.ps1");

Push-Location $PSScriptRoot
    # Start with the quick check first and make sure that Rust sources
    # meet formatting and style guide rules.
    cargo fmt -- --check

    # Check linting rules defined by clippy.
    # If there's a false positive, that check should be explicitly disabled
    # at the point where the false positive occurs with an explanation as to
    # why it's OK.
    cargo clippy -- -D warnings

    # If running in CI, use cargo2junit to expose unit tests to the
    # PublishTestResults task.
    if ("$Env:TF_BUILD" -ne "") {
        cargo install cargo2junit
        cargo test -- -Z unstable-options --format json `
            | cargo2junit `
            <# We use this name to match the *_results.xml pattern that is used
               to find test results in steps-wrap-up.yml. #> `
            | Out-File -FilePath opensim_results.xml -Encoding utf8NoBOM
    } else {
        # Outside of CI, show human-readable output.
        cargo test
    }

    # Run performance benchmarks as well.
    cargo bench

    # This step isn't required, but we use it to upload run summaries.
    $reportPath = (Join-Path "target" "criterion");
    $perfDest = (Join-Path $Env:DROPS_DIR "perf" "qdk_sim_rs");
    if (Get-Item -ErrorAction SilentlyContinue $reportPath) {
        New-Item -Type Directory -Force -Path $perfDest;
        Copy-Item -Recurse -Force -Path $reportPath -Destination $perfDest;
    }

    # Free disk space by cleaning up.
    # Note that this takes longer, but saves ~1 GB of space, which is
    # exceptionally helpful in CI builds.
    cargo clean
Pop-Location
