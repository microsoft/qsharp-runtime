#===============================================================================
# compiling from IR
macro(target_source_from_qir target_name source_file)
    set(CLANG_ARGS "-c")
    if (CMAKE_BUILD_TYPE STREQUAL "Debug")
        set(CLANG_ARGS
        "${CLANG_ARGS}"
        "-O0"
        "-DDEBUG"
        )
    endif()

    get_filename_component(file_name ${source_file} NAME_WLE)

    set(INFILE
        "${CMAKE_CURRENT_SOURCE_DIR}/${source_file}"
    )
    set(OBJFILE
        "${CMAKE_CURRENT_BINARY_DIR}/${file_name}.obj"
    )

    set(OBJFILE_COMPILE "${file_name}-compile")
    add_custom_command(OUTPUT ${OBJFILE_COMPILE}
        COMMAND ${CMAKE_CXX_COMPILER}
        ARGS ${CLANG_ARGS} ${INFILE} "-o" ${OBJFILE}
        DEPENDS ${INFILE}
        BYPRODUCTS ${OBJFILE}
        COMMENT "Compiling ${source_file}"
        VERBATIM
    )
    add_custom_target(${target_name}_${file_name}_compile DEPENDS ${OBJFILE_COMPILE})

    set_source_files_properties(
        ${OBJFILE}
        PROPERTIES
        EXTERNAL_OBJECT true
    )
    target_sources(${target_name} PUBLIC 
        ${OBJFILE}
    )
endmacro()


#===============================================================================
# Common flags

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
