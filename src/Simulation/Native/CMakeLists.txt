# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

cmake_minimum_required(VERSION 3.20 FATAL_ERROR)

message(INFO "*** build config: ${CMAKE_BUILD_TYPE}")

# Load common utils and configure cmake policies
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/../../Common/cmake")
include(secure_dependencies)
set_msvc_static_runtime_policy()

project(quantum-simulator)

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

locate_win32_spectre_static_runtime()
configure_security_flags()

include_directories(${PROJECT_BINARY_DIR}/src)
include_directories(${PROJECT_SOURCE_DIR}/src)

# OpenMP
if(ENABLE_OPENMP)

if (APPLE)
    set(OPENMP_LOCAL_PATH       "${PROJECT_SOURCE_DIR}/osx")
    # Note we use `-rpath @loader_path` to ensure the produced binary includes the folder of the binary
    # itself in the runtime search path for dynamic library load, regardless of environment settings.
    # We don't use `@executable_path` because that takes into account recursive dependencies and will be
    # the folder of the originally launched binary (root of the dependency tree) instead of loading binary
    # (the immediate parent in the dependency tree), which will be the simulatory library itself.
    # See https://www.man7.org/linux/man-pages/man1/ld.1.html and https://stackoverflow.com/questions/52981210/linking-with-dylib-library-from-the-command-line-using-clang
    set(OPENMP_COMPILER_FLAGS   "-Xpreprocessor -fopenmp -I${OPENMP_LOCAL_PATH}/include -L${OPENMP_LOCAL_PATH} -lomp -rpath @loader_path")
    set(OPENMP_LIB_NAME         "omp")

    set(OpenMP_CXX_FLAGS        "${OPENMP_COMPILER_FLAGS}")
    set(OpenMP_C_FLAGS          "${OPENMP_COMPILER_FLAGS}")
    set(OpenMP_CXX_LIB_NAMES    "${OPENMP_LIB_NAME}")
    set(OpenMP_C_LIB_NAMES      "${OPENMP_LIB_NAME}")
    set(OpenMP_omp_LIBRARY      "${OPENMP_LOCAL_PATH}/libomp.dylib")
endif()

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
