set(TEST_FILES
  qsharp/qir/qir-test-random.ll
)

#==============================================================================
# This executable target links test code against the dynamic libraries rather than the explicit
# static QIR/RT libs (qir will statically link in the bridge via transitivity of target_link_libraries).
#
add_executable(qir-dynamic-tests
  qir-driver.cpp
)

foreach(file ${TEST_FILES})
  target_source_from_qir(qir-dynamic-tests ${file})
endforeach()

target_link_libraries(qir-dynamic-tests PUBLIC
  "-L${runtime_lib_path}"
  -lMicrosoft.Quantum.Qir.Runtime
  -lMicrosoft.Quantum.Qir.QSharp.Foundation
  -lMicrosoft.Quantum.Qir.QSharp.Core
)

target_include_directories(qir-dynamic-tests PUBLIC
  ${test_includes}
  ${public_includes}
)

install(TARGETS qir-dynamic-tests RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin")
add_unit_test(qir-dynamic-tests)
