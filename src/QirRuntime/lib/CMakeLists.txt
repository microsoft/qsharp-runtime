add_subdirectory(QIR)
add_subdirectory(Simulators)


#===============================================================================
# Produce the qdk dynamic library
#
add_library(qdk SHARED
    $<TARGET_OBJECTS:qir-rt-support-obj>
    $<TARGET_OBJECTS:qir-qis-support-obj>
    $<TARGET_OBJECTS:simulators-obj>
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


