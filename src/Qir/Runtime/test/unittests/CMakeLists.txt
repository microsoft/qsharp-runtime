#==============================================================================
# produce the unit tests binary: qir-runtime-unittests.exe
#
add_executable(qir-runtime-unittests
  driver.cpp
  QirRuntimeTests.cpp
  ToffoliTests.cpp
  TracerTests.cpp
)

target_link_libraries(qir-runtime-unittests PUBLIC
  qir-rt-support
  qsharp-foundation-qis-support
  qsharp-core-qis-support
  simulators
  tracer
)

target_include_directories(qir-runtime-unittests PUBLIC 
  "${test_includes}"
   ${public_includes}
   "${PROJECT_SOURCE_DIR}/lib/QIR"
   "${PROJECT_SOURCE_DIR}/lib/QSharpFoundation"
   "${PROJECT_SOURCE_DIR}/lib/QSharpCore"
   "${PROJECT_SOURCE_DIR}/lib/Tracer"
)
target_compile_definitions(qir-runtime-unittests PRIVATE EXPORT_QIR_API)
install(TARGETS qir-runtime-unittests RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin")
add_unit_test(qir-runtime-unittests)
