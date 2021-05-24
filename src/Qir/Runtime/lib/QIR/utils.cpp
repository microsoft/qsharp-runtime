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

static std::unordered_set<char*>& UseMemoryTracker()
{
    static std::unordered_set<char*> memoryTracker;
    return memoryTracker;
}

extern "C"
{
    // Allocate a block of memory on the heap.
    char* quantum__rt__heap_alloc(uint64_t size) // NOLINT
    {
        char* buffer = new (std::nothrow) char[size];
        if(buffer == nullptr)
        {
            quantum__rt__fail(quantum__rt__string_create("Allocation Failed"));
        }
        #ifndef NDEBUG
            UseMemoryTracker().insert(buffer);
        #endif
        return buffer;
    }

    // Release a block of allocated heap memory.
    void quantum__rt__heap_free(char* buffer) // NOLINT
    {
        #ifndef NDEBUG
            auto iter = UseMemoryTracker().find(buffer);
            assert(iter != UseMemoryTracker().end());
            UseMemoryTracker().erase(iter);
        #endif
        delete[] buffer;
    }

    char* quantum__rt__memory_allocate(uint64_t size)
    {
        return (char *)malloc((size_t)size);
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