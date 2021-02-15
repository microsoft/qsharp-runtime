# compile test ll files into a library

set(RANDOM_BIT_FILES
#  qir-test-arrays
#  qir-test-functors
#  qir-test-noqsharp
#  qir-test-qsharp
#  qir-test-partials
#  qir-test-qubits-results
  qir-random-bit
)

foreach(file ${RANDOM_BIT_FILES})
  compile_from_qir(${file} "") # don't create a target per file
  list(APPEND QIR_RANDOM_BIT_LIBS ${QIR_UTILITY_LIB})
endforeach()

add_custom_target(qir_random_bit_lib DEPENDS ${QIR_RANDOM_BIT_LIBS})

#==============================================================================
# The executable target for QIR tests triggers the custom actions to compile ll files
#
add_executable(qir-random-bit
  qir-driver.cpp)

target_link_libraries(qir-random-bit PUBLIC
  ${QIR_RANDOM_BIT_LIBS}
  ${QIR_BRIDGE_UTILITY_LIB}
  ${QIR_BRIDGE_QIS_UTILITY_LIB}
  qir-rt-support
  qir-qis-support
  simulators
)

target_include_directories(qir-random-bit PUBLIC
  "${test_includes}"
  "${public_includes}"
  "${PROJECT_SOURCE_DIR}/lib/QIR"
)
add_dependencies(qir-random-bit qir_random_bit_lib)

install(TARGETS qir-random-bit RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin")
