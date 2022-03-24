$Env:BUILD_CONFIGURATION = "Debug"
$Name = "QPE"

if ( -not (Test-Path nlohmann_json) ) {
  git clone https://github.com/nlohmann/json.git nlohmann_json
}

$CMAKE_C_COMPILER = ""
$CMAKE_CXX_COMPILER = ""

if ($IsMacOS) {
    Write-Host "On MacOS build $Name using the default C/C++ compiler (should be AppleClang)"
}
elseif ($IsLinux) {
    Write-Host "On Linux build $Name using Clang"
    $CMAKE_C_COMPILER = "-DCMAKE_C_COMPILER=clang-13"
    $CMAKE_CXX_COMPILER = "-DCMAKE_CXX_COMPILER=clang++-13"
}
elseif ($IsWindows) {
    Write-Host "On Windows build $Name using Clang"
    $CMAKE_C_COMPILER = "-DCMAKE_C_COMPILER=clang.exe"
    $CMAKE_CXX_COMPILER = "-DCMAKE_CXX_COMPILER=clang++.exe"
}
else {
    Write-Host "##vso[task.logissue type=warning;]Failed to identify the OS. Will use default CXX compiler"
}

$BuildPath = (Join-Path $PSScriptRoot "build")
if (-not (Test-Path $BuildPath)) {
    New-Item -Path $BuildPath -ItemType "directory" > $Null
    Copy-Item -Verbose -Path "$PSScriptRoot/../../Runtime/bin/Debug/bin/*" -Destination "$BuildPath"
    Copy-Item -Verbose -Path "$PSScriptRoot/../../../Simulation/Native/build/*Microsoft.Quantum.Simulator.Runtime.*" -Destination "$BuildPath"
}

Push-Location $BuildPath 
    cmake -G Ninja $CMAKE_C_COMPILER $CMAKE_CXX_COMPILER -D CMAKE_VERBOSE_MAKEFILE:BOOL=ON .. | Write-Host
    cmake --build . --verbose| Write-Host
Pop-Location
