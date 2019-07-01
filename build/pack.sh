#!/bin/bash 
set -x
set -e

. ./set-env.sh

echo "##[info]Copy Native simulator xplat binaries"
pushd ../src/Simulation/Native
if [ ! -d osx   ]; then mkdir -p osx;   fi
if [ ! -d linux ]; then mkdir -p linux; fi
DROP="$DROP_NATIVE/src/Simulation/Native/build"
if [ -f $DROP/libMicrosoft.Quantum.Simulator.Runtime.dylib ]; then  cp $DROP/libMicrosoft.Quantum.Simulator.Runtime.dylib osx/Microsoft.Quantum.Simulator.Runtime.dll; fi
if [ -f $DROP/libMicrosoft.Quantum.Simulator.Runtime.so    ]; then  cp $DROP/libMicrosoft.Quantum.Simulator.Runtime.so  linux/Microsoft.Quantum.Simulator.Runtime.dll; fi
popd


pack_one() {
    nuget pack $1 \
        -OutputDirectory $NUGET_OUTDIR \
        -Properties Configuration=$BUILD_CONFIGURATION \
        -Version $NUGET_VERSION \
        -Verbosity detailed \
        $2
}

echo "##[info]Using nuget to create packages"
pack_one ../src/Simulation/CsharpGeneration/Microsoft.Quantum.CsharpGeneration.fsproj -IncludeReferencedProjects
pack_one ../src/Simulation/Simulators/Microsoft.Quantum.Simulators.csproj -IncludeReferencedProjects
pack_one ../src/ProjectTemplates/Microsoft.Quantum.ProjectTemplates.nuspec
pack_one ../src/Microsoft.Quantum.Development.Kit.nuspec
pack_one ../src/Xunit/Microsoft.Quantum.Xunit.csproj
