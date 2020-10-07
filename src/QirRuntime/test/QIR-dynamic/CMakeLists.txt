# compile test ll files into a library, have to use custom commands for this
set(CLANG_ARGS "-c")
if (CMAKE_BUILD_TYPE STREQUAL "Debug")
  set(CLANG_ARGS
    "${CLANG_ARGS}"
    "-O0"
    "-D_DEBUG"
  )
endif()

if (WIN32)
  set(TEST_FILES
    qir-test-vqe-simple-win
  )
else()
  set(TEST_FILES
    qir-test-vqe-simple-lnx
  )
endif()


foreach(file ${TEST_FILES})
  set(INFILE "${CMAKE_CURRENT_SOURCE_DIR}/${file}.ll")
  set(OBJFILE "${CMAKE_CURRENT_BINARY_DIR}/${file}.obj")

  set(QIR_SINGLE_FILE_COMPILE_ACTION "qir_single_file_compile_action_${file}")
  add_custom_command(OUTPUT ${QIR_SINGLE_FILE_COMPILE_ACTION}
    COMMAND ${CMAKE_CXX_COMPILER}
    ARGS ${CLANG_ARGS} ${INFILE} "-o" ${OBJFILE}
    DEPENDS ${INFILE}
    COMMENT "Compiling qir test file ${file}"
    VERBATIM)

  set(QIR_SINGLE_FILE_COMPILE "qir_single_file_compile_${file}")
  add_custom_target(${QIR_SINGLE_FILE_COMPILE} DEPENDS ${QIR_SINGLE_FILE_COMPILE_ACTION})

  if (WIN32)
    set(QIR_TESTS_LIB "${CMAKE_CURRENT_BINARY_DIR}/${file}.lib")
  else()
    set(QIR_TESTS_LIB "${CMAKE_CURRENT_BINARY_DIR}/libqir_${file}.a")
  endif()
  list(APPEND QIR_TESTS_LIBS ${QIR_TESTS_LIB})

  add_custom_command(OUTPUT ${QIR_TESTS_LIB}
    COMMAND ${CMAKE_AR}
    ARGS "rc" ${QIR_TESTS_LIB} ${OBJFILE}
    DEPENDS ${QIR_SINGLE_FILE_COMPILE} ${INFILE}
    COMMENT "Adding QIR tests ${file} into a lib"
    VERBATIM)

endforeach()

add_custom_target(qir_dynamic_test_lib DEPENDS ${QIR_TESTS_LIBS})

#==============================================================================
# This executable target links test code against the dynamic QDK library rather than the explicit
# static QIR/RT libs (qdk will statically link in the bridge via transitivity of target_link_libraries).
#
add_executable(qir-dynamic-tests
  qir-driver.cpp
)

target_link_libraries(qir-dynamic-tests PUBLIC
  ${QIR_TESTS_LIBS}
  qdk
)

target_include_directories(qir-dynamic-tests PUBLIC
  ${test_includes}
  ${public_includes}
)
add_dependencies(qir-dynamic-tests qir_dynamic_test_lib)

install(TARGETS qir-dynamic-tests RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin")
