add_executable(type1-simulator-tests
  FullstateSimulatorTests.cpp)

target_source_from_qir(type1-simulator-tests qsharp/qir/qir-test-simulator.ll)

target_link_libraries(type1-simulator-tests PUBLIC
  "-L${runtime_lib_path}"
  -lMicrosoft.Quantum.Qir.Runtime
  -lMicrosoft.Quantum.Qir.QSharp.Foundation
  -lMicrosoft.Quantum.Qir.Type1.Core
)

target_include_directories(type1-simulator-tests PUBLIC
  ${test_includes}
  ${public_includes}
)

install(TARGETS type1-simulator-tests RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin")
add_unit_test(type1-simulator-tests)

