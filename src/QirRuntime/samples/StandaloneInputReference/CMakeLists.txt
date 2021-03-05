#=======================================================================================================================
# This is a reference make file on how to build a QIR-based standalone executable.
#=======================================================================================================================

add_executable(qir-input-reference-standalone
  qir-driver.cpp
)

# This is where the generated QIR file is specified.
compile_from_qir(qir-standalone-input-reference qir_standalone_input_reference_target)

target_link_libraries(qir-input-reference-standalone PUBLIC
  ${QIR_UTILITY_LIB} # created by compile_from_qir
  ${QIR_BRIDGE_UTILITY_LIB}
  ${QIR_BRIDGE_QIS_UTILITY_LIB}
  qir-rt-support
  qir-qis-support
  simulators
)

set(standalone_includes "${PROJECT_SOURCE_DIR}/externals/CLI11")

target_include_directories(qir-input-reference-standalone PUBLIC
  "${standalone_includes}"
  "${public_includes}"
  "${PROJECT_SOURCE_DIR}/lib/QIR"
)

add_dependencies(qir-input-reference-standalone qir_standalone_input_reference_target)

install(TARGETS qir-input-reference-standalone RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin")

add_test(
  NAME qir-input-reference-standalone
  COMMAND qir-input-reference-standalone --int-value 1 --double-value 0.5 --bool-value true --integer-array 1 2 3 4 5 --pauli-value PauliX --range-value 1 10 1 --string-value SampleString --result-value zero
)
