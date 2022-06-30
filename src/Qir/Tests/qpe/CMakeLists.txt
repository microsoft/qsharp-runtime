cmake_minimum_required(VERSION 3.1)
set(CMAKE_CXX_STANDARD 17)

set(CMAKE_VERBOSE_MAKEFILE ON)
#set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -O0 -g")
#set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG -O0 -g")
#set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG -Og -g")
#set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG -Og -ggdb")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG -Og -ggdb3")
#set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG -Og -gdwarf")   # Does not show `main()`
#set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG -Og -gstabs")  # Unsupported   `-gstabs[+]`
#set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG -Og -gxcoff")   # Unsupported



project(qpe_invoker)

set(JSON_Install OFF CACHE INTERNAL "")
add_subdirectory(nlohmann_json)
# find_package(nlohmann_json 3.10.5 REQUIRED)

add_executable(qpe
#  QIR_dummy.cpp
  IBMQ_qis.cpp

  JW_QIR.cpp
  JW_json.cpp
  main.cpp
)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/../../Common/cmake")     # qir_cmake_include.cmake
include(qir_cmake_include)  # target_source_from_qir
set(TEST_FILES
  #est-energy.qat.dbginfo.ll

  #est-energy.IBMQ.ll
    # Removed `internal`.
    # After fix of ApplyUncontrolledRx.qs ApplyUncontrolledRy.qs

  est-energy.IBMQ.dbginfo.ll
    # Removed `internal`.
    # After fix of ApplyUncontrolledRx.qs ApplyUncontrolledRy.qs.

  #est-energy.ll
)
foreach(file ${TEST_FILES})
  target_source_from_qir(qpe ${file})      #qir-static-tests ${file})
endforeach()


target_link_libraries(qpe PRIVATE nlohmann_json::nlohmann_json)

set(runtime_lib_path "${PROJECT_SOURCE_DIR}/../../Runtime/bin/$ENV{BUILD_CONFIGURATION}/bin")   # Microsoft.Quantum.Qir.Runtime DLL
if (${CMAKE_SYSTEM_NAME} MATCHES "Windows")
target_link_libraries(qpe PUBLIC
  "-L${runtime_lib_path}"
  -lMicrosoft.Quantum.Qir.Runtime
  -lMicrosoft.Quantum.Qir.QSharp.Foundation
  -lMicrosoft.Quantum.Qir.QSharp.Core
  -llibcmt
)
else()
target_link_libraries(qpe PUBLIC
  "-L${runtime_lib_path}"
  -lMicrosoft.Quantum.Qir.Runtime
  -lMicrosoft.Quantum.Qir.QSharp.Foundation
  -lMicrosoft.Quantum.Qir.QSharp.Core
)
endif()

set(public_includes "${PROJECT_SOURCE_DIR}/../../Runtime/public")
set(QSharpCore_includes "${PROJECT_SOURCE_DIR}/../../Runtime/lib/QSharpCore")
target_include_directories(qpe PUBLIC
 #${test_includes}
 #${common_includes}
 ${public_includes}
 ${QSharpCore_includes}
)
