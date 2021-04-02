#+++++++++++++++++++++++++++++++++++++
# qsharp-core-qis
#+++++++++++++++++++++++++++++++++++++

#===============================================================================
# create qsharp-core-qis-support lib from the C++ sources
#
set(qsharp_core_sup_source_files
  intrinsics.cpp
)

# Produce object lib we'll use to create a shared lib (so/dll) later on
add_library(qsharp-core-qis-support-obj OBJECT ${qsharp_core_sup_source_files})
target_source_from_qir(qsharp-core-qis-support-obj qsharp-core-qis.ll)
target_include_directories(qsharp-core-qis-support-obj PUBLIC ${public_includes})
set_property(TARGET qsharp-core-qis-support-obj PROPERTY POSITION_INDEPENDENT_CODE ON)
target_compile_definitions(qsharp-core-qis-support-obj PUBLIC EXPORT_QIR_API)

#===============================================================================
# Produce the Microsoft.Quantum.Qir.QSharp.Core dynamic library
#
add_library(Microsoft.Quantum.Qir.QSharp.Core SHARED)

target_link_libraries(Microsoft.Quantum.Qir.QSharp.Core
  ${CMAKE_DL_LIBS}
  qsharp-core-qis-support-obj
  simulators-obj
  "-L${CMAKE_BINARY_DIR}/lib/QIR"
  -lMicrosoft.Quantum.Qir.Runtime
)
add_dependencies(Microsoft.Quantum.Qir.QSharp.Core Microsoft.Quantum.Qir.Runtime)

target_include_directories(Microsoft.Quantum.Qir.QSharp.Core PUBLIC ${public_includes})
target_compile_definitions(Microsoft.Quantum.Qir.QSharp.Core PRIVATE EXPORT_QIR_API)

set_property(TARGET Microsoft.Quantum.Qir.QSharp.Core PROPERTY POSITION_INDEPENDENT_CODE ON)

install(TARGETS Microsoft.Quantum.Qir.QSharp.Core
  RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin"
  LIBRARY DESTINATION "${CMAKE_BINARY_DIR}/bin"
  ARCHIVE DESTINATION "${CMAKE_BINARY_DIR}/bin"
)

