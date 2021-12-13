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
option(BUILD_TESTS "Build simulator test applications" ON)

# Always use Spectre mitigations where available
if (WIN32)
    # Enforce use of static runtime (avoids target machine needing msvcrt installed).
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")

    # Locate the vswhere application, which will provide paths to any installed Visual Studio instances.
    # By invoking it with "-find **/lib/spectre/x64" we will find any Spectre mitigated libaries that
    # have been installed.
    find_program(_vswhere_tool
        NAMES vswhere
        PATHS "$ENV{ProgramFiles\(x86\)}/Microsoft Visual Studio/Installer")
    if (NOT ${vswhere})
        message(FATAL_ERROR "Could not locate vswhere.exe - unable to source vc redistributable")
    endif()
    execute_process(
        COMMAND "${_vswhere_tool}" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -find **/14.29.*/**/lib/spectre/x64 -sort
        OUTPUT_VARIABLE _vs_install_loc_out
        RESULT_VARIABLE _vs_where_exitcode
        OUTPUT_STRIP_TRAILING_WHITESPACE)
    file(TO_CMAKE_PATH "${_vs_install_loc_out}" SPECTRE_LIB_PATH_OUT)
    string(REGEX REPLACE "[\r\n]+" ";" SPECTRE_LIB_PATH ${SPECTRE_LIB_PATH_OUT})
    message(INFO "*** install loc: ${SPECTRE_LIB_PATH}")

    # Locate the spectre mitigated runtime libraries and fail if they can't be found. Targets in this
    # cmake project can use the variables to explicitly link these libraries rather than using the 
    # non-mitigated libraries that are found by default.
    find_library(LIBCMT_SPECTRE_REL libcmt PATHS ${SPECTRE_LIB_PATH} REQUIRED)
    find_library(LIBCMT_SPECTRE_DEB libcmtd PATHS ${SPECTRE_LIB_PATH} REQUIRED)
    set(LIBCMT_SPECTRE debug ${LIBCMT_SPECTRE_DEB} optimized ${LIBCMT_SPECTRE_REL})
    message(INFO "*** using spectre lib: ${LIBCMT_SPECTRE}")
    find_library(LIBCPMT_SPECTRE_REL libcpmt PATHS ${SPECTRE_LIB_PATH} REQUIRED)
    find_library(LIBCPMT_SPECTRE_DEB libcpmtd PATHS ${SPECTRE_LIB_PATH} REQUIRED)
    set(LIBCPMT_SPECTRE debug ${LIBCPMT_SPECTRE_DEB} optimized ${LIBCPMT_SPECTRE_REL})
    message(INFO "*** using spectre lib: ${LIBCPMT_SPECTRE}")
    find_library(LIBVCRUNTIME_SPECTRE_REL libvcruntime PATHS ${SPECTRE_LIB_PATH} REQUIRED)
    find_library(LIBVCRUNTIME_SPECTRE_DEB libvcruntimed PATHS ${SPECTRE_LIB_PATH} REQUIRED)
    set(LIBVCRUNTIME_SPECTRE debug ${LIBVCRUNTIME_SPECTRE_DEB} optimized ${LIBVCRUNTIME_SPECTRE_REL})
    message(INFO "*** using spectre lib: ${LIBVCRUNTIME_SPECTRE}")
    set(SPECTRE_LIBS
        ${LIBCMT_SPECTRE}
        ${LIBCPMT_SPECTRE}
        ${LIBVCRUNTIME_SPECTRE})

    add_link_options("LINKER:/guard:cf")
endif()

if (NOT APPLE)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mspeculative-load-hardening -mretpoline")
    set(CMAKE_C_FLAGS     "${CMAKE_C_FLAGS} -mspeculative-load-hardening -mretpoline")
endif()

include_directories(${PROJECT_BINARY_DIR}/src)
include_directories(${PROJECT_SOURCE_DIR}/src)

# OpenMP
if(ENABLE_OPENMP)

if (APPLE)
    set(OPENMP_PATH             "/usr/local/opt/libomp")
    set(OPENMP_COMPILER_FLAGS   "-Xpreprocessor -fopenmp -I${OPENMP_PATH}/include -lomp -L${OPENMP_PATH}/lib")
    set(OPENMP_LIB_NAME         "omp")

    set(OpenMP_CXX_FLAGS        "${OPENMP_COMPILER_FLAGS}")
    set(OpenMP_C_FLAGS          "${OPENMP_COMPILER_FLAGS}")
    set(OpenMP_CXX_LIB_NAMES    "${OPENMP_LIB_NAME}")
    set(OpenMP_C_LIB_NAMES      "${OPENMP_LIB_NAME}")
    set(OpenMP_omp_LIBRARY      "${OPENMP_PATH}/lib/libomp.dylib")
endif()

find_package(OpenMP)
if(OPENMP_FOUND)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
endif(OPENMP_FOUND)
endif(ENABLE_OPENMP)

# tests
if(BUILD_TESTS)
ENABLE_TESTING()
endif(BUILD_TESTS)

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
