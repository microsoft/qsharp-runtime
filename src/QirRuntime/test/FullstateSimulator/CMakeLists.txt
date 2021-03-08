
compile_from_qir(qir-test-simulator qir_test_simulator_target)

add_executable(fullstate-simulator-tests
  FullstateSimulatorTests.cpp)

target_link_libraries(fullstate-simulator-tests PUBLIC
  ${QIR_UTILITY_LIB} # created by compile_from_qir
  ${QIR_BRIDGE_UTILITY_LIB}
  ${QIR_BRIDGE_QIS_UTILITY_LIB}
  ${QSHARP_CORE_BRIDGE_QIS_UTILITY_LIB}
  qir-rt-support
  qir-qis-support
  qsharp-core-qis-support
  simulators
)

target_include_directories(fullstate-simulator-tests PUBLIC
  "${test_includes}"
  "${public_includes}"
  "${PROJECT_SOURCE_DIR}/lib/QIR"
)
target_compile_definitions(fullstate-simulator-tests PRIVATE EXPORT_QIR_API)
add_dependencies(fullstate-simulator-tests qir_test_simulator_target)

install(TARGETS fullstate-simulator-tests RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin")
add_unit_test(fullstate-simulator-tests)

