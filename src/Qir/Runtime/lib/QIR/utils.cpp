// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include <cassert>
#include <stdexcept>
#include <memory>
#include <unordered_set>
#include <iostream>
#include <cstdint>
#include <cstdlib>

#include "QirTypes.hpp"
#include "QirRuntime.hpp"
#include "OutputStream.hpp"


extern "C"
{
    char* quantum__rt__memory_allocate(uint64_t size)
    {
        return (char*)malloc((size_t)size);
    }

    // Fail the computation with the given error message.
    void quantum__rt__fail(QirString* msg) // NOLINT
    {
        quantum__rt__fail_cstr(msg->str.c_str());
    }

    void quantum__rt__fail_cstr(const char* cstr)
    {
        Microsoft::Quantum::OutputStream::Get() << cstr << std::endl;
        Microsoft::Quantum::OutputStream::Get().flush();
        throw std::runtime_error(cstr);
    }
}
