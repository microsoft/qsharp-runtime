# build the utility lib for tracer's bridge
compile_from_qir(bridge-trc bridge_trc)

# build the native part of the tracer
set(component_name "tracer")

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

add_dependencies(${component_name} bridge_trc)
