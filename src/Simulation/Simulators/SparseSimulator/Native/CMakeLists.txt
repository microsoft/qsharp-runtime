cmake_minimum_required(VERSION 3.10)
project(SparseQuantumSimulator)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_MACOSX_RPATH 1)
# Main build files
add_library(SparseQuantumSimulator SHARED factory.cpp capi.cpp)

# Set OpenMP if it is available
find_package(OpenMP REQUIRED)
if(OpenMP_CXX_FOUND)
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}")
	set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${OpenMP_EXE_LINKER_FLAGS}")
	if (OpenMP_CXX_VERSION_MAJOR GREATER_EQUAL 3)
		target_compile_definitions(SparseQuantumSimulator PRIVATE DOMP_GE_V3=1)
	endif()
endif()

# Windows adds a special dllexport command which must be defined
if (WIN32)
	target_compile_options(SparseQuantumSimulator PUBLIC -fdeclspec)
	target_compile_definitions(SparseQuantumSimulator PRIVATE BUILD_DLL=1)
endif()
# Try to optimize with gcc
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
	target_compile_options(SparseQuantumSimulator PUBLIC -O3 -ftree-vectorize -mavx2 -mfma -fopenmp)
endif()

message("Compiler flags: ${CMAKE_CXX_FLAGS_RELEASE}")
