# build the native part of the tracer
set(source_files
  "tracer-qis.cpp"
  "tracer.cpp"
)

set(includes
  "${public_includes}"
  "${PROJECT_SOURCE_DIR}/lib/QIR"
)

# Produce object lib we'll use to create a shared lib (so/dll) later on
add_library(tracer-obj OBJECT ${source_files})
target_source_from_qir(tracer-obj tracer-bridge.ll)
target_include_directories(tracer-obj PUBLIC ${includes})
set_property(TARGET tracer-obj PROPERTY POSITION_INDEPENDENT_CODE ON)
target_compile_definitions(tracer-obj PRIVATE EXPORT_QIR_API)

#===============================================================================
# Produce the Microsoft.Quantum.Qir.Tracer dynamic library
#
add_library(Microsoft.Quantum.Qir.Tracer SHARED)

target_link_libraries(Microsoft.Quantum.Qir.Tracer
  ${CMAKE_DL_LIBS}
  tracer-obj
  "-L${CMAKE_BINARY_DIR}/lib/QIR"
  -lMicrosoft.Quantum.Qir.Runtime
)
add_dependencies(Microsoft.Quantum.Qir.Tracer Microsoft.Quantum.Qir.Runtime)

target_include_directories(Microsoft.Quantum.Qir.Tracer PUBLIC ${includes})
target_compile_definitions(Microsoft.Quantum.Qir.Tracer PRIVATE EXPORT_QIR_API)

set_property(TARGET Microsoft.Quantum.Qir.Tracer PROPERTY POSITION_INDEPENDENT_CODE ON)

install(TARGETS Microsoft.Quantum.Qir.Tracer
  RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin"
  LIBRARY DESTINATION "${CMAKE_BINARY_DIR}/bin"
  ARCHIVE DESTINATION "${CMAKE_BINARY_DIR}/bin"
)
