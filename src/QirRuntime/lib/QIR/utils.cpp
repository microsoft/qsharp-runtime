#include <assert.h>
#include <stdexcept>
#include <memory>
#include <unordered_set>
#include <iostream>

#include "__quantum__rt.hpp"

#include "qirTypes.hpp"

std::unordered_set<char*>& UseMemoryTracker()
{
    static std::unordered_set<char*> memoryTracker;
    return memoryTracker;
}

extern "C"
{
    // Allocate a block of memory on the heap.
    char* quantum__rt__heap_alloc(int size) // NOLINT
    {
        char* buffer = new char[size];
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

    // Fail the computation with the given error message.
    void quantum__rt__fail(QirString* msg) // NOLINT
    {
        std::string str = msg->str;
        quantum__rt__string_unreference(msg);
        throw std::runtime_error(str);
    }

    // Include the given message in the computation's execution log or equivalent.
    // TODO: should we allow the user to register their own output?
    void quantum__rt__message(QirString* msg) // NOLINT
    {
        std::cout << msg->str;
    }
}