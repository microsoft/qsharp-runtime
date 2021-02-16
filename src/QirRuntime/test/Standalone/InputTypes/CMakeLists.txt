# compile test ll files into a library

set(INPUT_TYPES_FILES
#  qir-test-arrays
#  qir-test-functors
#  qir-test-noqsharp
#  qir-test-qsharp
#  qir-test-partials
#  qir-test-qubits-results
  qir-input-types
)

foreach(file ${INPUT_TYPES_FILES})
  compile_from_qir(${file} "") # don't create a target per file
  list(APPEND QIR_INPUT_TYPES_LIBS ${QIR_UTILITY_LIB})
endforeach()

add_custom_target(qir_input_types_lib DEPENDS ${QIR_INPUT_TYPES_LIBS})

#==============================================================================
# The executable target for QIR tests triggers the custom actions to compile ll files
#
add_executable(qir-input-types
  qir-driver.cpp)

target_link_libraries(qir-input-types PUBLIC
  ${QIR_INPUT_TYPES_LIBS}
  ${QIR_BRIDGE_UTILITY_LIB}
  ${QIR_BRIDGE_QIS_UTILITY_LIB}
  qir-rt-support
  qir-qis-support
  simulators
)

target_include_directories(qir-input-types PUBLIC
  "${test_includes}"
  "${public_includes}"
  "${PROJECT_SOURCE_DIR}/lib/QIR"
)
add_dependencies(qir-input-types qir_input_types_lib)

install(TARGETS qir-input-types RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin")
