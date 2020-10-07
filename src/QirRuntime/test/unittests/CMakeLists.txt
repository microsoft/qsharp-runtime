#==============================================================================
# produce the unit tests binary: unittests.exe
#
add_executable(unittests
  driver.cpp
  ChunkedStoreTests.cpp
  DeferredResultsTests.cpp
  FullstateSimulatorTests.cpp
  QIRSupport.cpp
  ToffoliTests.cpp
)

target_link_libraries(unittests PUBLIC
  simulators
  core
  qir-rt
)

target_include_directories(unittests PUBLIC 
  "${test_includes}"
   ${public_includes}
  "${PROJECT_SOURCE_DIR}/lib/QIR"
)
install(TARGETS unittests RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin")

#==============================================================================
# build against tracing context
#
add_executable(tracer-tests
  "TracingContextTests.cpp")

target_link_libraries(tracer-tests PUBLIC
  simulators
  core
  resource-tracer
)

# this setting enables LTO (link time optimizations), but to benefit across
# libraries, the linked libraries also should enable it.
#set_property(TARGET tracer-tests PROPERTY INTERPROCEDURAL_OPTIMIZATION True)

target_include_directories(tracer-tests PUBLIC 
  "${test_includes}"
  "${public_includes}"
)
install(TARGETS tracer-tests RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin")
