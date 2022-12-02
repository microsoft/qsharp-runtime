set(TEST_FILES
  qsharp/qir/qir-gen.ll
)

#==============================================================================
# The executable target for QIR tests triggers the custom actions to compile ll files
#
add_executable(qir-static-tests
  qir-driver.cpp
  qir-test-math.cpp
  qir-test-strings.cpp
  qir-test-other.cpp
)

foreach(file ${TEST_FILES})
  target_source_from_qir(qir-static-tests ${file})
endforeach()

target_link_libraries(qir-static-tests PUBLIC
  "-L${simulator_lib_path}"
  -lMicrosoft.Quantum.Simulator.Runtime
)

target_include_directories(qir-static-tests PUBLIC
  ${test_includes}
  ${public_includes}
)

install(TARGETS qir-static-tests RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin")
add_unit_test(qir-static-tests)

