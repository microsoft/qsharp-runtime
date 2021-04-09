# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

$all_ok = $True

Write-Host "##[info]Test QIR Controller"

$controllerProject = (Join-Path $PSScriptRoot QirController.csproj)
$testCasesFolder = (Join-Path $PSScriptRoot "test-cases")
$testArtifactsFolder = (Join-Path $PSScriptRoot "test-artifacts")

if (!(Test-Path $testArtifactsFolder -PathType Container)) {
    New-Item -ItemType Directory -Force -Path $testArtifactsFolder
}
Get-ChildItem -Path $testArtifactsFolder | Remove-Item -Force

# Go through each input file in the test cases folder.
Get-ChildItem $testCasesFolder -Filter *.in |
Foreach-Object {
    # Get the paths to the output and error files to pass to the QIR controller.
    $outputFile = (Join-Path $testArtifactsFolder ($_.BaseName + ".out"))
    $errorFile = (Join-Path $testArtifactsFolder ($_.BaseName + ".err"))
    dotnet run --project $controllerProject -- --input $_.FullName --output $outputFile --error $errorFile --includeDirectory "placeholder for now" --libraryDirectory "placeholder for now"

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
        elseif ((Test-Path $errorFile)) {
            $actualError = Get-Content -Path $errorFile -Raw

            # An error file should not have been generated, so fail test if one was found.
            Write-Host "##vso[task.logissue type=error;]Failed QIR Controller test case: $($_.BaseName)"
            Write-Host "##[info]Unexpected error file was found:"
            Write-Host $actualError
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
    elseif ((Test-Path $outputFile)) {
        $actualOutput = Get-Content -Path $outputFile -Raw

        # An error file should not have been generated, so fail test if one was found.
        Write-Host "##vso[task.logissue type=error;]Failed QIR Controller test case: $($_.BaseName)"
        Write-Host "##[info]Unexpected output file was found:"
        Write-Host $actualOutput
        $script:all_ok = $False
    }
    else {
        Write-Host "##[info]Test case '$($_.BaseName)' passed"
    }
}

if (-not $all_ok) {
    throw "At least one project failed testing. Check the logs."
}
