set(component_name "tracer")

# the tracer implements its own management of qubits/results but reuses the rest of the qir-runtime
# TODO: consider splitting qir-rt into two libs
set(source_files
  "../QIR/arrays.cpp"
  "../QIR/callables.cpp"
  "../QIR/strings.cpp"
  "../QIR/utils.cpp"
  "tracer-rt.cpp"
  "tracer-trc.cpp"
  "tracer.cpp"
)

set(includes
  "${public_includes}"
  "${PROJECT_SOURCE_DIR}/lib/QIR"
)


#===============================================================================
# Produce static lib for users to link directly to

add_library(${component_name} STATIC ${source_files})
target_include_directories(${component_name} PUBLIC ${includes})
target_link_libraries(${component_name} ${CMAKE_DL_LIBS})

# The tracer cannot be included into qdk.dll so we don't build an object lib for it
