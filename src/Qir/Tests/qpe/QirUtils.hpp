#ifndef QIRUTILS_HPP
#define QIRUTILS_HPP

#include <cstdint>

struct Array  // See https://github.com/microsoft/qsharp-runtime/issues/969.
{
    int64_t itemCount;
    void* buffer;
};

#endif
