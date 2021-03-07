// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#pragma once

#include <memory>

#include "CoreTypes.hpp"

namespace Microsoft
{
namespace Quantum
{
    struct ISimulator;
    void InitializeQirContext(ISimulator* sim, bool trackAllocatedObjects = false);
    void ReleaseQirContext();

    struct AllocationsTracker;
    struct QIR_SHARED_API QirExecutionContext
    {
        ISimulator* simulator = nullptr;
        bool trackAllocatedObjects = false;
        std::unique_ptr<AllocationsTracker> allocationsTracker;

        QirExecutionContext(ISimulator* sim, bool trackAllocatedObjects);
        ~QirExecutionContext();
    };
    extern QIR_SHARED_API thread_local std::unique_ptr<QirExecutionContext> g_context;

    struct QIR_SHARED_API QirContextScope
    {
        QirContextScope(ISimulator* sim, bool trackAllocatedObjects = false)
        {
            InitializeQirContext(sim, trackAllocatedObjects);
        }
        ~QirContextScope()
        {
            ReleaseQirContext();
        }
    };
} // namespace Quantum
} // namespace Microsoft