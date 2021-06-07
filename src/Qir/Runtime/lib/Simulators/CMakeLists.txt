set(source_files
  "FullstateSimulator.cpp"
  "ToffoliSimulator.cpp"
)

set(includes
  "${public_includes}"
  "${PROJECT_SOURCE_DIR}/../../Simulation/Native/src"
  "${PROJECT_SOURCE_DIR}/../../Simulation/Native/src/simulator"
)

#===============================================================================
# Produce object lib we'll use to create a shared lib (so/dll) later on

add_library(simulators-obj OBJECT ${source_files})
target_include_directories(simulators-obj PUBLIC ${includes})
set_property(TARGET simulators-obj PROPERTY POSITION_INDEPENDENT_CODE ON)
target_compile_definitions(simulators-obj PRIVATE EXPORT_QIR_API)
