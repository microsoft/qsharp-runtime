# build the utility lib for tracer's bridge
compile_from_qir(tracer-bridge tracer-bridge)

# build the native part of the tracer
set(source_files
  "tracer-qis.cpp"
  "tracer.cpp"
)

set(includes
  "${public_includes}"
  "${PROJECT_SOURCE_DIR}/lib/QIR"
)

add_library(tracer STATIC ${source_files})
target_include_directories(tracer PUBLIC ${includes})
add_dependencies(tracer tracer-bridge)
target_compile_definitions(tracer PRIVATE EXPORT_QIR_API)

# Produce object lib we'll use to create a shared lib (so/dll) later on
add_library(tracer-obj OBJECT ${source_files})
target_source_from_qir_obj(tracer-obj tracer-bridge)
target_include_directories(tracer-obj PUBLIC ${includes})
set_property(TARGET tracer-obj PROPERTY POSITION_INDEPENDENT_CODE ON)
target_compile_definitions(tracer-obj PRIVATE EXPORT_QIR_API)

#===============================================================================
# Produce the qirtracer dynamic library
#
add_library(qirtracer SHARED)

target_link_libraries(qirtracer
  ${CMAKE_DL_LIBS}
  tracer-obj
  "-L${CMAKE_BINARY_DIR}/lib/QIR"
  -lMicrosoft.Quantum.Qir.Runtime
)

target_include_directories(qirtracer PUBLIC ${includes})
target_compile_definitions(qirtracer PRIVATE EXPORT_QIR_API)

set_property(TARGET qirtracer PROPERTY POSITION_INDEPENDENT_CODE ON)

install(TARGETS qirtracer
  RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin"
  LIBRARY DESTINATION "${CMAKE_BINARY_DIR}/bin"
)
