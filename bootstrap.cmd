:: Initializes the current repo
:: and prepares it for build
@echo off

dotnet  --info || GOTO missingDotnet
git --version  || GOTO missingGit


:: Initialize C++ runtime project
CALL :runtimeBootstrap

:: Initialize the compiler's nuspec file
CALL :nuspecBootstrap

:: Next steps are only needed for developers environment, they are skipped for cloud builds.
IF "%SKIPLOCALDEV%" == "true" GOTO EOF

:: Make sure everything is ready and builds locally.
cmake --build src\Runtime\build --target Microsoft.Quantum.Simulator.Runtime --config Release || EXIT /B 1
dotnet build src\CsharpGenerationApp     || EXIT /B 1
dotnet build Simulation.sln              || EXIT /B 1

:: Done
GOTO EOF

:: Bootstrap Runtime library
:runtimeBootstrap
pushd src\Runtime\
CALL bootstrap.cmd
popd
EXIT /B


:: Bootstrap the compiler nuspec
:nuspecBootstrap
pushd src\CsharpGeneration
CALL powershell -NoProfile .\FindNuspecReferences.ps1
popd

pushd src\Simulators
CALL powershell -NoProfile .\FindNuspecReferences.ps1
popd
EXIT /B

:missingGit
echo.
echo This script depends on git.
echo.
echo Make sure you install it as part of Visual Studio, and then run this
echo script inside the "Developer Command Prompt for VS 2017"
echo.
EXIT /B 1001


:missingDotnet
echo.
echo You need to install dotnet core to use/build Solid:
echo https://www.microsoft.com/net/download
echo.
EXIT /B 1002


:EOF
echo Your environment is now ready for developement.

