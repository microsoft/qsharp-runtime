# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

# AVX
set(AVXFLAGS "-mavx")
set(AVX2FLAGS "-mfma -mavx2")
set(AVX512FLAGS "-mfma -mavx512f -mavx512cd")
set(FMAFLAGS )

configure_file(config.hpp.in ${PROJECT_BINARY_DIR}/src/config.hpp)
configure_file(version.hpp.in ${PROJECT_BINARY_DIR}/src/version.hpp)

add_subdirectory(util)
add_subdirectory(simulator)

set(SOURCES simulator/factory.cpp simulator/capi.cpp simulator/simulator.cpp util/openmp.cpp simulator/simulatoravx.cpp simulator/simulatoravx2.cpp simulator/simulatoravx512.cpp simulator/qir.cpp)
if(BUILD_SHARED_LIBS)
  add_library(Microsoft.Quantum.Simulator.Runtime SHARED ${SOURCES})
  set_source_files_properties(simulator/capi.cpp PROPERTIES COMPILE_FLAGS ${AVXFLAGS})
  set_source_files_properties(simulator/simulator.cpp PROPERTIES COMPILE_FLAGS ${AVXFLAGS})
  set_source_files_properties(simulator/simulatoravx.cpp PROPERTIES COMPILE_FLAGS ${AVXFLAGS})
  set_source_files_properties(simulator/simulatoravx2.cpp PROPERTIES COMPILE_FLAGS -mfma COMPILE_FLAGS ${AVX2FLAGS})
  set_source_files_properties(simulator/simulatoravx512.cpp PROPERTIES COMPILE_FLAGS -mfma COMPILE_FLAGS ${AVX512FLAGS})
  message (STATUS "Building shared library")
  target_compile_definitions(Microsoft.Quantum.Simulator.Runtime PRIVATE BUILD_DLL=1)
  set_target_properties(Microsoft.Quantum.Simulator.Runtime PROPERTIES POSITION_INDEPENDENT_CODE TRUE)
else(BUILD_SHARED_LIBS)
  message (STATUS "Building static library")
  add_library(Microsoft.Quantum.Simulator.Runtime STATIC ${SOURCES})
  set_source_files_properties(simulator/capi.cpp PROPERTIES COMPILE_FLAGS ${AVXFLAGS})
  set_source_files_properties(simulator/simulator.cpp PROPERTIES COMPILE_FLAGS ${AVXFLAGS})
  set_source_files_properties(simulator/simulatoravx.cpp PROPERTIES COMPILE_FLAGS ${AVXFLAGS})
  set_source_files_properties(simulator/simulatoravx2.cpp PROPERTIES COMPILE_FLAGS ${AVX2FLAGS})
  set_source_files_properties(simulator/simulatoravx512.cpp PROPERTIES COMPILE_FLAGS ${AVX512FLAGS})
endif(BUILD_SHARED_LIBS)

target_include_directories(Microsoft.Quantum.Simulator.Runtime PRIVATE "${PROJECT_BINARY_DIR}/../../../Qir/drops/include")
target_link_libraries(Microsoft.Quantum.Simulator.Runtime 
  ${SPECTRE_LIBS}
  "-L${PROJECT_BINARY_DIR}/../../../Qir/drops/bin/$ENV{BUILD_PLATFORM}/native"
  -lqir_runtime
)

if (WIN32)
  target_link_libraries(Microsoft.Quantum.Simulator.Runtime
    Ws2_32
    Bcrypt
    Userenv
  )
  target_sources(Microsoft.Quantum.Simulator.Runtime PUBLIC "${PROJECT_BINARY_DIR}/../../../Qir/drops/include/qir_runtime.def")
else()
  target_link_libraries(Microsoft.Quantum.Simulator.Runtime
    pthread
  )
endif()

install(TARGETS Microsoft.Quantum.Simulator.Runtime
        RUNTIME DESTINATION "${CMAKE_BINARY_DIR}/drop"
        LIBRARY DESTINATION "${CMAKE_BINARY_DIR}/drop"
        ARCHIVE DESTINATION "${CMAKE_BINARY_DIR}/drop"
       )
