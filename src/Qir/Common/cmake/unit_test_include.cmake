include(CTest)
macro(add_unit_test target)
    add_test(
        NAME ${target}
        COMMAND ${target} ~[skip] -o "${target}_results.xml" -r junit
    )

    # set the environment path for loading shared libs the tests are using
    if(DEFINED ENV{NATIVE_SIMULATOR})
        set(TEST_DEPS1 $ENV{NATIVE_SIMULATOR})
    else()
        set(TEST_DEPS1 "${PROJECT_SOURCE_DIR}/../../Simulation/native/build/$ENV{BUILD_CONFIGURATION}")
    endif()

    set(TEST_DEPS2 "${CMAKE_BINARY_DIR}/bin")
    set(TEST_DEPS3 "${PROJECT_SOURCE_DIR}/../Runtime/bin/$ENV{BUILD_CONFIGURATION}/bin")
    set_property(TEST ${target} PROPERTY ENVIRONMENT
        "LD_LIBRARY_PATH=${TEST_DEPS1}:${TEST_DEPS2}:${TEST_DEPS3}:${LD_LIBRARY_PATH}"
        "PATH=${TEST_DEPS1}\;${TEST_DEPS2}\;${TEST_DEPS3}\;${PATH}"
        "DYLD_LIBRARY_PATH=${TEST_DEPS1}:${TEST_DEPS2}:${TEST_DEPS3}:${DYLD_LIBRARY_PATH}"
    )
endmacro(add_unit_test)
