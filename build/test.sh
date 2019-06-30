#!/bin/bash 
set -x
set -e

. ./set-env.sh

echo "##[info]Test Native simulator"
pushd ../src/Simulation/Native/build
ctest -C $BUILD_CONFIGURATION
popd


test_one() {
    dotnet test $1 \
        -c $BUILD_CONFIGURATION \
        -v $BUILD_VERBOSITY \
        --logger trx \
        /property:DefineConstants=$ASSEMBLY_CONSTANTS \
        /property:Version=$ASSEMBLY_VERSION
}

echo "##[info]Testing C# code generation"
test_one '../src/Simulation/CsharpGeneration.Tests/Tests.CsharpGeneration.fsproj'

echo "##[info]Testing Roslyn Wrapper"
test_one '../src/Simulation/RoslynWrapper.Tests/Tests.RoslynWrapper.fsproj'

echo "##[info]Testing Tracer"
test_one '../src/Simulation/QCTraceSimulator.Tests/Tests.Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime.csproj'

echo "##[info]Testing Q# Simulators"
test_one '../src/Simulation/Simulators.Tests/Tests.Microsoft.Quantum.Simulation.Simulators.csproj'

