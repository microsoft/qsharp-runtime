#+++++++++++++++++++++++++++++++++++++
# qsharp-foundation-qis
#+++++++++++++++++++++++++++++++++++++

#===============================================================================
# create a utility lib from qsharp-foundation-qis.ll
#
set(qsharp_foundation_qis_target "qsharp_foundation_qis_target")
compile_from_qir(qsharp-foundation-qis ${qsharp_foundation_qis_target})

#===============================================================================
# create qsharp-foundation-qis-support lib from the C++ sources
#
set(qsharp_foundation_sup_source_files
  intrinsicsMath.cpp
  intrinsicsOut.cpp
  conditionals.cpp
)

add_library(qsharp-foundation-qis-support ${qsharp_foundation_sup_source_files})
target_include_directories(qsharp-foundation-qis-support PUBLIC ${public_includes})
add_dependencies(qsharp-foundation-qis-support ${qsharp_foundation_qis_target})
target_compile_definitions(qsharp-foundation-qis-support PRIVATE EXPORT_QIR_API)

# Produce object lib we'll use to create a shared lib (so/dll) later on
add_library(qsharp-foundation-qis-support-obj OBJECT ${qsharp_foundation_sup_source_files})
target_source_from_qir_obj(qsharp-foundation-qis-support-obj qsharp-foundation-qis)
target_include_directories(qsharp-foundation-qis-support-obj PUBLIC ${public_includes})
set_property(TARGET qsharp-foundation-qis-support-obj PROPERTY POSITION_INDEPENDENT_CODE ON)
target_compile_definitions(qsharp-foundation-qis-support-obj PUBLIC EXPORT_QIR_API)

#===============================================================================
# Produce the Microsoft.Quantum.Qir.QSharp.Foundation dynamic library
#
add_library(Microsoft.Quantum.Qir.QSharp.Foundation SHARED)

target_link_libraries(Microsoft.Quantum.Qir.QSharp.Foundation
  ${CMAKE_DL_LIBS}
  qsharp-foundation-qis-support-obj
  "-L${CMAKE_BINARY_DIR}/lib/QIR"
  -lMicrosoft.Quantum.Qir.Runtime
)

target_include_directories(Microsoft.Quantum.Qir.QSharp.Foundation PUBLIC ${public_includes})
target_compile_definitions(Microsoft.Quantum.Qir.QSharp.Foundation PRIVATE EXPORT_QIR_API)

set_property(TARGET Microsoft.Quantum.Qir.QSharp.Foundation PROPERTY POSITION_INDEPENDENT_CODE ON)

install(TARGETS Microsoft.Quantum.Qir.QSharp.Foundation
  RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin"
  LIBRARY DESTINATION "${CMAKE_BINARY_DIR}/bin"
  ARCHIVE DESTINATION "${CMAKE_BINARY_DIR}/bin"
)

