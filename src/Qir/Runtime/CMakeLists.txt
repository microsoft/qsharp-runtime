cmake_minimum_required(VERSION 3.10)

message(INFO "*** build config: ${CMAKE_BUILD_TYPE}")

# set the project name and version
project(qirruntime)

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

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

set(public_includes "${PROJECT_SOURCE_DIR}/public")

include(qir_cmake_include)

if (WIN32)
  set(QIR_BRIDGE_UTILITY_LIB "${PROJECT_BINARY_DIR}/lib/QIR/bridge-rt-u.lib")
  set(QSHARP_FOUNDATION_BRIDGE_QIS_UTILITY_LIB "${PROJECT_BINARY_DIR}/lib/QSharpFoundation/qsharp-foundation-qis-u.lib")
  set(QSHARP_CORE_BRIDGE_QIS_UTILITY_LIB "${PROJECT_BINARY_DIR}/lib/QSharpCore/qsharp-core-qis-u.lib")
  set(QIR_BRIDGE_TRACER_UTILITY_LIB "${PROJECT_BINARY_DIR}/lib/Tracer/tracer-bridge-u.lib")
else()
  set(QIR_BRIDGE_UTILITY_LIB "${PROJECT_BINARY_DIR}/lib/QIR/libbridge-rt-u.a")
  set(QSHARP_FOUNDATION_BRIDGE_QIS_UTILITY_LIB "${PROJECT_BINARY_DIR}/lib/QSharpFoundation/libqsharp-foundation-qis-u.a")
  set(QSHARP_CORE_BRIDGE_QIS_UTILITY_LIB "${PROJECT_BINARY_DIR}/lib/QSharpCore/libqsharp-core-qis-u.a")
  set(QIR_BRIDGE_TRACER_UTILITY_LIB "${PROJECT_BINARY_DIR}/lib/Tracer/libtracer-bridge-u.a")
endif()

add_subdirectory(lib)
add_subdirectory(samples)
add_subdirectory(test)
