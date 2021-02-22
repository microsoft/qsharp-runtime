# compile test ll files into a library

set(TEST_FILES
  qir-entrypoint-supported-inputs
)

foreach(file ${TEST_FILES})
  compile_from_qir(${file} "") # don't create a target per file
  list(APPEND QIR_TESTS_LIBS ${QIR_UTILITY_LIB})
endforeach()

add_custom_target(qir_entrypoint_supported_inputs_lib DEPENDS ${QIR_TESTS_LIBS})

#==============================================================================
# The executable target for QIR tests triggers the custom actions to compile ll files
#
add_executable(qir-entrypoint-supported-inputs
  qir-driver.cpp
)

target_link_libraries(qir-entrypoint-supported-inputs PUBLIC
  ${QIR_TESTS_LIBS}
  ${QIR_BRIDGE_UTILITY_LIB}
  ${QIR_BRIDGE_QIS_UTILITY_LIB}
  qir-rt-support
  qir-qis-support
  simulators
)

target_include_directories(qir-entrypoint-supported-inputs PUBLIC
  "${test_includes}"
  "${standalone_includes}"
  "${public_includes}"
  "${PROJECT_SOURCE_DIR}/lib/QIR"
)
add_dependencies(qir-entrypoint-supported-inputs qir_entrypoint_supported_inputs_lib)

install(TARGETS qir-entrypoint-supported-inputs RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin")
