cmake_minimum_required(VERSION 3.10)

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
set(test_includes   "${PROJECT_SOURCE_DIR}/externals/catch2" "${PROJECT_SOURCE_DIR}/test")

# testing related
include(CTest)
macro(add_unit_test target)
    add_test(
        NAME ${target}
        COMMAND ${target} ~[skip] -o "${target}_results.xml" -r junit
    )

    # set the environment path for loading shared libs the tests are using
    if(DEFINED ENV{NATIVE_SIMULATOR})
        set(TEST_DEPS1 $ENV{NATIVE_SIMULATOR})
    else()
        set(TEST_DEPS1 "${PROJECT_SOURCE_DIR}/../Simulation/native/build/${CMAKE_BUILD_TYPE}")
    endif()

    set(TEST_DEPS2 "${CMAKE_BINARY_DIR}/bin")
    set_property(TEST ${target} PROPERTY ENVIRONMENT
        "LD_LIBRARY_PATH=${TEST_DEPS1}:${TEST_DEPS2}:${LD_LIBRARY_PATH}"
        "PATH=${TEST_DEPS1}\;${TEST_DEPS2}\;${PATH}"
        "DYLD_LIBRARY_PATH=${TEST_DEPS1}:${TEST_DEPS2}:${DYLD_LIBRARY_PATH}"
    )
endmacro(add_unit_test)


add_subdirectory(lib)
add_subdirectory(test)

