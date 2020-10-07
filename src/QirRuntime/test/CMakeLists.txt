set(test_includes "${PROJECT_SOURCE_DIR}/test")

add_subdirectory(QIR-dynamic)
add_subdirectory(QIR-static)
add_subdirectory(unittests)
# `interop` folder is built using dotnet