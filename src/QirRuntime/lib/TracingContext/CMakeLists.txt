set(component_name "resource-tracer")

set(source_files
  "TracingContext.cpp"
)

set(includes
  "${public_includes}"
)

add_library(${component_name} ${source_files})
target_include_directories(${component_name} PUBLIC ${includes})
#set_property(TARGET ${component_name} PROPERTY INTERPROCEDURAL_OPTIMIZATION True)
