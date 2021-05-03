add_executable(fullstate-simulator-tests
  FullstateSimulatorTests.cpp)

target_source_from_qir(fullstate-simulator-tests qsharp/obj/qsharp/qir-test-simulator.bc)

target_link_libraries(fullstate-simulator-tests PUBLIC
  "-L${runtime_lib_path}"
  -lMicrosoft.Quantum.Qir.Runtime
  -lMicrosoft.Quantum.Qir.QSharp.Foundation
  -lMicrosoft.Quantum.Qir.QSharp.Core
)

target_include_directories(fullstate-simulator-tests PUBLIC
  ${test_includes}
  ${public_includes}
)

install(TARGETS fullstate-simulator-tests RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin")
add_unit_test(fullstate-simulator-tests)

