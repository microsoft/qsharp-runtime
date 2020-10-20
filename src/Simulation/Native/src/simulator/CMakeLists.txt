# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

add_executable(local_test local_test.cpp)
add_executable(factory_test factory_test.cpp)
add_executable(capi_test capi_test.cpp)
add_executable(dbw_test dbw_test.cpp)
target_link_libraries(factory_test Microsoft.Quantum.Simulator.Runtime)
target_link_libraries(local_test Microsoft.Quantum.Simulator.Runtime)
target_link_libraries(capi_test Microsoft.Quantum.Simulator.Runtime)
target_link_libraries(dbw_test Microsoft.Quantum.Simulator.Runtime)
add_test(NAME factory_test COMMAND ./factory_test WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
add_test(NAME local_test COMMAND ./local_test WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
add_test(NAME capi_test COMMAND ./capi_test WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
add_test(NAME dbw_test COMMAND ./dbw_test WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
