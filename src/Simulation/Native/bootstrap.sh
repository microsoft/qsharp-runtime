#!/bin/bash -v
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

if [ "$(uname)" == "Darwin" ]; then
  GCC_VERSION=-7
  brew install gcc@7
else
  GCC_VERSION=""
fi

: ${BuildConfiguration:="Release"}
: ${BuildFolder:="build"}

echo Building in "$BuildFolder" with configuration "$BuildConfiguration" with gcc$GCC_VERSION

if [ ! -d $BuildFolder ]; then 
  mkdir -p $BuildFolder;
fi
pushd $BuildFolder

if [ CMakeCache.txt ]; then 
  rm CMakeCache.txt; 
fi
cmake -DBUILD_SHARED_LIBS:BOOL="1" -DCMAKE_C_COMPILER=gcc$GCC_VERSION -DCMAKE_CXX_COMPILER=g++$GCC_VERSION -DCMAKE_BUILD_TYPE=$BuildConfiguration ..

popd

