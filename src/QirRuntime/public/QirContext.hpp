// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#pragma once

#include <memory>

#include "CoreTypes.hpp"

namespace Microsoft
{
namespace Quantum
{
    struct IRuntimeDriver;
    struct AllocationsTracker;

    QIR_SHARED_API void InitializeQirContext(IRuntimeDriver* driver, bool trackAllocatedObjects = false);
    QIR_SHARED_API void ReleaseQirContext();
    struct QIR_SHARED_API QirExecutionContext
    {
        IRuntimeDriver* driver = nullptr;
        bool trackAllocatedObjects = false;
        std::unique_ptr<AllocationsTracker> allocationsTracker;

        QirExecutionContext(IRuntimeDriver* sim, bool trackAllocatedObjects);
        ~QirExecutionContext();
    };
    extern thread_local std::unique_ptr<QirExecutionContext> g_context;
    extern QIR_SHARED_API std::unique_ptr<QirExecutionContext>& GlobalContext();

    struct QIR_SHARED_API QirContextScope
    {
        QirContextScope(IRuntimeDriver* sim, bool trackAllocatedObjects = false)
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