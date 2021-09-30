cmake_minimum_required(VERSION 3.20 FATAL_ERROR)

message(INFO "*** build config: ${CMAKE_BUILD_TYPE}")

# set the project name and version
project(qirruntime)

# specify the C++ standard, compiler and other tools
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG")

include(${CMAKE_SOURCE_DIR}/cmake/LlvmIr.cmake)

# Always use available Spectre mitigations where available
if (NOT APPLE)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mspeculative-load-hardening -mretpoline")
endif()

if (WIN32)
    add_link_options("LINKER:/guard:cf")
endif()

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

