cmake_minimum_required(VERSION 3.20 FATAL_ERROR)

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
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/../../Common/cmake")
include(cache)

set(common_includes "${PROJECT_SOURCE_DIR}/../Common/Include")
set(test_includes "${PROJECT_SOURCE_DIR}/../Common/Externals/catch2")

# set the environment path for loading shared libs the tests are using
if(DEFINED ENV{NATIVE_SIMULATOR})
    set(simulator_lib_path $ENV{NATIVE_SIMULATOR})
else()
    set(simulator_lib_path "${PROJECT_SOURCE_DIR}/../../Simulation/Native/build/drop")
endif()

include(qir_cmake_include)

add_subdirectory(StandaloneInputReference)
