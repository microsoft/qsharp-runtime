# The downstream consumers but must pick up both the native support lib and the utility
# lib, produced from ll bridge files when linking against either qir-rt or qir-qis.

#+++++++++++++++++++++++++++++++++++++
# qir-rt
#+++++++++++++++++++++++++++++++++++++

#===============================================================================
# create a utility lib from bridge-rt.ll
#
set(bridge_rt_target "bridge_rt_target")
compile_from_qir(bridge-rt ${bridge_rt_target})

#===============================================================================
# create qir-rt-support lib from the C++ sources
#
set(rt_sup_source_files
  allocationsTracker.cpp
  arrays.cpp
  callables.cpp
  context.cpp
  delegated.cpp
  strings.cpp
  utils.cpp
  rtOut.cpp
)

add_library(qir-rt-support ${rt_sup_source_files})
target_include_directories(qir-rt-support PUBLIC ${public_includes})
add_dependencies(qir-rt-support ${bridge_rt_target})
target_compile_definitions(qir-rt-support PRIVATE EXPORT_QIR_API)

# Produce object lib we'll use to create a shared lib (so/dll) later on
add_library(qir-rt-support-obj OBJECT ${rt_sup_source_files})
target_source_from_qir_obj(qir-rt-support-obj bridge-rt)
target_include_directories(qir-rt-support-obj PUBLIC ${public_includes})
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
)

target_include_directories(Microsoft.Quantum.Qir.Runtime PUBLIC ${public_includes})
target_compile_definitions(Microsoft.Quantum.Qir.Runtime PRIVATE EXPORT_QIR_API)

set_property(TARGET Microsoft.Quantum.Qir.Runtime PROPERTY POSITION_INDEPENDENT_CODE ON)

install(TARGETS Microsoft.Quantum.Qir.Runtime
  RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin"
  LIBRARY DESTINATION "${CMAKE_BINARY_DIR}/bin"
  ARCHIVE DESTINATION "${CMAKE_BINARY_DIR}/bin"
)
