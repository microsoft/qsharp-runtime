set(TEST_FILES
  tracer-qir
)

foreach(file ${TEST_FILES})
  compile_from_qir(${file} "") # don't create a target per file
  list(APPEND QIR_TESTS_LIBS ${QIR_UTILITY_LIB})
endforeach()

add_custom_target(tracer_qir_test_lib DEPENDS ${QIR_TESTS_LIBS})

#==============================================================================
# The executable target for QIR tests triggers the custom actions to compile ll files
#
add_executable(qir-tracer-tests
  qir-tracer-driver.cpp
  tracer-config.cpp
)

target_link_libraries(qir-tracer-tests PUBLIC
  ${QIR_TESTS_LIBS}
  "-L${CMAKE_BINARY_DIR}/lib/QIR"
  -lMicrosoft.Quantum.Qir.Runtime
  "-L${CMAKE_BINARY_DIR}/lib/Tracer"
  -lMicrosoft.Quantum.Qir.Tracer
)

target_include_directories(qir-tracer-tests PUBLIC
  "${test_includes}"
  "${public_includes}"
  "${PROJECT_SOURCE_DIR}/lib/Tracer" # TODO: Remove this when tracer api is put into public headers.
)
add_dependencies(qir-tracer-tests tracer_qir_test_lib)

install(TARGETS qir-tracer-tests RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin")
add_unit_test(qir-tracer-tests)
