set(component_name "simulators")

set(source_files
  "FullstateSimulator.cpp"
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

corrosion_import_crate(MANIFEST_PATH opensim/Cargo.toml)

#===============================================================================
# Produce static lib for users to link directly to

add_library(${component_name} STATIC ${source_files})
target_include_directories(${component_name} PUBLIC ${includes})
target_link_libraries(${component_name} ${CMAKE_DL_LIBS} PUBLIC opensim_static)

#===============================================================================
# Produce object lib we'll use to create a shared lib (so/dll) later on

set(component_name_obj "${component_name}-obj")
add_library(${component_name_obj} OBJECT ${source_files})
target_include_directories(${component_name_obj} PUBLIC ${includes})
set_property(TARGET ${component_name_obj} PROPERTY POSITION_INDEPENDENT_CODE ON)
