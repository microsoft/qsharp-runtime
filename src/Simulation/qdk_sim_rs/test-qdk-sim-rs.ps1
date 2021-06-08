& (Join-Path $PSScriptRoot ".." ".." ".." "build" "set-env.ps1");
$IsCI = "$Env:TF_BUILD" -ne "" -or "$Env:CI" -eq "true";

$script:allOk = $true;

Push-Location $PSScriptRoot
    # If running in CI, use cargo2junit to expose unit tests to the
    # PublishTestResults task.
    if ($IsCI) {
        cargo install cargo2junit
        $testJson = cargo +nightly test -- -Z unstable-options --format json;
        $script:allOk = $script:allOk -and $LASTEXITCODE -eq 0;

        $testJson `
            | cargo2junit `
            <# We use this name to match the *_results.xml pattern that is used
               to find test results in steps-wrap-up.yml. #> `
            | Out-File -FilePath opensim_results.xml -Encoding utf8NoBOM
    } else {
        # Outside of CI, show human-readable output.
        cargo +nightly test
        $script:allOk = $script:allOk -and $LASTEXITCODE -eq 0;
    }

    # Run performance benchmarks as well.
    cargo bench
    $script:allOk = $script:allOk -and $LASTEXITCODE -eq 0;

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
        # When building in CI, free disk space by cleaning up.
    # Note that this takes longer, but saves ~1 GB of space.
    if ($IsCI) {
        cargo clean;
    }
Pop-Location

if (-not $script:allOk) {
    Write-Host "##vso[task.logissue type=error;]Failed to test qdk_sim_rs — please check logs above."
    exit -1;
}
