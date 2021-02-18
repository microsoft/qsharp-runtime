// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include <cassert>

#include "QirContext.hpp"

#include "CoreTypes.hpp"
#include "QuantumApi_I.hpp"
#include "allocationsTracker.hpp"

#ifdef _WIN32
#define QIR_SHARED_API __declspec(dllexport)
#else
#define QIR_SHARED_API
#endif

extern "C" QIR_SHARED_API Result ResultOne = nullptr;
extern "C" QIR_SHARED_API Result ResultZero = nullptr;
namespace Microsoft
{
namespace Quantum
{
    thread_local std::unique_ptr<QirExecutionContext> g_context = nullptr;
    void InitializeQirContext(ISimulator* sim, bool trackAllocatedObjects)
    {
        assert(g_context == nullptr);
        g_context = std::make_unique<QirExecutionContext>(sim, trackAllocatedObjects);

        if (g_context->simulator != nullptr)
        {
            ResultOne = g_context->simulator->UseOne();
            ResultZero = g_context->simulator->UseZero();
        }
        else
        {
            ResultOne = nullptr;
            ResultZero = nullptr;
        }
    }

    void ReleaseQirContext()
    {
        assert(g_context != nullptr);

        if (g_context->trackAllocatedObjects)
        {
            g_context->allocationsTracker->CheckForLeaks();
        }

        ResultOne = nullptr;
        ResultZero = nullptr;
        g_context.reset(nullptr);
    }

    QirExecutionContext::QirExecutionContext(ISimulator* sim, bool trackAllocatedObjects)
        : simulator(sim)
        , trackAllocatedObjects(trackAllocatedObjects)
    {
        if (this->trackAllocatedObjects)
        {
            this->allocationsTracker = std::make_unique<AllocationsTracker>();
        }
    }
    QirExecutionContext::~QirExecutionContext() = default;

} // namespace Quantum
} // namespace Microsoft