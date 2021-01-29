# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

message(INFO "*** build config: ${CMAKE_BUILD_TYPE}")

project(quantum-simulator)
cmake_minimum_required(VERSION 3.2.0 FATAL_ERROR)

set (CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
set (CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/config)

set(MICROSOFT_QUANTUM_SIMULATOR_VERSION_MAJOR $ENV{BUILD_MAJOR})
set(MICROSOFT_QUANTUM_SIMULATOR_VERSION_MINOR $ENV{BUILD_MINOR})
set(MICROSOFT_QUANTUM_SIMULATOR_VERSION_PATCH 0)
set(MICROSOFT_QUANTUM_SIMULATOR_YEAR 2020)


set(MICROSOFT_QUANTUM_SIMULATOR_VERSION $ENV{ASSEMBLY_VERSION})
set(MICROSOFT_QUANTUM_VERSION_STRING "quarcsw simulator version ${MICROSOFT_QUANTUM_SIMULATOR_VERSION}")
MESSAGE(STATUS "QUARCSW version: ${MICROSOFT_QUANTUM_SIMULATOR_VERSION}")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

ADD_DEFINITIONS(-D_SCL_SECURE_NO_WARNINGS)
# Configuration options (choose one to turn on)
option(BUILD_SHARED_LIBS "Build shared libraries" ON)
option(ENABLE_OPENMP  "Enable OpenMP Parallelization" ON)
option(USE_SINGLE_PRECISION "Use single-precision floating point operations" OFF)
option(HAVE_INTRINSICS "Have AVX intrinsics" OFF)
option(USE_GATE_FUSION "Use gate fusion" ON)

# windows specific flags
if (MSVC)
  # always create debug info
  add_definitions("/Zi")

  # build with no VC runtime depedencies:
  set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MT /Qspectre /guard:cf")
  set(CMAKE_CXX_FLAGS_DEBUG   "${CMAKE_CXX_FLAGS_DEBUG}   /MTd /Qspectre /guard:cf")
else (MSVC)
  set(CMAKE_CXX_FLAGS "-static-libgcc")
endif (MSVC)


include_directories(${PROJECT_BINARY_DIR}/src)
include_directories(${PROJECT_SOURCE_DIR}/src)

# OpenMP
if(ENABLE_OPENMP)
find_package(OpenMP)
if(OPENMP_FOUND)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
endif(OPENMP_FOUND)
endif(ENABLE_OPENMP)

# tests
ENABLE_TESTING()

# include directories
add_subdirectory("src")

# Copy test file depedencies
configure_file(advantage_44_4.log advantage_44_4.log COPYONLY)

# RPATH setting

set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
set(CMAKE_SKIP_BUILD_RPATH FALSE)
set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
set(CMAKE_MACOSX_RPATH 1)
