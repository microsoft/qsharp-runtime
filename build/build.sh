#!/bin/bash 
set -x
set -e

. ./set-env.sh

echo "##[info]Build Native simulator"
cmake --build ../src/Simulation/Native/build \
    --config $BUILD_CONFIGURATION


do_one() {
    dotnet $1 $2 \
        -c $BUILD_CONFIGURATION \
        -v $BUILD_VERBOSITY \
        /property:DefineConstants=$ASSEMBLY_CONSTANTS \
        /property:Version=$ASSEMBLY_VERSION \
        /property:QsharpDocsOutDir=$DOCS_OUTDIR
}

echo "##[info]Build C# code generation"
do_one publish '../src/Simulation/CsharpGeneration.App'

echo "##[info]Build Q# simulation"
do_one build '../Simulation.sln'

