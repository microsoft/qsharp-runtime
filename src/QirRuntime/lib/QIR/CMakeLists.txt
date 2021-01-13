#
# The bridge funtions calls into the rt so on Linux the dependency requires to
# introduce a new target that sits on top of both and links them in the correct
# order. This top target doesn't have any code of its own but CMake insists on
# providing a source file, thus __dummy.cpp...
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

# Produce object lib we'll use to create a shared lib (so/dll) later on
add_library(qir-rt-support-obj OBJECT ${rt_sup_source_files})
target_include_directories(qir-rt-support-obj PUBLIC ${public_includes})
set_property(TARGET qir-rt-support-obj PROPERTY POSITION_INDEPENDENT_CODE ON)

#===============================================================================
# Step 2: create a utility lib from bridge-rt.ll
#
set(bridge_rt_target "bridge_rt_target")
compile_from_qir(bridge-rt ${bridge_rt_target})

#===============================================================================
# Step 3: combine the utility lib and the support lib into a single static qir-rt
# library, the clients can link against.
#
add_library(qir-rt STATIC __dummy.cpp)

target_link_libraries(qir-rt PUBLIC
  ${QIR_UTILITY_LIB} # set in compile_from_qir
  qir-rt-support
  ${CMAKE_DL_LIBS}
)
add_dependencies(qir-rt ${bridge_rt_target})


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

# Produce object lib we'll use to create a shared lib (so/dll) later on
add_library(qir-qis-support-obj OBJECT ${qis_sup_source_files})
target_include_directories(qir-qis-support-obj PUBLIC ${public_includes})
set_property(TARGET qir-qis-support-obj PROPERTY POSITION_INDEPENDENT_CODE ON)

#===============================================================================
# Step 2: create a utility lib from bridge-qis.ll
#
set(bridge_qis_target "bridge_qis_target")
compile_from_qir(bridge-qis ${bridge_qis_target})

#===============================================================================
# Step 3: combine the utility lib and the support lib into a single static qir-qis
# library, the clients can link against.
#
add_library(qir-qis STATIC __dummy.cpp)

target_link_libraries(qir-qis PUBLIC
  ${QIR_UTILITY_LIB}  # set in compile_from_qir
  qir-qis-support
  ${CMAKE_DL_LIBS}
)

add_dependencies(qir-qis ${bridge_qis_target})



