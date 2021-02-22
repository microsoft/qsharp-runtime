#===============================================================================
# Produce the qdk dynamic library
#
add_library(qdk SHARED
  qdk.cpp
  $<TARGET_OBJECTS:qir-rt-support-obj>
  $<TARGET_OBJECTS:qir-qis-support-obj>
  # NB: The following line includes all obj files from simulators, but does
  #     not include Rust dependencies. To get that, we need the opensim lib
  #     as well, built from corrosion in the Simulators subdirectory, above.
  $<TARGET_OBJECTS:simulators-obj>
)

target_link_libraries(qdk
  ${QIR_BRIDGE_UTILITY_LIB}
  ${QIR_BRIDGE_QIS_UTILITY_LIB}
  ${CMAKE_DL_LIBS}
  opensim
)

target_include_directories(qdk PUBLIC 
   ${public_includes}
)

set_property(TARGET qdk PROPERTY POSITION_INDEPENDENT_CODE ON)

install(TARGETS qdk
  RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin" 
  LIBRARY DESTINATION "${CMAKE_BINARY_DIR}/bin"
)


