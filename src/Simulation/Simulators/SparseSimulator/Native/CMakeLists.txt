cmake_minimum_required(VERSION 3.10)
project(SparseQuantumSimulator)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_MACOSX_RPATH 1)
# Main build files
add_library(SparseQuantumSimulator SHARED factory.cpp capi.cpp)

# Windows adds a special dllexport command which must be defined
if (WIN32)
	target_compile_options(SparseQuantumSimulator PUBLIC -fdeclspec)
	target_compile_definitions(SparseQuantumSimulator PRIVATE BUILD_DLL=1)
endif()
# Try to optimize with gcc
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
	target_compile_options(SparseQuantumSimulator PUBLIC -O3 -ftree-vectorize -mavx2 -mfma)
endif()

message("Compiler flags: ${CMAKE_CXX_FLAGS_RELEASE}")

include(CTest)
enable_testing()

foreach(TEST SparseSimulatorTests CSharpIntegrationTests)
    add_executable(${TEST} ${TEST}.cpp TestHelpers.cpp)
    target_include_directories(${TEST} PRIVATE ../../../../Qir/Common/Externals/catch2)
    add_test(${TEST} ${TEST})
endforeach()