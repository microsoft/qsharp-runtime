# compile test ll files into a library, have to use custom commands for this
set(CLANG_ARGS "-c")
if (CMAKE_BUILD_TYPE STREQUAL "Debug")
  set(CLANG_ARGS
    "${CLANG_ARGS}"
    "-O0"
    "-D_DEBUG"
  )
endif()

set(TEST_FILES
  vqe-with-params
)

foreach(file ${TEST_FILES})
  compile_from_qir(${file} "") # don't create a target per file
  list(APPEND QIR_TESTS_LIBS ${QIR_UTILITY_LIB})
endforeach()

add_custom_target(qir_exe_lib DEPENDS ${QIR_TESTS_LIBS})

#==============================================================================
# The executable target for QIR tests triggers the custom actions to compile ll files
#
add_executable(qir-exe
  main.cpp
)

target_link_libraries(qir-exe PUBLIC
  ${QIR_TESTS_LIBS}
  ${QIR_BRIDGE_UTILITY_LIB}
  ${QIR_BRIDGE_QIS_UTILITY_LIB}
  qir-rt-support
  qir-qis-support
  simulators
)

target_include_directories(qir-exe PUBLIC
  "${test_includes}"
  "${public_includes}"
  "${PROJECT_SOURCE_DIR}/lib/QIR"
)
add_dependencies(qir-exe qir_exe_lib)

install(TARGETS qir-exe RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin")

