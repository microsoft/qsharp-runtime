#+++++++++++++++++++++++++++++++++++++
# qsharp-foundation-qis
#+++++++++++++++++++++++++++++++++++++

#===============================================================================
# create qsharp-foundation-qis-support lib from the C++ sources
#
set(qsharp_foundation_sup_source_files
  AssertMeasurement.cpp
  intrinsicsMath.cpp
  conditionals.cpp
)

# Produce object lib we'll use to create a shared lib (so/dll) later on
add_library(qsharp-foundation-qis-support-obj OBJECT ${qsharp_foundation_sup_source_files})
target_include_directories(qsharp-foundation-qis-support-obj PUBLIC
  ${public_includes}
  ${common_includes}
)
set_property(TARGET qsharp-foundation-qis-support-obj PROPERTY POSITION_INDEPENDENT_CODE ON)
target_compile_definitions(qsharp-foundation-qis-support-obj PUBLIC EXPORT_QIR_API)

#===============================================================================
# Produce the Microsoft.Quantum.Qir.QSharp.Foundation dynamic library
#
add_library(Microsoft.Quantum.Qir.QSharp.Foundation SHARED)

add_library(Microsoft.Quantum.Qir.QSharp.Foundation.Static STATIC)

target_link_libraries(Microsoft.Quantum.Qir.QSharp.Foundation
  ${CMAKE_DL_LIBS}
  qsharp-foundation-qis-support-obj
  "-L${CMAKE_BINARY_DIR}/lib/QIR"
  -lMicrosoft.Quantum.Qir.Runtime
  ${SPECTRE_LIBS}
)
add_dependencies(Microsoft.Quantum.Qir.QSharp.Foundation Microsoft.Quantum.Qir.Runtime)

target_link_libraries(Microsoft.Quantum.Qir.QSharp.Foundation.Static
  ${CMAKE_DL_LIBS}
  qsharp-foundation-qis-support-obj
  "-L${CMAKE_BINARY_DIR}/lib/QIR"
  -lMicrosoft.Quantum.Qir.Runtime.Static
  ${SPECTRE_LIBS}
)
add_dependencies(Microsoft.Quantum.Qir.QSharp.Foundation.Static Microsoft.Quantum.Qir.Runtime.Static)

target_include_directories(Microsoft.Quantum.Qir.QSharp.Foundation PUBLIC 
  ${public_includes}
  ${common_includes}
)

target_compile_definitions(Microsoft.Quantum.Qir.QSharp.Foundation PRIVATE EXPORT_QIR_API)

target_compile_definitions(Microsoft.Quantum.Qir.QSharp.Foundation.Static PRIVATE EXPORT_QIR_API)

set_property(TARGET Microsoft.Quantum.Qir.QSharp.Foundation PROPERTY POSITION_INDEPENDENT_CODE ON)

set_property(TARGET Microsoft.Quantum.Qir.QSharp.Foundation.Static PROPERTY POSITION_INDEPENDENT_CODE ON)

install(TARGETS Microsoft.Quantum.Qir.QSharp.Foundation
  RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin"
  LIBRARY DESTINATION "${CMAKE_BINARY_DIR}/bin"
  ARCHIVE DESTINATION "${CMAKE_BINARY_DIR}/bin"
)

install(TARGETS Microsoft.Quantum.Qir.QSharp.Foundation.Static
  RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin"
  LIBRARY DESTINATION "${CMAKE_BINARY_DIR}/bin"
  ARCHIVE DESTINATION "${CMAKE_BINARY_DIR}/bin"
)
