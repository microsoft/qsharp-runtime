& (Join-Path $PSScriptRoot ".." ".." ".." "build" "set-env.ps1");

Push-Location (Join-Path $PSScriptRoot runtime)
    $releaseFlag = "$Env:BUILD_CONFIGURATION" -eq "Release" ? @("--release") : @();
    cargo build @releaseFlag;

    # Free disk space by cleaning up target/${config}/deps.
    # Note that this takes longer, but saves ~1 GB of space, which is
    # exceptionally helpful in CI builds.
    @("release", "debug") | ForEach-Object {
        $config = $_;
        @("deps", "build", "incremental") | ForEach-Object {
            Remove-Item -Recurse (Join-Path . target $config $_) -ErrorAction Continue -Verbose;
        }
    }
Pop-Location
