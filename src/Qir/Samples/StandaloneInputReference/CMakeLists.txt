#=======================================================================================================================
# This is a reference make file on how to build a QIR-based standalone executable.
#=======================================================================================================================
add_executable(qir-input-reference-standalone
  qir-driver.cpp
)

# This is where the generated QIR file is specified.
target_source_from_qir(qir-input-reference-standalone qsharp/obj/qsharp/qir-standalone-input-reference.bc)

target_link_libraries(qir-input-reference-standalone PUBLIC
  "-L${runtime_lib_path}"
  -lMicrosoft.Quantum.Qir.Runtime
  -lMicrosoft.Quantum.Qir.QSharp.Foundation
  -lMicrosoft.Quantum.Qir.QSharp.Core
)

set(standalone_includes "${PROJECT_SOURCE_DIR}/../Common/externals/CLI11")

target_include_directories(qir-input-reference-standalone PUBLIC
  "${standalone_includes}"
  "${public_includes}"
)

install(TARGETS qir-input-reference-standalone RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin")

include(CTest)
add_test(
  NAME qir-input-reference-standalone
  COMMAND qir-input-reference-standalone --int-value 1 --integer-array 1 2 3 4 5 --double-value 0.5 --double-array 0.1 0.2 0.3 0.4 0.5 --bool-value true --bool-array true TRUE false fALSe 1 --pauli-value PauliI --pauli-array PauliI paulix PAULIY PAulIZ --range-value 1 2 10 --range-array 1 2 10 5 5 50 10 1 20 --string-value ASampleString --result-value one --result-array one ONE 1 0 zero ZERO --string-array StringA StringB StringC
)

# set the environment path for loading shared libs the tests are using
if(DEFINED ENV{NATIVE_SIMULATOR})
    set(TEST_DEPS1 $ENV{NATIVE_SIMULATOR})
else()
    set(TEST_DEPS1 "${PROJECT_SOURCE_DIR}/../../Simulation/native/build/$ENV{BUILD_CONFIGURATION}")
endif()

set(TEST_DEPS2 "${PROJECT_SOURCE_DIR}/../Runtime/bin/$ENV{BUILD_CONFIGURATION}/bin")
set_property(TEST qir-input-reference-standalone PROPERTY ENVIRONMENT
    "LD_LIBRARY_PATH=${TEST_DEPS1}:${TEST_DEPS2}:${LD_LIBRARY_PATH}"
    "PATH=${TEST_DEPS1}\;${TEST_DEPS2}\;${PATH}"
    "DYLD_LIBRARY_PATH=${TEST_DEPS1}:${TEST_DEPS2}:${DYLD_LIBRARY_PATH}"
)
