#
# CMake doesn't support IR files as sources so we do this with custom commands,
# which produce UTILITY libs that can only be linked in using abs paths (rather
# than the target name):
#   Target "qir_bridge_qis" of type UTILITY may not be linked into another
#   target.  One may link only to INTERFACE, OBJECT, STATIC or SHARED
#   libraries, or to executables with the ENABLE_EXPORTS property set.
#
# The other complication is that the bridge funtions calls into the rt
# so on Linux the dependency requires to introduce a new target that sits
# on top of both and links them in the correct order. This top target doesn't
# have any code of its own but CMake insists on providing a source file, thus
# __dummy.cpp...
#

set(CLANG_ARGS "-c")
if (CMAKE_BUILD_TYPE STREQUAL "Debug")
set(CLANG_ARGS
  "${CLANG_ARGS}"
  "-O0"
  "-D_DEBUG"
)
endif()

#+++++++++++++++++++++++++++++++++++++
# qir-rt
#+++++++++++++++++++++++++++++++++++++

#===============================================================================
# Step 1: create qir-rt-support lib from the C++ sources
#
set(rt_sup_source_files
  "arrays.cpp"
  "callables.cpp"
  "delegated.cpp"
  "strings.cpp"
  "utils.cpp"
)

add_library(qir-rt-support ${rt_sup_source_files})

target_include_directories(qir-rt-support PUBLIC ${public_includes})
produce_ir(qir-rt-support)

# Produce object lib we'll use to create a shared lib (so/dll) later on
add_library(qir-rt-support-obj OBJECT ${rt_sup_source_files})
target_include_directories(qir-rt-support-obj PUBLIC ${public_includes})
set_property(TARGET qir-rt-support-obj PROPERTY POSITION_INDEPENDENT_CODE ON)

#===============================================================================
# Step 2: create a utility lib from bridge-rt.ll
#
set(INFILE
  "${CMAKE_CURRENT_SOURCE_DIR}/bridge-rt.ll"
)
set(OBJFILE
  "${PROJECT_BINARY_DIR}/lib/QIR/bridge.obj"
)

set(BRIDGE_COMPILE "bridge-compile")
add_custom_command(OUTPUT ${BRIDGE_COMPILE}
  COMMAND ${CMAKE_CXX_COMPILER}
  ARGS ${CLANG_ARGS} ${INFILE} "-o" ${OBJFILE}
  DEPENDS ${INFILE}
  COMMENT "Compiling qir bridge"
  VERBATIM)

add_custom_target(qir_bridge_compile DEPENDS ${BRIDGE_COMPILE})

if (WIN32)
  set(QIR_BRIDGE_UTILITY_LIB "${PROJECT_BINARY_DIR}/lib/QIR/qir-bridge-u.lib")
else()
  set(QIR_BRIDGE_UTILITY_LIB "${PROJECT_BINARY_DIR}/lib/QIR/libqir-bridge-u.a")
endif()

add_custom_command(OUTPUT ${QIR_BRIDGE_UTILITY_LIB}
  COMMAND ${CMAKE_AR}
  ARGS "rc" ${QIR_BRIDGE_UTILITY_LIB} ${OBJFILE}
  DEPENDS qir_bridge_compile ${INFILE}
  COMMENT "Adding QIR bridge into a lib"
  VERBATIM)

add_custom_target(qir_bridge_u DEPENDS ${QIR_BRIDGE_UTILITY_LIB})

#===============================================================================
# Step 3: combine the utility lib and the support lib into a single static qir-rt
# library, the clients can link against.
#
add_library(qir-rt STATIC __dummy.cpp)

target_link_libraries(qir-rt PUBLIC
  ${QIR_BRIDGE_UTILITY_LIB}
  qir-rt-support
  ${CMAKE_DL_LIBS}
)
add_dependencies(qir-rt qir_bridge_u)




#+++++++++++++++++++++++++++++++++++++
# QIR_QIS
# (the same dance as for qir-rt)
#+++++++++++++++++++++++++++++++++++++

#===============================================================================
# Step 1: create qir-qis-support lib from the C++ sources
#
set(qis_sup_source_files
  "intrinsics.cpp"
)

add_library(qir-qis-support ${qis_sup_source_files})

target_include_directories(qir-qis-support PUBLIC ${public_includes})
produce_ir(qir-qis-support)

# Produce object lib we'll use to create a shared lib (so/dll) later on
add_library(qir-qis-support-obj OBJECT ${qis_sup_source_files})
target_include_directories(qir-qis-support-obj PUBLIC ${public_includes})
set_property(TARGET qir-qis-support-obj PROPERTY POSITION_INDEPENDENT_CODE ON)

#===============================================================================
# Step 2: create a utility lib from bridge-qis.ll
#

# compile into obj file
set(INFILE
  "${CMAKE_CURRENT_SOURCE_DIR}/bridge-qis.ll"
)
set(OBJFILE
  "${PROJECT_BINARY_DIR}/lib/QIR/bridge-qis.obj"
)

set(BRIDGE_QIS_COMPILE "bridge-qis-compile")
add_custom_command(OUTPUT ${BRIDGE_QIS_COMPILE}
  COMMAND ${CMAKE_CXX_COMPILER}
  ARGS ${CLANG_ARGS} ${INFILE} "-o" ${OBJFILE}
  DEPENDS ${INFILE}
  COMMENT "Compiling qir bridge for intrinsics"
  VERBATIM)

add_custom_target(qir_bridge_qis_compile DEPENDS ${BRIDGE_QIS_COMPILE})

if (WIN32)
  set(QIR_BRIDGE_QIS_UTILITY_LIB "${PROJECT_BINARY_DIR}/lib/QIR/qir-bridge-qis-u.lib" )
else()
  set(QIR_BRIDGE_QIS_UTILITY_LIB "${PROJECT_BINARY_DIR}/lib/QIR/libqir-bridge-qis-u.a")
endif()

add_custom_command(OUTPUT ${QIR_BRIDGE_QIS_UTILITY_LIB}
  COMMAND ${CMAKE_AR}
  ARGS "rc" ${QIR_BRIDGE_QIS_UTILITY_LIB} ${OBJFILE}
  DEPENDS qir_bridge_qis_compile ${INFILE}
  COMMENT "Adding QIR bridge for intrinsics into a lib"
  VERBATIM)

add_custom_target(qir_bridge_qis_u DEPENDS ${QIR_BRIDGE_QIS_UTILITY_LIB})

#===============================================================================
# Step 3: combine the utility lib and the support lib into a single static qir-qis
# library, the clients can link against.
#
add_library(qir-qis STATIC __dummy.cpp)

target_link_libraries(qir-qis PUBLIC
  ${QIR_BRIDGE_QIS_UTILITY_LIB}
  qir-qis-support
  ${CMAKE_DL_LIBS}
)

add_dependencies(qir-qis qir_bridge_qis_u)



