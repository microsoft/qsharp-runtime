# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

add_executable(factory_test factory_test.cpp)
target_link_libraries(factory_test Microsoft.Quantum.Simulator.Runtime cudaquantumgates)
add_test(NAME factory_test COMMAND ./factory_test WORKING_DIRECTORY ${CMAKE_BINARY_DIR})

add_executable(capi_test capi_test.cpp)
target_link_libraries(capi_test Microsoft.Quantum.Simulator.Runtime cudaquantumgates)
add_test(NAME capi_test COMMAND ./capi_test WORKING_DIRECTORY ${CMAKE_BINARY_DIR})

add_executable(dbw_test dbw_test.cpp)
target_link_libraries(dbw_test Microsoft.Quantum.Simulator.Runtime cudaquantumgates)
add_test(NAME dbw_test COMMAND ./dbw_test WORKING_DIRECTORY ${CMAKE_BINARY_DIR})



add_executable(quantum_simulator_unittests
  "${PROJECT_SOURCE_DIR}/src/catch2/catch_driver.cpp"
  local_test.cpp
)

target_link_libraries(quantum_simulator_unittests PUBLIC
  Microsoft.Quantum.Simulator.Runtime cudaquantumgates
)

set_target_properties(quantum_simulator_unittests PROPERTIES COMPILE_DEFINITIONS "CATCH2_TESTS=1")
target_include_directories(quantum_simulator_unittests PUBLIC
  "${PROJECT_SOURCE_DIR}/src/catch2"
)

install(TARGETS quantum_simulator_unittests RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/drop")

add_test(
    NAME quantum_simulator_unittests
    COMMAND quantum_simulator_unittests ~[skip] -o "quantum_simulator_unittests_results.xml" -r junit
)
