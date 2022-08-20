#===============================================================================
# Produce the qir_range_support dynamic library
#
add_library(qir_range_support SHARED bridge-rt.cpp)

target_source_from_qir(qir_range_support bridge-rt.ll)

target_link_libraries(qir_range_support
  ${CMAKE_DL_LIBS}
  "-L${CMAKE_BINARY_DIR}/bin"
  -lqir_runtime
  ${SPECTRE_LIBS}
)

target_include_directories(qir_range_support PUBLIC 
  ${public_includes}
  ${common_includes}
)

set_property(TARGET qir_range_support PROPERTY POSITION_INDEPENDENT_CODE ON)

install(TARGETS qir_range_support
  RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin"
  LIBRARY DESTINATION "${CMAKE_BINARY_DIR}/bin"
  ARCHIVE DESTINATION "${CMAKE_BINARY_DIR}/bin"
)
