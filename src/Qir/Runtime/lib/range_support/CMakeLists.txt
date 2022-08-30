#===============================================================================
# Produce the qir_range_support dynamic library
#
add_library(qir_range_support SHARED bridge-rt.cpp)

target_source_from_qir(qir_range_support bridge-rt.ll)

set(QIR_LIB_PATH "${CMAKE_SOURCE_DIR}/../drops/bin/$ENV{BUILD_PLATFORM}/native")

target_link_libraries(qir_range_support
  ${CMAKE_DL_LIBS}
  "-L${QIR_LIB_PATH}"
  -lqir_sim
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