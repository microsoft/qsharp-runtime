cmake_minimum_required(VERSION 3.10)

message(INFO "*** build config: ${CMAKE_BUILD_TYPE}")

# set the project name and version
project(qir-samples)

# specify the C++ standard, compiler and other tools
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG")

# feel free to customize these flags for your local builds (don't check in)
set(CMAKE_VERBOSE_MAKEFILE ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-inline")

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/../Common/cmake")

set(public_includes "${PROJECT_SOURCE_DIR}/../Runtime/public")
set(common_includes "${PROJECT_SOURCE_DIR}/../Common/Include")
set(test_includes "${PROJECT_SOURCE_DIR}/../Common/externals/catch2")

set(runtime_lib_path "${PROJECT_SOURCE_DIR}/../Runtime/build/$ENV{BUILD_CONFIGURATION}/bin")

include(qir_cmake_include)

add_subdirectory(StandaloneInputReference)
