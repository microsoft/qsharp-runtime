
compile_from_qir(tracer-qir tracer_qir)

#==============================================================================
# The executable target for QIR tests triggers the custom actions to compile ll files
#
add_executable(qir-tracer-tests
  qir-tracer-driver.cpp
  tracer-config.cpp
)

target_link_libraries(qir-tracer-tests PUBLIC
  ${QIR_UTILITY_LIB} # set by compile_from_qir
  ${QIR_BRIDGE_UTILITY_LIB}
  ${QIR_BRIDGE_TRACER_UTILITY_LIB}
  tracer
  qir-rt-support
)

target_include_directories(qir-tracer-tests PUBLIC
  "${test_includes}"
  "${public_includes}"
  "${PROJECT_SOURCE_DIR}/lib/Tracer"
)
add_dependencies(qir-tracer-tests tracer_qir)

install(TARGETS qir-tracer-tests RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin")
add_unit_test(qir-tracer-tests)
