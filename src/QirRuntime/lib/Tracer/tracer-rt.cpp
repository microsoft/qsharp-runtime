// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include <assert.h>

#include "tracer.hpp"
#include "qirTypes.hpp"

extern "C"
{
    Result UseZero()
    {
        return reinterpret_cast<Result>(0);
    }

    Result UseOne()
    {
        return reinterpret_cast<Result>(1);
    }

    QUBIT* quantum__rt__qubit_allocate() // NOLINT
    {
        return nullptr;
    }

    void quantum__rt__qubit_release(QUBIT* qubit) // NOLINT
    {
    }

    void quantum__rt__result_reference(RESULT* r) // NOLINT
    {
    }

    void quantum__rt__result_unreference(RESULT* r) // NOLINT
    {
    }

    bool quantum__rt__result_equal(RESULT* r1, RESULT* r2) // NOLINT
    {
        return false;
    }

    QirString* quantum__rt__result_to_string(RESULT* result) // NOLINT
    {
        return nullptr;
    }

    QirString* quantum__rt__qubit_to_string(QUBIT* qubit) // NOLINT
    {
        return nullptr;
    }
}