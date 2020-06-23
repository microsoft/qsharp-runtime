# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

# AVX
if (MSVC)
set(AVXFLAGS "/arch:AVX" )
set(AVX2FLAGS "/arch:AVX2" )
set(AVX512FLAGS "/arch:AVX512" )
set(FMAFLAGS "")
else(MSVC)
SET(AVXFLAGS "-mavx")
set(AVX2FLAGS "-mfma -mavx2")
set(AVX512FLAGS "-mfma -mavx512f -mavx512cd")
set(FMAFLAGS )
endif(MSVC)

configure_file(config.hpp.in ${PROJECT_BINARY_DIR}/src/config.hpp)
configure_file(version.hpp.in ${PROJECT_BINARY_DIR}/src/version.hpp)

add_subdirectory(util)
add_subdirectory(simulator)

set(SOURCES simulator/factory.cpp simulator/capi.cpp simulator/simulator.cpp util/openmp.cpp simulator/simulatoravx.cpp simulator/simulatoravx2.cpp simulator/simulatoravx512.cpp )
if(BUILD_SHARED_LIBS)
  add_library(Microsoft.Quantum.Simulator.Runtime SHARED ${SOURCES})
  set_source_files_properties(simulator/simulatoravx.cpp PROPERTIES COMPILE_FLAGS ${AVXFLAGS})
if (MSVC)
set_source_files_properties(simulator/simulatoravx2.cpp PROPERTIES COMPILE_FLAGS -mfma COMPILE_FLAGS ${AVX2FLAGS})
set_source_files_properties(simulator/simulatoravx512.cpp PROPERTIES COMPILE_FLAGS -mfma COMPILE_FLAGS ${AVX512FLAGS})
else(MSVC)
set_source_files_properties(simulator/simulatoravx2.cpp PROPERTIES COMPILE_FLAGS -mfma COMPILE_FLAGS ${AVX2FLAGS})
set_source_files_properties(simulator/simulatoravx512.cpp PROPERTIES COMPILE_FLAGS -mfma COMPILE_FLAGS ${AVX512FLAGS})
endif(MSVC)
  message (STATUS "Building shared library")
  target_compile_definitions(Microsoft.Quantum.Simulator.Runtime PRIVATE BUILD_DLL=1)
  set_target_properties(Microsoft.Quantum.Simulator.Runtime PROPERTIES POSITION_INDEPENDENT_CODE TRUE)
else(BUILD_SHARED_LIBS)
  message (STATUS "Building static library")
  add_library(Microsoft.Quantum.Simulator.Runtime STATIC ${SOURCES})
  set_source_files_properties(simulator/simulatoravx.cpp PROPERTIES COMPILE_FLAGS ${AVXFLAGS})
  set_source_files_properties(simulator/simulatoravx2.cpp PROPERTIES COMPILE_FLAGS ${AVX2FLAGS})
  set_source_files_properties(simulator/simulatoravx512.cpp PROPERTIES COMPILE_FLAGS ${AVX512FLAGS})
endif(BUILD_SHARED_LIBS)

install(TARGETS Microsoft.Quantum.Simulator.Runtime
        COMPONENT libraries
        RUNTIME DESTINATION bin
        ARCHIVE DESTINATION lib
        LIBRARY DESTINATION lib
       )
