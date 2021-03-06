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

# Produce object lib we'll use to create a shared lib (so/dll) later on
add_library(qsharp-core-qis-support-obj OBJECT ${qsharp_core_sup_source_files})
target_include_directories(qsharp-core-qis-support-obj PUBLIC ${public_includes})
set_property(TARGET qsharp-core-qis-support-obj PROPERTY POSITION_INDEPENDENT_CODE ON)

add_dependencies(qsharp-core-qis-support ${qsharp_core_qis_target})

#===============================================================================
# Produce the QSharpCore dynamic library
#
add_library(QSharpCore SHARED
  $<TARGET_OBJECTS:qsharp-core-qis-support-obj>
  $<TARGET_OBJECTS:simulators-obj>
)

target_link_libraries(QSharpCore
  ${QSHARP_CORE_BRIDGE_QIS_UTILITY_LIB}
  ${CMAKE_DL_LIBS}
)

target_include_directories(QSharpCore PUBLIC 
   ${public_includes}
)

set_property(TARGET QSharpCore PROPERTY POSITION_INDEPENDENT_CODE ON)

install(TARGETS QSharpCore
  RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin" 
  LIBRARY DESTINATION "${CMAKE_BINARY_DIR}/bin"
)

