#=======================================================================================================================
# This is a reference make file on how to build a QIR-based standalone executable.
#=======================================================================================================================
add_executable(qir-input-reference-standalone
  qir-driver.cpp
)

# This is where the generated QIR file is specified.
compile_from_qir(qir-standalone-input-reference qir_standalone_input_reference_target)

target_link_libraries(qir-input-reference-standalone PUBLIC
  ${QIR_UTILITY_LIB} # created by compile_from_qir
  "-L${CMAKE_BINARY_DIR}/lib/QIR"
  -lMicrosoft.Quantum.Qir.Runtime
  "-L${CMAKE_BINARY_DIR}/lib/QSharpFoundation"
  -lMicrosoft.Quantum.Qir.QSharp.Foundation
  "-L${CMAKE_BINARY_DIR}/lib/QSharpCore"
  -lMicrosoft.Quantum.Qir.QSharp.Core
)

set(standalone_includes "${PROJECT_SOURCE_DIR}/externals/CLI11")

target_include_directories(qir-input-reference-standalone PUBLIC
  "${standalone_includes}"
  "${public_includes}"
)

add_dependencies(qir-input-reference-standalone qir_standalone_input_reference_target)

install(TARGETS qir-input-reference-standalone RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin")

include(CTest)
add_test(
  NAME qir-input-reference-standalone
  COMMAND qir-input-reference-standalone --int-value 1 --integer-array 1 2 3 4 5 --double-value 0.5 --double-array 0.1 0.2 0.3 0.4 0.5 --bool-value true --bool-array true TRUE false fALSe 1 --pauli-value PauliX --pauli-array PauliI paulix PAULIY PAulIZ --range-value 1 2 10 --range-array 1 2 10 5 5 50 10 1 20 --string-value ASampleString --result-value one --result-array one ONE true TRUE 1 zero ZERO false FALSE 0
)

# set the environment path for loading shared libs the tests are using
if(DEFINED ENV{NATIVE_SIMULATOR})
    set(TEST_DEPS1 $ENV{NATIVE_SIMULATOR})
else()
    set(TEST_DEPS1 "${PROJECT_SOURCE_DIR}/../Simulation/native/build/${CMAKE_BUILD_TYPE}")
endif()

set(TEST_DEPS2 "${CMAKE_BINARY_DIR}/bin")
set_property(TEST qir-input-reference-standalone PROPERTY ENVIRONMENT
    "LD_LIBRARY_PATH=${TEST_DEPS1}:${TEST_DEPS2}:${LD_LIBRARY_PATH}"
    "PATH=${TEST_DEPS1}\;${TEST_DEPS2}\;${PATH}"
    "DYLD_LIBRARY_PATH=${TEST_DEPS1}:${TEST_DEPS2}:${DYLD_LIBRARY_PATH}"
)
