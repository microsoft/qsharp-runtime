cmake_minimum_required(VERSION 3.20 FATAL_ERROR)

# Load common utils and configure cmake policies
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/../../Common/cmake")
include(secure_dependencies)
set_msvc_static_runtime_policy()

project(Microsoft.Quantum.SparseSimulator.Runtime)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_MACOSX_RPATH 1)

locate_win32_spectre_static_runtime()
configure_security_flags()

# Main build files
add_library(Microsoft.Quantum.SparseSimulator.Runtime SHARED factory.cpp capi.cpp)
target_link_libraries(Microsoft.Quantum.SparseSimulator.Runtime ${SPECTRE_LIBS})

# Windows adds a special dllexport command which must be defined
if (WIN32)
	target_compile_options(Microsoft.Quantum.SparseSimulator.Runtime PUBLIC -fdeclspec)
	target_compile_definitions(Microsoft.Quantum.SparseSimulator.Runtime PRIVATE BUILD_DLL=1)
endif()
# Try to optimize with gcc
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
	target_compile_options(Microsoft.Quantum.SparseSimulator.Runtime PUBLIC -O3 -ftree-vectorize -mavx2 -mfma)
endif()

message("Compiler flags: ${CMAKE_CXX_FLAGS_RELEASE}")


include(CTest)
enable_testing()

foreach(TEST SparseSimulatorTests CSharpIntegrationTests)
    add_executable(${TEST} ${TEST}.cpp TestHelpers.cpp)
    target_include_directories(${TEST} PRIVATE ../../Qir/Common/Externals/catch2)
    add_test(${TEST} ${TEST})
endforeach()
