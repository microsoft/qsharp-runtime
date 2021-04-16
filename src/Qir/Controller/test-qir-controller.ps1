# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

$all_ok = $True

Write-Host "##[info]Test QIR Controller"

$controllerProject = (Join-Path $PSScriptRoot QirController.csproj)
$testCasesFolder = (Join-Path $PSScriptRoot "test-cases")
$testArtifactsFolder = (Join-Path $PSScriptRoot "test-artifacts")
$includeDirectory = (Join-Path $testArtifactsFolder "include")
$headerPaths = @((Join-Path $PSScriptRoot "..\..\Qir\Common\externals\CLI11"), (Join-Path $PSScriptRoot "..\..\Qir\Runtime\public"))
$libraryPaths =  @((Join-Path $PSScriptRoot "..\..\Qir\Runtime\build\Debug\bin"), (Join-Path $PSScriptRoot "..\..\Simulation\Simulators\bin\Debug\netstandard2.1"))
$includeDirectory = (Join-Path $testArtifactsFolder "include")
$libraryDirectory = (Join-Path $testArtifactsFolder "library")
$runtimeScript = (Join-Path $PSScriptRoot "..\..\Qir\Runtime\build-qir-runtime.ps1")

# Build the runtime
Invoke-Expression $runtimeScript

if (!(Test-Path $testArtifactsFolder -PathType Container)) {
    New-Item -ItemType Directory -Force -Path $testArtifactsFolder
}
Get-ChildItem -Path $testArtifactsFolder | Remove-Item -Force -Recurse

# Copy includes to the include folder
New-Item -ItemType "directory" -Path $includeDirectory -Force
foreach ( $path in $headerPaths )
{
    Get-ChildItem $path -File |
    Foreach-Object {
        Copy-Item $_ -Destination (Join-Path $includeDirectory $_.Name)
    }
}

# Copy libraries to the library folder
New-Item -ItemType "directory" -Path $libraryDirectory -Force
foreach ( $path in $libraryPaths )
{
    Get-ChildItem $path -File |
    Foreach-Object {
        Copy-Item $_ -Destination (Join-Path $libraryDirectory $_.Name)
    }
}

# Go through each input file in the test cases folder.
Get-ChildItem $testCasesFolder -Filter *.in |
Foreach-Object {
    # Get the paths to the output and error files to pass to the QIR controller.
    $outputFile = (Join-Path $testArtifactsFolder ($_.BaseName + ".out"))
    $errorFile = (Join-Path $testArtifactsFolder ($_.BaseName + ".err"))
    dotnet run --project $controllerProject -- --input $_.FullName --output $outputFile --error $errorFile --includeDirectory $includeDirectory --libraryDirectory $libraryDirectory

    # Compare the expected content of the output and error files vs the actual content.
    $expectedOutputFile = (Join-Path $testCasesFolder ($_.BaseName + ".out"))
    $expectedErrorFile = (Join-Path $testCasesFolder ($_.BaseName + ".err"))

    if ((Test-Path $expectedOutputFile)) {
        $expectedOutput = Get-Content -Path $expectedOutputFile -Raw
        $actualOutput = Get-Content -Path $outputFile -Raw
        if (-not ($expectedOutput -ceq $actualOutput)) {
            Write-Host "##vso[task.logissue type=error;]Failed QIR Controller test case: $($_.BaseName)"
            Write-Host "##[info]Expected output:"
            Write-Host $expectedOutput
            Write-Host "##[info]Actual output:"
            Write-Host $actualOutput
            $script:all_ok = $False
        }
        else {
            Write-Host "##[info]Test case '$($_.BaseName)' passed"
        }
        continue;
    }

    $expectedError = Get-Content -Path $expectedErrorFile -Raw
    $actualError = Get-Content -Path $errorFile -Raw
    if (-not ($expectedError -ceq $actualError)) {
        Write-Host "##vso[task.logissue type=error;]Failed QIR Controller test case: $($_.BaseName)"
        Write-Host "##[info]Expected error:"
        Write-Host $expectedError
        Write-Host "##[info]Actual error:"
        Write-Host $actualError
        $script:all_ok = $False
        continue
    }
    else {
        Write-Host "##[info]Test case '$($_.BaseName)' passed"
    }
}

if (-not $all_ok) {
    throw "At least one project failed testing. Check the logs."
}
