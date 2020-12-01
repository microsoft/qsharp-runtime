# compile test ll files into a library, have to use custom commands for this
set(CLANG_ARGS "-c")
if (CMAKE_BUILD_TYPE STREQUAL "Debug")
  set(CLANG_ARGS
    "${CLANG_ARGS}"
    "-O0"
    "-D_DEBUG"
  )
endif()

set(TEST_FILES
  qir-test-trace
)

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
    set(QIR_TESTS_LIB  "${CMAKE_CURRENT_BINARY_DIR}/${file}.lib")
  else()
    set(QIR_TESTS_LIB  "${CMAKE_CURRENT_BINARY_DIR}/libqir_${file}.a")
  endif()
  list(APPEND QIR_TESTS_LIBS ${QIR_TESTS_LIB})

  add_custom_command(OUTPUT ${QIR_TESTS_LIB}
    COMMAND ${CMAKE_AR}
    ARGS "rc" ${QIR_TESTS_LIB} ${OBJFILE}
    DEPENDS ${QIR_SINGLE_FILE_COMPILE} ${INFILE}
    COMMENT "Adding QIR tests ${file} into a lib"
    VERBATIM)

endforeach()

add_custom_target(qir_tracer_test_lib DEPENDS ${QIR_TESTS_LIBS})

#==============================================================================
# The executable target for QIR tests triggers the custom actions to compile ll files
#
add_executable(qir-tracer-tests
  qir-tracer-driver.cpp)

if (WIN32)
  set(QIR_BRIDGE_UTILITY_LIB "${PROJECT_BINARY_DIR}/lib/QIR/qir-bridge-u.lib")
#  set(QIR_BRIDGE_QIS_UTILITY_LIB "${PROJECT_BINARY_DIR}/lib/QIR/qir-bridge-qis-u.lib")
else()
  set(QIR_BRIDGE_UTILITY_LIB "${PROJECT_BINARY_DIR}/lib/QIR/libqir-bridge-u.a")
#  set(QIR_BRIDGE_QIS_UTILITY_LIB "${PROJECT_BINARY_DIR}/lib/QIR/libqir-bridge-qis-u.a")
endif()

target_link_libraries(qir-tracer-tests PUBLIC
  ${QIR_TESTS_LIBS}
  ${QIR_BRIDGE_UTILITY_LIB}
  tracer
)

target_include_directories(qir-tracer-tests PUBLIC
  "${test_includes}"
  "${public_includes}"
  "${PROJECT_SOURCE_DIR}/lib/QIR"
)
add_dependencies(qir-tracer-tests qir_tracer_test_lib)

install(TARGETS qir-tracer-tests RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin")
add_unit_test(qir-tracer-tests)

