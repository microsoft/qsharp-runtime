
compile_from_qir(qir-test-opensimulator qir_test_opensimulator_target)

add_executable(open-systems-simulator-tests
  OpenSystemsSimulatorTests.cpp)

target_link_libraries(open-systems-simulator-tests PUBLIC
  ${QIR_UTILITY_LIB} # created by compile_from_qir
  ${QIR_BRIDGE_UTILITY_LIB}
  ${QIR_BRIDGE_QIS_UTILITY_LIB}
  qir-rt-support
  qir-qis-support
  simulators
)

target_include_directories(open-systems-simulator-tests PUBLIC
  "${test_includes}"
  "${public_includes}"
  "${PROJECT_SOURCE_DIR}/lib/QIR"
)
# add_dependencies(open-systems-simulator-tests qir_test_opensimulator_target)

# install(TARGETS open-systems-simulator-tests RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin")
# add_unit_test(open-systems-simulator-tests)

