cmake_minimum_required(VERSION 3.10)

# setthe project name and version
project(qtracer)

# specify the C++ standard, compiler and other tools
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED True)

if(LINUX)
    set(CMAKE_C_COMPILER             "/usr/bin/clang")
    set(CMAKE_CXX_COMPILER             "/usr/bin/clang++")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17 -stdlib=libc++ -lc++abi -fms-compatibility")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -ldl -fuse-ld=lld")
    set(CMAKE_AR      "/usr/bin/llvm-ar")
    set(CMAKE_LINKER  "/usr/bin/llvm-ld")
    set(CMAKE_NM      "/usr/bin/llvm-nm")
    set(CMAKE_OBJDUMP "/usr/bin/llvm-objdump")
    set(CMAKE_RANLIB  "/usr/bin/llvm-ranlib")
elseif(WIN32)
    set(CMAKE_AR      "llvm-ar.exe")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17")
endif()

set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG")

# feel free to customize these flags for your local builds (don't check in)
set(CMAKE_VERBOSE_MAKEFILE ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-inline")
#set(GENERATE_IR true)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

include(ProduceIR)

# Copy the fullstate native simulator library into the install locations where the tests will run from.
# TODO: replace with proper package handling
if (WIN32)
  set(QUANTUM_SIMULATOR "Microsoft.Quantum.Simulator.Runtime.dll" )
else()
  set(QUANTUM_SIMULATOR "libMicrosoft.Quantum.Simulator.Runtime.so")
endif()
configure_file(
  "${PROJECT_SOURCE_DIR}/externals/QuantumSimulator/${QUANTUM_SIMULATOR}" 
  "${CMAKE_BINARY_DIR}/bin/${QUANTUM_SIMULATOR}"
  COPYONLY
)

include(CTest)
macro(add_unit_test target)
    add_test(
        NAME ${target}
        COMMAND "${CMAKE_BINARY_DIR}/bin/${target}" -o "${CMAKE_BINARY_DIR}/bin/${target}_results.xml" -r junit)
    set_property(TEST ${target} PROPERTY ENVIRONMENT "LD_LIBRARY_PATH=${CMAKE_BINARY_DIR}/bin")
endmacro(add_unit_test)

set(public_includes "${PROJECT_SOURCE_DIR}/public")
set(test_includes   "${PROJECT_SOURCE_DIR}/externals/catch2")

add_subdirectory(experimental)
add_subdirectory(lib)
add_subdirectory(test)

