set(TEST_FILES
  qsharp/qir/tracer-qir.ll
)

#==============================================================================
# The executable target for QIR tests triggers the custom actions to compile ll files
#
add_executable(qir-tracer-tests
  qir-tracer-driver.cpp
  tracer-config.cpp
)

foreach(file ${TEST_FILES})
  target_source_from_qir(qir-tracer-tests ${file})
endforeach()

target_link_libraries(qir-tracer-tests PUBLIC
  "-L${runtime_lib_path}"
  -lMicrosoft.Quantum.Qir.Runtime
  -lMicrosoft.Quantum.Qir.Tracer
)

target_include_directories(qir-tracer-tests PUBLIC
  ${test_includes}
  ${public_includes}
  "${PROJECT_SOURCE_DIR}/../Runtime/lib/Tracer" # TODO: Remove this when tracer api is put into public headers.
)

install(TARGETS qir-tracer-tests RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin")
add_unit_test(qir-tracer-tests)
