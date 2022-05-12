# The downstream consumers but must pick up both the native support lib and the utility
# lib, produced from ll bridge files when linking against either qir-rt or qir-qis.

#+++++++++++++++++++++++++++++++++++++
# qir-rt
#+++++++++++++++++++++++++++++++++++++

#===============================================================================
# create qir-rt-support lib from the C++ sources
#
set(rt_sup_source_files
  QirOutputHandling.cpp
  OutputStream.cpp
  Output.cpp
  allocationsTracker.cpp
  arrays.cpp
  callables.cpp
  context.cpp
  delegated.cpp
  strings.cpp
  utils.cpp
  QubitManager.cpp
  BasicRuntimeDriver.cpp
)

# Produce object lib we'll use to create a shared lib (so/dll) later on
add_library(qir-rt-support-obj OBJECT ${rt_sup_source_files})
target_source_from_qir(qir-rt-support-obj bridge-rt.ll)
target_include_directories(qir-rt-support-obj PUBLIC 
    ${public_includes}   
    ${common_includes}
)
set_property(TARGET qir-rt-support-obj PROPERTY POSITION_INDEPENDENT_CODE ON)
target_compile_definitions(qir-rt-support-obj PRIVATE EXPORT_QIR_API)

#+++++++++++++++++++++++++++++++++++++
# qir-qis
#+++++++++++++++++++++++++++++++++++++

#===============================================================================
# Produce the Microsoft.Quantum.Qir.Runtime dynamic library
#
add_library(Microsoft.Quantum.Qir.Runtime SHARED)

target_link_libraries(Microsoft.Quantum.Qir.Runtime
  ${CMAKE_DL_LIBS}
  qir-rt-support-obj
  ${SPECTRE_LIBS}
)

target_include_directories(Microsoft.Quantum.Qir.Runtime PUBLIC ${public_includes})
target_compile_definitions(Microsoft.Quantum.Qir.Runtime PRIVATE EXPORT_QIR_API)

set_property(TARGET Microsoft.Quantum.Qir.Runtime PROPERTY POSITION_INDEPENDENT_CODE ON)

install(TARGETS Microsoft.Quantum.Qir.Runtime
  RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin"
  LIBRARY DESTINATION "${CMAKE_BINARY_DIR}/bin"
  ARCHIVE DESTINATION "${CMAKE_BINARY_DIR}/bin"
)
