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
  "allocationsTracker.cpp"
  "arrays.cpp"
  "callables.cpp"
  "context.cpp"
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

add_dependencies(qir-rt-support ${bridge_rt_target})

#+++++++++++++++++++++++++++++++++++++
# qir-qis
#+++++++++++++++++++++++++++++++++++++

#===============================================================================
# create a utility lib from bridge-qis.ll
#
set(bridge_qis_target "bridge_qis_target")
compile_from_qir(bridge-qis ${bridge_qis_target})

#===============================================================================
# create qir-qis-support lib from the C++ sources
#
set(qis_sup_source_files
  conditionals.cpp
  intrinsics.cpp
  intrinsicsMath.cpp
  intrinsicsOut.cpp
  intrinsicsFormat.cpp
)

add_library(qir-qis-support ${qis_sup_source_files})

target_include_directories(qir-qis-support PUBLIC ${public_includes} ${externals_includes})

# Produce object lib we'll use to create a shared lib (so/dll) later on
add_library(qir-qis-support-obj OBJECT ${qis_sup_source_files})
target_include_directories(qir-qis-support-obj PUBLIC ${public_includes} ${externals_includes})
set_property(TARGET qir-qis-support-obj PROPERTY POSITION_INDEPENDENT_CODE ON)

add_dependencies(qir-qis-support ${bridge_qis_target})



