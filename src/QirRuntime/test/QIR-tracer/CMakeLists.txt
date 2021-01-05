set(TEST_FILES
  qir-test-intrinsics
)

foreach(file ${TEST_FILES})
  compile_from_qir(${file} "") # don't create a target per file
  list(APPEND QIR_TESTS_LIBS ${QIR_UTILITY_LIB})
endforeach()

add_custom_target(qir_tracer_test_lib DEPENDS ${QIR_TESTS_LIBS})

#==============================================================================
# The executable target for QIR tests triggers the custom actions to compile ll files
#
add_executable(qir-tracer-tests
  qir-tracer-driver.cpp)

target_link_libraries(qir-tracer-tests PUBLIC
  ${QIR_TESTS_LIBS}
  ${QIR_BRIDGE_UTILITY_LIB}
  tracer
  qir-rt-support
)

target_include_directories(qir-tracer-tests PUBLIC
  "${test_includes}"
  "${public_includes}"
  "${PROJECT_SOURCE_DIR}/lib/Tracer"
)
add_dependencies(qir-tracer-tests qir_tracer_test_lib)

install(TARGETS qir-tracer-tests RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin")
add_unit_test(qir-tracer-tests)
