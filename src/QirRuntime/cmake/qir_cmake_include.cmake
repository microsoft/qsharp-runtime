#===============================================================================
# compiling from IR
#
# CMake doesn't support LLVM IR files as sources so we compile them with custom
# commands, which produce UTILITY libs that can only be linked in using abs paths
# (rather than the target name):
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

macro(target_source_from_qir_obj target_name source_file)
    SET_SOURCE_FILES_PROPERTIES(
        "${source_file}.obj"
        PROPERTIES
        EXTERNAL_OBJECT true
        GENERATED true
    )
    target_sources(${target_name} PUBLIC 
        "${CMAKE_CURRENT_BINARY_DIR}/${source_file}.obj"
    )
endmacro()