#!/bin/bash 
set -e

: ${BUILD_BUILDNUMBER:="0.0.0.1"}
: ${BUILD_CONFIGURATION:="Debug"}
: ${BUILD_VERBOSITY:="m"}
: ${IQSHARP_HOSTING_ENV:="dev-machine"}
: ${ASSEMBLY_VERSION:="$BUILD_BUILDNUMBER"}
: ${NUGET_VERSION:="$ASSEMBLY_VERSION-alpha"}
: ${NUGET_OUTDIR:="$(cd ..;pwd)/drop/nugets"}
: ${DOCS_OUTDIR:="$(cd ..;pwd)/drop/docs"}

