cmake_minimum_required(VERSION 3.20 FATAL_ERROR)

message(INFO "*** build config: ${CMAKE_BUILD_TYPE}")

# Load common utils and configure cmake policies
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/../../Common/cmake")
include(secure_dependencies)
set_msvc_static_runtime_policy()

# set the project name and version
project(qirruntime)

# specify the C++ standard, compiler and other tools
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

locate_win32_spectre_static_runtime()
configure_security_flags()

# feel free to customize these flags for your local builds (don't check in)
set(CMAKE_VERBOSE_MAKEFILE ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-inline")

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/../Common/cmake")

set(public_includes "${PROJECT_SOURCE_DIR}/public")
set(common_includes "${PROJECT_SOURCE_DIR}/../Common/Include")

include(qir_cmake_include)

add_subdirectory(lib)
add_subdirectory(unittests)
