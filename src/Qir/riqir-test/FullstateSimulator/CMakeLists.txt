add_executable(fullstate-simulator-tests
../../Tests/FullstateSimulator/FullstateSimulatorTests.cpp)

target_source_from_qir(fullstate-simulator-tests ../../Tests/FullstateSimulator/qsharp/obj/qsharp/qir-test-simulator.bc)

target_link_libraries(fullstate-simulator-tests PUBLIC
  "-L${runtime_lib_path}"
  -lqir_range_support
  -lqir_sim
)

target_include_directories(fullstate-simulator-tests PUBLIC
  ${test_includes}
  ${public_includes}
)
target_compile_definitions(fullstate-simulator-tests PRIVATE RIQIR_TESTING)

install(TARGETS fullstate-simulator-tests RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin")
add_unit_test(fullstate-simulator-tests)

