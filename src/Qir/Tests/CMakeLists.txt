cmake_minimum_required(VERSION 3.10)

message(INFO "*** build config: ${CMAKE_BUILD_TYPE}")

# set the project name and version
project(qir-tests)

# specify the C++ standard, compiler and other tools
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED True)

set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG")

if(WIN32)
    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_DLL -D_MT -Xclang --dependent-lib=msvcrtd")
    else()
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_DLL -D_MT -Xclang --dependent-lib=msvcrt")
    endif()
endif()

# feel free to customize these flags for your local builds (don't check in)
set(CMAKE_VERBOSE_MAKEFILE ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-inline")

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/../Common/cmake")

set(public_includes "${PROJECT_SOURCE_DIR}/../Runtime/public")
set(common_includes "${PROJECT_SOURCE_DIR}/../Common/Include")
set(test_includes "${PROJECT_SOURCE_DIR}/../Common/externals/catch2")

set(runtime_lib_path "${PROJECT_SOURCE_DIR}/../Runtime/build/${CMAKE_BUILD_TYPE}/bin")

include(qir_cmake_include)
include(unit_test_include)

add_subdirectory(FullstateSimulator)
add_subdirectory(QIR-dynamic)
add_subdirectory(QIR-static)
add_subdirectory(QIR-tracer)
add_subdirectory(Type1Simulator)
