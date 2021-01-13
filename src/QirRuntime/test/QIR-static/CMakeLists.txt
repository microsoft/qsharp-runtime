# compile test ll files into a library

set(TEST_FILES
  qir-test-arrays
  qir-test-functors
  qir-test-noqsharp
  qir-test-partials
  qir-test-qubits-results
)

foreach(file ${TEST_FILES})
  compile_from_qir(${file} "") # don't create a target per file
  list(APPEND QIR_TESTS_LIBS ${QIR_UTILITY_LIB})
endforeach()

add_custom_target(qir_static_test_lib DEPENDS ${QIR_TESTS_LIBS})

#==============================================================================
# The executable target for QIR tests triggers the custom actions to compile ll files
#
add_executable(qir-static-tests
  qir-driver.cpp)

target_link_libraries(qir-static-tests PUBLIC
  ${QIR_TESTS_LIBS}
  ${QIR_BRIDGE_UTILITY_LIB}
  ${QIR_BRIDGE_QIS_UTILITY_LIB}
  qir-rt-support
  qir-qis-support
  simulators
)

target_include_directories(qir-static-tests PUBLIC
  "${test_includes}"
  "${public_includes}"
  "${PROJECT_SOURCE_DIR}/lib/QIR"
)
add_dependencies(qir-static-tests qir_static_test_lib)

install(TARGETS qir-static-tests RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin")
add_unit_test(qir-static-tests)

