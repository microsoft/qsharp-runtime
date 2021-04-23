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
    if (WIN32)
        set(CLANG_ARGS "${CLANG_ARGS}" "-Xclang" "-cfguard")
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
