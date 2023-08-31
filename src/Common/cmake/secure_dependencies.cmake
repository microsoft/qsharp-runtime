# ===============================================================================
# Configure the flags used to ensure that required security settings are enabled
macro(configure_security_flags)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fstack-protector")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fstack-protector")

    # Enable Control Flow Guard
    if(WIN32)
        add_link_options("LINKER:/guard:cf")
    endif()

    # Enable Compiler supported Spectre mitigations
    if(NOT APPLE)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mspeculative-load-hardening -mretpoline")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mspeculative-load-hardening -mretpoline")
    endif()
endmacro()

# ===============================================================================
# Set MSVC static runtime library policy
# NOTE: Since this sets a cmake policy for ensuring Windows compilation uses static runtime,
# this policy MUST be set before any projects are declared for it to take effect.
macro(set_msvc_static_runtime_policy)
    # Enforce use of static runtime (avoids target machine needing msvcrt installed).
    # Must set policy CMP0091 before any projects are declared (see https://cmake.org/cmake/help/latest/variable/CMAKE_MSVC_RUNTIME_LIBRARY.html#cmake-msvc-runtime-library)
    cmake_policy(SET CMP0091 NEW)
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
endmacro()

# ===============================================================================
# Locate Spectre mitigated static C runtime on Windows. Sets the `SPECTRE_LIBS`
# variable for use in later calls to `target_link_libraries`.
# NOTE: This sets a cmake policy for ensuring Windows compilation uses static runtime.
# this policy MUST be set before any projects are declared for it to take effect.
macro(locate_win32_spectre_static_runtime)
    if(WIN32)
        # Locate the vswhere application, which will provide paths to any installed Visual Studio instances.
        # By invoking it with "-find **/lib/spectre/x64" we will find any Spectre mitigated libaries that
        # have been installed.
        find_program(_vswhere_tool
            NAMES vswhere
            PATHS "$ENV{ProgramFiles\(x86\)}/Microsoft Visual Studio/Installer")
        message(INFO "*** _vswhere_tool: ${_vswhere_tool}")

        if(NOT ${vswhere})
            message(FATAL_ERROR "Could not locate vswhere - unable to search for installed vcruntime libraries.")
        endif()

        execute_process(
            COMMAND "${_vswhere_tool}" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -find **/14.*.*/**/lib/spectre/x64 -sort
            OUTPUT_VARIABLE _vs_install_loc_out
            RESULT_VARIABLE _vs_where_exitcode
            OUTPUT_STRIP_TRAILING_WHITESPACE)
        message(INFO "*** _vs_install_loc_out: ${_vs_install_loc_out}")

        file(TO_CMAKE_PATH "${_vs_install_loc_out}" SPECTRE_LIB_PATH_OUT)
        message(INFO "*** SPECTRE_LIB_PATH_OUT: ${SPECTRE_LIB_PATH_OUT}")

        string(REGEX REPLACE "[\r\n]+" ";" SPECTRE_LIB_PATH ${SPECTRE_LIB_PATH_OUT})
        list(REVERSE SPECTRE_LIB_PATH)
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
    endif(WIN32)
endmacro()
