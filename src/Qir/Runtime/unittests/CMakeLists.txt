include(unit_test_include)

#==============================================================================
# produce the unit tests binary: qir-runtime-unittests.exe
#
add_executable(qir-runtime-unittests
  driver.cpp
  QirOutputHandlingTests.cpp
  QirRuntimeTests.cpp
  ToffoliTests.cpp
  TracerTests.cpp
  QubitManagerTests.cpp
  $<TARGET_OBJECTS:qir-rt-support-obj>
  $<TARGET_OBJECTS:qsharp-foundation-qis-support-obj>
  $<TARGET_OBJECTS:qsharp-core-qis-support-obj>
  $<TARGET_OBJECTS:simulators-obj>
  $<TARGET_OBJECTS:tracer-obj>
)

target_include_directories(qir-runtime-unittests PUBLIC 
  "${PROJECT_SOURCE_DIR}/../Common/Externals/catch2"
  ${public_includes}
  ${common_includes}
  "${PROJECT_SOURCE_DIR}/lib/QIR"
  "${PROJECT_SOURCE_DIR}/lib/QSharpFoundation"
  "${PROJECT_SOURCE_DIR}/lib/QSharpCore"
  "${PROJECT_SOURCE_DIR}/lib/Tracer"
)
target_link_libraries(qir-runtime-unittests ${CMAKE_DL_LIBS})
target_compile_definitions(qir-runtime-unittests PRIVATE EXPORT_QIR_API)
install(TARGETS qir-runtime-unittests RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin")
add_unit_test(qir-runtime-unittests)
