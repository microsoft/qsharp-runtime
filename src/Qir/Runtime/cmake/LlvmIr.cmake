function (microsoft_add_ir_library)
  set(prefix "IR")

  set(flags "")
  set(singleValues TARGET OUTPUT)
  set(multiValues SOURCES INCLUDES)

  include(CMakeParseArguments)
  cmake_parse_arguments(${prefix}
                   "${flags}"
                   "${singleValues}"
                   "${multiValues}"
                    ${ARGN})

  list(LENGTH IR_UNPARSED_ARGUMENTS SIZE)
  list(GET IR_UNPARSED_ARGUMENTS 0 IR_TARGET)
  if(SIZE GREATER 1)
    list(GET IR_UNPARSED_ARGUMENTS 1 IR_OUTPUT)
  endif()


  set(include_flags "")
  foreach(flag IN ITEMS  ${IR_INCLUDES})
    set(include_flags "${include_flags}"  "-I${flag}")
  endforeach()

  set(output_files "")
  foreach(source IN ITEMS ${IR_SOURCES})
    set(outputfile "${CMAKE_CURRENT_BINARY_DIR}/${source}.ll" )
    set(inputfile "${CMAKE_CURRENT_SOURCE_DIR}/${source}" )

    add_custom_command(OUTPUT ${outputfile}
        COMMAND clang++ # TODO: Use CMAKE_CXX_COMPILER
        ARGS ${include_flags} ${CMAKE_CXX_FLAGS} "-S" "-emit-llvm" "-fPIC" "-o" ${outputfile} ${inputfile}
      )

    set(output_files ${output_files} ${outputfile} )    
  endforeach()

  add_custom_target(${IR_TARGET}
                DEPENDS ${output_files})

  SET(${IR_OUTPUT}  "${output_files}" CACHE INTERNAL ${IR_OUTPUT})
endfunction ()


function (microsoft_link_ir)
  set(prefix "LINK")

  set(flags "")
  set(singleValues TARGET OUTPUT)
  set(multiValues DEPENDS SOURCES)
  cmake_parse_arguments(${prefix}
                   "${flags}"
                   "${singleValues}"
                   "${multiValues}"
                  ${ARGN})

  add_custom_command(OUTPUT ${LINK_OUTPUT}
                     COMMAND llvm-link 
                     ARGS "-S" "-o" ${LINK_OUTPUT} ${LINK_SOURCES}
                     DEPENDS ${LINK_DEPENDS}
                     COMMAND_EXPAND_LISTS)

  add_custom_target(${LINK_TARGET}
                    DEPENDS ${LINK_OUTPUT})

endfunction()