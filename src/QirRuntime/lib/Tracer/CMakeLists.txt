set(component_name "tracer")
set(bridge_lib "bridge_trc_u")

compile_from_qir(bridge-trc ${bridge_lib})

# the tracer implements its own management of qubits/results but reuses the rest of the qir-runtime
# TODO: consider splitting qir-rt into two libs
set(source_files
  "tracer-trc.cpp"
  "tracer.cpp"
)

set(includes
  "${public_includes}"
  "${PROJECT_SOURCE_DIR}/lib/QIR"
)

add_library(${component_name} STATIC ${source_files})

target_include_directories(${component_name} PUBLIC ${includes})

MESSAGE(INFO "*** ${QIR_UTILITY_LIB}")
target_link_libraries(${component_name}
  ${QIR_UTILITY_LIB} # absolute path to the bridge library, set by compile_from_ir
)

add_dependencies(${component_name} ${bridge_lib})
