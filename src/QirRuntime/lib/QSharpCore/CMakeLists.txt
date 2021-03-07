#+++++++++++++++++++++++++++++++++++++
# qsharp-core-qis
#+++++++++++++++++++++++++++++++++++++

#===============================================================================
# create a utility lib from qsharp-core-qis.ll
#
set(qsharp_core_qis_target "qsharp_core_qis_target")
compile_from_qir(qsharp-core-qis ${qsharp_core_qis_target})

#===============================================================================
# create qsharp-core-qis-support lib from the C++ sources
#
set(qsharp_core_sup_source_files
  intrinsics.cpp
)

add_library(qsharp-core-qis-support ${qsharp_core_sup_source_files})
target_include_directories(qsharp-core-qis-support PUBLIC ${public_includes})
add_dependencies(qsharp-core-qis-support ${qsharp_core_qis_target})
target_compile_definitions(qsharp-core-qis-support PRIVATE EXPORT_QIR_API)

# Produce object lib we'll use to create a shared lib (so/dll) later on
add_library(qsharp-core-qis-support-obj OBJECT ${qsharp_core_sup_source_files})
target_source_from_qir_obj(qsharp-core-qis-support-obj qsharp-core-qis)
target_include_directories(qsharp-core-qis-support-obj PUBLIC ${public_includes})
set_property(TARGET qsharp-core-qis-support-obj PROPERTY POSITION_INDEPENDENT_CODE ON)
target_compile_definitions(qsharp-core-qis-support-obj PUBLIC EXPORT_QIR_API)

#===============================================================================
# Produce the QSharpCore dynamic library
#
add_library(QSharpCore SHARED)

target_link_libraries(QSharpCore
  ${CMAKE_DL_LIBS}
  qsharp-core-qis-support-obj
  simulators-obj
  "-L${CMAKE_BINARY_DIR}/lib/QIR"
  -lqir
)

target_include_directories(QSharpCore PUBLIC ${public_includes})
target_compile_definitions(QSharpCore PRIVATE EXPORT_QIR_API)

set_property(TARGET QSharpCore PROPERTY POSITION_INDEPENDENT_CODE ON)

install(TARGETS QSharpCore
  LIBRARY DESTINATION "${CMAKE_BINARY_DIR}/bin"
)

