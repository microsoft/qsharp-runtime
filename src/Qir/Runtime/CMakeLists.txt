cmake_minimum_required(VERSION 3.20 FATAL_ERROR)

message(INFO "*** build config: ${CMAKE_BUILD_TYPE}")

# set the project name and version
project(qirruntime)

# specify the C++ standard, compiler and other tools
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG")
set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -DDEBUG")

if (NOT WIN32)
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -fsanitize=undefined -fsanitize=float-divide-by-zero -fsanitize=unsigned-integer-overflow -fsanitize=implicit-conversion -fsanitize=local-bounds -fsanitize=nullability")
    set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -fsanitize=undefined -fsanitize=float-divide-by-zero -fsanitize=unsigned-integer-overflow -fsanitize=implicit-conversion -fsanitize=local-bounds -fsanitize=nullability")

    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -fsanitize=address")
    set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -fsanitize=address")

    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -fno-omit-frame-pointer")
    set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -fno-omit-frame-pointer")

    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -fno-optimize-sibling-calls")
    set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -fno-optimize-sibling-calls")
endif()

# Treat warnings as errors:
# https://clang.llvm.org/docs/UsersManual.html#options-to-control-error-and-warning-messages
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Werror")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Werror")


# https://clang.llvm.org/docs/UsersManual.html#enabling-all-diagnostics
# https://clang.llvm.org/docs/DiagnosticsReference.html
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Weverything")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Weverything")

# Disable these warnings:

# https://clang.llvm.org/docs/DiagnosticsReference.html#wc-98-compat-pedantic
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-c++98-compat-pedantic")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-c++98-compat-pedantic")

# Old-style casts increase readability as opposed to `reinterpret_cast<..>()`. We want to be able to use the old-style casts.
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-old-style-cast")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-old-style-cast")

# Even if the `switch` covers all the enumerators, it is still good to have `default` label to cover the potential newly added (but not handled) enumerators.
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-covered-switch-default")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-covered-switch-default")

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-c99-extensions")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-c99-extensions")

# We are OK that the structs are padded to align the fields.
# https://clang.llvm.org/docs/DiagnosticsReference.html#wpadded
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-padded")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-padded")

# We are OK with abstract classes.
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-weak-vtables")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-weak-vtables")

# Temporarily disable the following warnings (until QIR RT is refactored to expose C interface).

# https://clang.llvm.org/docs/DiagnosticsReference.html#wglobal-constructors
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-global-constructors")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-global-constructors")

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-exit-time-destructors")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-exit-time-destructors")

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-extra-semi-stmt")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-extra-semi-stmt")


# Always use available Spectre mitigations where available
if (NOT APPLE)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mspeculative-load-hardening -mretpoline")
endif()

if (WIN32)
    # Enforce use of static runtime (avoids target machine needing msvcrt installed).
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")

    # Locate the vswhere application, which will provide paths to any installed Visual Studio instances.
    # By invoking it with "-find **/lib/spectre/x64" we will find any Spectre mitigated libaries that
    # have been installed.
    find_program(_vswhere_tool
        NAMES vswhere
        PATHS "$ENV{ProgramFiles\(x86\)}/Microsoft Visual Studio/Installer")
    if (NOT ${vswhere})
        message(FATAL_ERROR "Could not locate vswhere.exe - unable to source vc redistributable")
    endif()
    execute_process(
        COMMAND "${_vswhere_tool}" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -find **/14.29.*/**/lib/spectre/x64 -sort
        OUTPUT_VARIABLE _vs_install_loc_out
        RESULT_VARIABLE _vs_where_exitcode
        OUTPUT_STRIP_TRAILING_WHITESPACE)
    file(TO_CMAKE_PATH "${_vs_install_loc_out}" SPECTRE_LIB_PATH_OUT)
    string(REGEX REPLACE "[\r\n]+" ";" SPECTRE_LIB_PATH ${SPECTRE_LIB_PATH_OUT})
    message(INFO "*** install loc: ${SPECTRE_LIB_PATH}")

    # Locate the spectre mitigated runtime libraries and fail if they can't be found. Targets in this
    # cmake project can use the variables to explicitly link these libraries rather than using the 
    # non-mitigated libraries that are found by default.
    find_library(LIBCMT_SPECTRE_REL libcmt PATHS ${SPECTRE_LIB_PATH} REQUIRED)
    find_library(LIBCMT_SPECTRE_DEB libcmtd PATHS ${SPECTRE_LIB_PATH} REQUIRED)
    set(LIBCMT_SPECTRE debug ${LIBCMT_SPECTRE_DEB} optimized ${LIBCMT_SPECTRE_REL})
    message(INFO "*** using spectre lib: ${LIBCMT_SPECTRE}")
    find_library(LIBCPMT_SPECTRE_REL libcpmt PATHS ${SPECTRE_LIB_PATH} REQUIRED)
    find_library(LIBCPMT_SPECTRE_DEB libcpmtd PATHS ${SPECTRE_LIB_PATH} REQUIRED)
    set(LIBCPMT_SPECTRE debug ${LIBCPMT_SPECTRE_DEB} optimized ${LIBCPMT_SPECTRE_REL})
    message(INFO "*** using spectre lib: ${LIBCPMT_SPECTRE}")
    find_library(LIBVCRUNTIME_SPECTRE_REL libvcruntime PATHS ${SPECTRE_LIB_PATH} REQUIRED)
    find_library(LIBVCRUNTIME_SPECTRE_DEB libvcruntimed PATHS ${SPECTRE_LIB_PATH} REQUIRED)
    set(LIBVCRUNTIME_SPECTRE debug ${LIBVCRUNTIME_SPECTRE_DEB} optimized ${LIBVCRUNTIME_SPECTRE_REL})
    message(INFO "*** using spectre lib: ${LIBVCRUNTIME_SPECTRE}")
    set(SPECTRE_LIBS
        ${LIBCMT_SPECTRE}
        ${LIBCPMT_SPECTRE}
        ${LIBVCRUNTIME_SPECTRE})

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
