# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

add_executable(tinymatrix_test tinymatrix_test.cpp)
add_executable(diagmatrix_test diagmatrix_test.cpp)
add_executable(bitops_test bitops_test.cpp)
add_executable(openmp_test openmp_test.cpp)
add_executable(argmaxnrm2_test argmaxnrm2_test.cpp)
add_executable(bititerator_test bititerator_test.cpp)
add_executable(cpuid_test cpuid_test.cpp)

target_link_libraries(openmp_test Microsoft.Quantum.Simulator.Runtime)

add_test(NAME tinymatrix COMMAND  ./tinymatrix_test WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
add_test(NAME diagmatrix COMMAND  ./diagmatrix_test WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
add_test(NAME bitops COMMAND   ./bitops_test WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
add_test(NAME openmp COMMAND  ./openmp_test WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
add_test(NAME argmaxnrm2 COMMAND  ./argmaxnrm2_test WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
add_test(NAME bititerator COMMAND  ./bititerator_test WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
add_test(NAME cpuid_test COMMAND  ./cpuid_test WORKING_DIRECTORY ${CMAKE_BINARY_DIR})

