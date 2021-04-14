set(source_files
  "FullstateSimulator.cpp"
  "setup.cpp"
  "ToffoliSimulator.cpp"
  "OpenSystemsSimulator.cpp"
)

set(includes
  "${public_includes}"
)

#===============================================================================
# Import Rust crates into CMake.

include(FetchContent)

FetchContent_Declare(
    Corrosion
    GIT_REPOSITORY https://github.com/AndrewGaspar/corrosion.git
    GIT_TAG origin/master # Optionally specify a version tag or branch here
)

FetchContent_MakeAvailable(Corrosion)
corrosion_import_crate(MANIFEST_PATH ../../../../Simulation/OpenSystems/runtime/Cargo.toml)

#===============================================================================
# Produce object lib we'll use to create a shared lib (so/dll) later on

add_library(simulators-obj OBJECT ${source_files})
target_include_directories(simulators-obj PUBLIC ${includes})
set_property(TARGET simulators-obj PROPERTY POSITION_INDEPENDENT_CODE ON)
target_compile_definitions(simulators-obj PRIVATE EXPORT_QIR_API)
