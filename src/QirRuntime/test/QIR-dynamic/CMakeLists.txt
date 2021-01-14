# compile test ll files into a library, have to use custom commands for this
set(CLANG_ARGS "-c")
if (CMAKE_BUILD_TYPE STREQUAL "Debug")
  set(CLANG_ARGS
    "${CLANG_ARGS}"
    "-O0"
    "-D_DEBUG"
  )
endif()

if (WIN32)
  set(TEST_FILES
    qir-test-random-win
  )
else()
  set(TEST_FILES
    qir-test-random-lnx
  )
endif()

foreach(file ${TEST_FILES})
  compile_from_qir(${file} "") # don't create a target per file
  list(APPEND QIR_TESTS_LIBS ${QIR_UTILITY_LIB})
endforeach()

add_custom_target(qir_dynamic_test_lib DEPENDS ${QIR_TESTS_LIBS})

#==============================================================================
# This executable target links test code against the dynamic QDK library rather than the explicit
# static QIR/RT libs (qdk will statically link in the bridge via transitivity of target_link_libraries).
#
add_executable(qir-dynamic-tests
  qir-driver.cpp
)

target_link_libraries(qir-dynamic-tests PUBLIC
  ${QIR_TESTS_LIBS}
  qdk
)

target_include_directories(qir-dynamic-tests PUBLIC
  ${test_includes}
  ${public_includes}
)
add_dependencies(qir-dynamic-tests qir_dynamic_test_lib)

install(TARGETS qir-dynamic-tests RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/bin")
add_unit_test(qir-dynamic-tests)
