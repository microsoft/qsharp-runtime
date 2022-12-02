add_executable(fullstate-simulator-tests FullstateSimulatorTests.cpp)

target_source_from_qir(fullstate-simulator-tests qsharp/obj/qsharp/qir-test-simulator.bc)

target_link_libraries(fullstate-simulator-tests PUBLIC
  "-L${simulator_lib_path}"
  -lMicrosoft.Quantum.Simulator.Runtime
)

target_include_directories(fullstate-simulator-tests PUBLIC
  ${test_includes}
)

install(TARGETS fullstate-simulator-tests RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin")
add_unit_test(fullstate-simulator-tests)

