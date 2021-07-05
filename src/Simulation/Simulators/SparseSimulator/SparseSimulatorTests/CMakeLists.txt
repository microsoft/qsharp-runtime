cmake_minimum_required(VERSION 3.10)
project(SparseQuantumSimulator)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

include(CTest)
enable_testing()

set(CMAKE_MACOSX_RPATH 1)
add_executable(SparseSimulatorTests SparseSimulatorTests.cpp)
add_test(SparseSimulatorTests SparseSimulatorTests)

#target_compile_options(SparseQuantumSimulator PUBLIC -fdeclspec)

#add_executable(SparseQuantumSimulatorExe SparseQuantumSimulator.cpp)
# target_include_directories(${EXE} PUBLIC ${OSSIM_INCLUDE_DIRS})
# target_link_libraries(${EXE} PRIVATE ${OPENMP_LINKER_FLAG})