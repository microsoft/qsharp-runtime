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
set(test_includes   "${PROJECT_SOURCE_DIR}/externals/catch2" "${PROJECT_SOURCE_DIR}/test")

#===============================================================================
# testing related
#
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

#===============================================================================
# compiling from IR
#
# CMake doesn't support IR files as sources so we compile them with custom commands,
# which produce UTILITY libs that can only be linked in using abs paths (rather
# than the target name):
#   Target "qir_bridge_qis" of type UTILITY may not be linked into another
#   target.  One may link only to INTERFACE, OBJECT, STATIC or SHARED
#   libraries, or to executables with the ENABLE_EXPORTS property set.
#
macro(compile_from_qir source_file target)
    set(CLANG_ARGS "-c")
    if (CMAKE_BUILD_TYPE STREQUAL "Debug")
        set(CLANG_ARGS
        "${CLANG_ARGS}"
        "-O0"
        "-D_DEBUG"
        )
    endif()

    set(INFILE
        "${CMAKE_CURRENT_SOURCE_DIR}/${source_file}.ll"
    )
    set(OBJFILE
        "${CMAKE_CURRENT_BINARY_DIR}/${source_file}.obj"
    )

    set(OBJFILE_COMPILE "${source_file}-compile")
    add_custom_command(OUTPUT ${OBJFILE_COMPILE}
        COMMAND ${CMAKE_CXX_COMPILER}
        ARGS ${CLANG_ARGS} ${INFILE} "-o" ${OBJFILE}
        DEPENDS ${INFILE}
        COMMENT "Compiling ${source_file}.ll"
        VERBATIM
    )

    add_custom_target(${source_file}_compile DEPENDS ${OBJFILE_COMPILE})

    if (WIN32)
        set(QIR_UTILITY_LIB "${CMAKE_CURRENT_BINARY_DIR}/${source_file}-u.lib" )
    else()
        set(QIR_UTILITY_LIB "${CMAKE_CURRENT_BINARY_DIR}/lib${source_file}-u.a")
    endif()

    add_custom_command(OUTPUT ${QIR_UTILITY_LIB}
        COMMAND ${CMAKE_AR}
        ARGS "rc" ${QIR_UTILITY_LIB} ${OBJFILE}
        DEPENDS ${source_file}_compile ${INFILE}
        COMMENT "Creating a lib from ${source_file}.ll"
        VERBATIM
    )

    if (NOT ${target} STREQUAL "")
      add_custom_target(${target} DEPENDS ${QIR_UTILITY_LIB})
    endif()
endmacro(compile_from_qir)

if (WIN32)
  set(QIR_BRIDGE_UTILITY_LIB "${PROJECT_BINARY_DIR}/lib/QIR/bridge-rt-u.lib")
  set(QIR_BRIDGE_QIS_UTILITY_LIB "${PROJECT_BINARY_DIR}/lib/QIR/bridge-qis-u.lib")
else()
  set(QIR_BRIDGE_UTILITY_LIB "${PROJECT_BINARY_DIR}/lib/QIR/libbridge-rt-u.a")
  set(QIR_BRIDGE_QIS_UTILITY_LIB "${PROJECT_BINARY_DIR}/lib/QIR/libbridge-qis-u.a")
endif()


add_subdirectory(lib)
add_subdirectory(test)

