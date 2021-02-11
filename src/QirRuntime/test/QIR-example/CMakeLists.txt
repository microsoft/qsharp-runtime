# compile test ll files into a library

set(TEST_FILES
  qir-example-vqe
)

foreach(file ${TEST_FILES})
  compile_from_qir(${file} "") # don't create a target per file
  list(APPEND QIR_TESTS_LIBS ${QIR_UTILITY_LIB})
endforeach()

add_custom_target(qir_example_lib DEPENDS ${QIR_TESTS_LIBS})

#==============================================================================
# The executable target for QIR tests triggers the custom actions to compile ll files
#
add_executable(qir-example
  qir-driver.cpp)

target_link_libraries(qir-example PUBLIC
  ${QIR_TESTS_LIBS}
  ${QIR_BRIDGE_UTILITY_LIB}
  ${QIR_BRIDGE_QIS_UTILITY_LIB}
  qir-rt-support
  qir-qis-support
  simulators
)

target_include_directories(qir-example PUBLIC
  "${test_includes}"
  "${public_includes}"
  "${PROJECT_SOURCE_DIR}/lib/QIR"
)
add_dependencies(qir-example qir_example_lib)

install(TARGETS qir-example RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin")
add_unit_test(qir-example)

