:: Copyright (c) Microsoft Corporation. All rights reserved.
:: Licensed under the MIT License.
@echo ON

:: Check dependencies
:: Notice that we can't check for msbuild as it's not in the build's machine path...
cmake   -version || GOTO missingDependency
echo.

SET BUILD_FOLDER=build
SET DROP_FOLDER=%BUILD_ARTIFACTSTAGINGDIRECTORY%\drop\src\simulation\Native\build

IF NOT EXIST linux mkdir linux
IF EXIST %DROP_FOLDER%\libMicrosoft.Quantum.Simulator.Runtime.so    copy %DROP_FOLDER%\libMicrosoft.Quantum.Simulator.Runtime.so     linux\Microsoft.Quantum.Simulator.Runtime.dll

IF NOT EXIST osx mkdir osx
IF EXIST %DROP_FOLDER%\libMicrosoft.Quantum.Simulator.Runtime.dylib copy %DROP_FOLDER%\libMicrosoft.Quantum.Simulator.Runtime.dylib  osx\Microsoft.Quantum.Simulator.Runtime.dll

IF NOT EXIST %BUILD_FOLDER% mkdir %BUILD_FOLDER%
pushd %BUILD_FOLDER%

cmake -A "x64" ^
    -DBUILD_SHARED_LIBS:BOOL="1" ^
    ..

popd

:: Done
GOTO EOF


:missingDependency
echo.
echo One or more dependencies are missing. Refer to README.md to make sure you have all known dependencies.
echo.
EXIT /B 1001


:EOF
