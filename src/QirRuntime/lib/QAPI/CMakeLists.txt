
set(component_name "qapi")

set(source_files
  "QAPI.cpp"
)

set(includes
  "${public_includes}"
  "${PROJECT_SOURCE_DIR}/lib/QIR"
)

#===============================================================================
# Produce static lib for users to link directly to
#
add_library(${component_name} STATIC ${source_files})
target_include_directories(${component_name} PUBLIC ${includes})


#===============================================================================
# Produce object lib we'll use to create a shared lib (so/dll) later on
#
set(component_name_obj "${component_name}-obj")
add_library(${component_name_obj} OBJECT ${source_files})
target_include_directories(${component_name_obj} PUBLIC ${includes})
set_property(TARGET ${component_name_obj} PROPERTY POSITION_INDEPENDENT_CODE ON)


#===============================================================================
# Produce the dynamic library
#
add_library(qdk SHARED
    $<TARGET_OBJECTS:qapi-obj>
    $<TARGET_OBJECTS:simulators-obj>
    $<TARGET_OBJECTS:core-obj>
    $<TARGET_OBJECTS:qir-rt-support-obj>
    $<TARGET_OBJECTS:qir-qis-support-obj>
)

if (WIN32)
  set(QIR_BRIDGE_UTILITY_LIB "${PROJECT_BINARY_DIR}/lib/QIR/qir-bridge-u.lib")
  set(QIR_BRIDGE_QIS_UTILITY_LIB "${PROJECT_BINARY_DIR}/lib/QIR/qir-bridge-qis-u.lib")
else()
  set(QIR_BRIDGE_UTILITY_LIB "${PROJECT_BINARY_DIR}/lib/QIR/libqir-bridge-u.a")
  set(QIR_BRIDGE_QIS_UTILITY_LIB "${PROJECT_BINARY_DIR}/lib/QIR/libqir-bridge-qis-u.a")
endif()

target_link_libraries(qdk
  ${QIR_BRIDGE_UTILITY_LIB}
  ${QIR_BRIDGE_QIS_UTILITY_LIB}
  ${CMAKE_DL_LIBS}
)

set_property(TARGET qdk PROPERTY POSITION_INDEPENDENT_CODE ON)

install(TARGETS qdk
  RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin" 
  LIBRARY DESTINATION "${CMAKE_BINARY_DIR}/bin"
)

