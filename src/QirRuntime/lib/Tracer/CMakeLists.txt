set(component_name "tracer")

set(source_files
  "tracer.cpp"
)

set(includes
  "${public_includes}"
)


#===============================================================================
# Produce static lib for users to link directly to

add_library(${component_name} STATIC ${source_files})
target_include_directories(${component_name} PUBLIC ${includes})
target_link_libraries(${component_name} ${CMAKE_DL_LIBS})

#===============================================================================
# Produce object lib we'll use to create a shared lib (so/dll) later on

set(component_name_obj "${component_name}-obj")
add_library(${component_name_obj} OBJECT ${source_files})
target_include_directories(${component_name_obj} PUBLIC ${includes})
set_property(TARGET ${component_name_obj} PROPERTY POSITION_INDEPENDENT_CODE ON)
