#=======================================================================================================================
# This is a reference make file on how to build a QIR-based standalone executable.
#=======================================================================================================================

add_executable(qir-entrypoint-supported-inputs-exe
  qir-driver.cpp
)

# This is where the generated QIR file is specified.
compile_from_qir(qir-entrypoint-supported-inputs qir_entry_point_supported_inputs_target)

target_link_libraries(qir-entrypoint-supported-inputs-exe PUBLIC
  ${QIR_UTILITY_LIB} # created by compile_from_qir
  ${QIR_BRIDGE_UTILITY_LIB}
  ${QIR_BRIDGE_QIS_UTILITY_LIB}
  qir-rt-support
  qir-qis-support
  simulators
)

target_include_directories(qir-entrypoint-supported-inputs-exe PUBLIC
  "${standalone_includes}"
  "${public_includes}"
  "${PROJECT_SOURCE_DIR}/lib/QIR"
)

add_dependencies(qir-entrypoint-supported-inputs-exe qir_entry_point_supported_inputs_target)

install(TARGETS qir-entrypoint-supported-inputs-exe RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin")
