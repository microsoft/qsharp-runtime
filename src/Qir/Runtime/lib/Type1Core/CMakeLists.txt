#+++++++++++++++++++++++++++++++++++++
# type1-core-qis
#+++++++++++++++++++++++++++++++++++++

#===============================================================================
# create type1-core-qis-support lib from the C++ sources
#
set(qsharp_core_sup_source_files
  intrinsicsDump.cpp
  intrinsics.cpp
)

# Produce object lib we'll use to create a shared lib (so/dll) later on
add_library(type1-core-qis-support-obj OBJECT ${qsharp_core_sup_source_files})
target_source_from_qir(type1-core-qis-support-obj type1-core-qis.ll)
target_include_directories(type1-core-qis-support-obj PUBLIC ${public_includes})
set_property(TARGET type1-core-qis-support-obj PROPERTY POSITION_INDEPENDENT_CODE ON)
target_compile_definitions(type1-core-qis-support-obj PUBLIC EXPORT_QIR_API)

#===============================================================================
# Produce the Microsoft.Quantum.Qir.Type1.Core dynamic library
#
add_library(Microsoft.Quantum.Qir.Type1.Core SHARED)

target_link_libraries(Microsoft.Quantum.Qir.Type1.Core
  ${CMAKE_DL_LIBS}
  type1-core-qis-support-obj
  simulators-obj
  "-L${CMAKE_BINARY_DIR}/lib/QIR"
  -lMicrosoft.Quantum.Qir.Runtime
)
add_dependencies(Microsoft.Quantum.Qir.Type1.Core Microsoft.Quantum.Qir.Runtime)

target_include_directories(Microsoft.Quantum.Qir.Type1.Core PUBLIC ${public_includes})
target_compile_definitions(Microsoft.Quantum.Qir.Type1.Core PRIVATE EXPORT_QIR_API)

set_property(TARGET Microsoft.Quantum.Qir.Type1.Core PROPERTY POSITION_INDEPENDENT_CODE ON)

install(TARGETS Microsoft.Quantum.Qir.Type1.Core
  RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin"
  LIBRARY DESTINATION "${CMAKE_BINARY_DIR}/bin"
  ARCHIVE DESTINATION "${CMAKE_BINARY_DIR}/bin"
)

