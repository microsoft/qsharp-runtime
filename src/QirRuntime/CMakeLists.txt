cmake_minimum_required(VERSION 3.10)

# setthe project name and version
project(qtracer)

# specify the C++ standard, compiler and other tools
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED True)

if(LINUX)
    set(CMAKE_C_COMPILER             "/usr/bin/clang")
    set(CMAKE_CXX_COMPILER             "/usr/bin/clang++")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17 -stdlib=libc++ -lc++abi -fms-compatibility")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -ldl -fuse-ld=lld")
    set(CMAKE_AR      "/usr/bin/llvm-ar")
    set(CMAKE_LINKER  "/usr/bin/llvm-ld")
    set(CMAKE_NM      "/usr/bin/llvm-nm")
    set(CMAKE_OBJDUMP "/usr/bin/llvm-objdump")
    set(CMAKE_RANLIB  "/usr/bin/llvm-ranlib")
elseif(WIN32)
    set(CMAKE_AR      "llvm-ar.exe")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17")
endif()
set(CMAKE_CXX_CLANG_TIDY clang-tidy)

set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG")

# feel free to customize these flags for your local builds (don't check in)
set(CMAKE_VERBOSE_MAKEFILE ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-inline")
#set(GENERATE_IR true)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

include(ProduceIR)

set(public_includes "${PROJECT_SOURCE_DIR}/public")
set(test_includes   "${PROJECT_SOURCE_DIR}/externals/catch2")

add_subdirectory(experimental)
add_subdirectory(lib)
add_subdirectory(test)

