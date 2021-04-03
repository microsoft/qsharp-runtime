set(TEST_FILES
  qir-test-noqsharp.ll
  qsharp/qir/qir-gen.ll
)

#==============================================================================
# The executable target for QIR tests triggers the custom actions to compile ll files
#
add_executable(qir-static-tests
  qir-driver.cpp
  qir-test-conditionals.cpp
  qir-test-math.cpp
  qir-test-strings.cpp
  qir-test-ouput.cpp
  qir-test-other.cpp
)

foreach(file ${TEST_FILES})
  target_source_from_qir(qir-static-tests ${file})
endforeach()

target_link_libraries(qir-static-tests PUBLIC
  "-L${runtime_lib_path}"
  -lMicrosoft.Quantum.Qir.Runtime
  -lMicrosoft.Quantum.Qir.QSharp.Foundation
  -lMicrosoft.Quantum.Qir.QSharp.Core
)

target_include_directories(qir-static-tests PUBLIC
  ${test_includes}
  ${common_includes}
  ${public_includes}
)
# target_compile_definitions(qir-static-tests PRIVATE EXPORT_QIR_API)

install(TARGETS qir-static-tests RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin")
add_unit_test(qir-static-tests)

