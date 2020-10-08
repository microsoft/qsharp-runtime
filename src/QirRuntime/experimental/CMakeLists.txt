#==============================================================================
# produce the unit tests binary: experimental-unittests.exe
#
add_executable(experimental-unittests
  driver.cpp
  IntervalsColoringTests.cpp
  IonqTranslator.cpp
  IonqTranslatorTests.cpp
  LockstepSimulator.cpp
  LockstepSimulatorTests.cpp
  QubitInterferences.cpp
  QubitInterferencesTests.cpp
  TracingSimulator.cpp
  TracingSimulatorTests.cpp
)

target_link_libraries(experimental-unittests PUBLIC
  core
)

target_include_directories(experimental-unittests PUBLIC
   ${public_includes}
   ${test_includes}
)
install(TARGETS experimental-unittests RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin")

