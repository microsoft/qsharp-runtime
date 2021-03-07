set(source_files
  "FullstateSimulator.cpp"
  "setup.cpp"
  "ToffoliSimulator.cpp"
)

set(includes
  "${public_includes}"
)


#===============================================================================
# Produce static lib for users to link directly to

add_library(simulators STATIC ${source_files})
target_include_directories(simulators PUBLIC ${includes})
target_link_libraries(simulators ${CMAKE_DL_LIBS})

#===============================================================================
# Produce object lib we'll use to create a shared lib (so/dll) later on

add_library(simulators-obj OBJECT ${source_files})
target_include_directories(simulators-obj PUBLIC ${includes})
set_property(TARGET simulators-obj PROPERTY POSITION_INDEPENDENT_CODE ON)
