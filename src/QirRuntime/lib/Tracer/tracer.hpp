// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include <memory>

#include "CoreTypes.hpp"

// The tracer does _not_ implement ISimulator interface by design to avoid virtual calls and enable as many compiler
// optimizations (inlining, etc.) as possible.
class CTracer
{
    // Start with no reuse of qubits.
    long lastQubitId = -1;

  public:
    Qubit AllocateQubit();
    void ReleaseQubit(Qubit q);

    template<int N> void TraceSingleQubitOp(int32_t duration, Qubit target)
    {
        // figure out the layering, etc.
    }
};

thread_local std::shared_ptr<CTracer> tracer = nullptr;
void InitializeTracer();