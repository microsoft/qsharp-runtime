// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#pragma once

#include <memory>

namespace Microsoft
{
namespace Quantum
{
    struct ISimulator;
    void InitializeQirContext(ISimulator* sim, bool trackAllocatedObjects = false);
    void ReleaseQirContext();

    struct AllocationsTracker;
    struct QirExecutionContext
    {
        ISimulator* simulator;
        bool trackAllocatedObjects;
        std::unique_ptr<AllocationsTracker> allocationsTracker;

        QirExecutionContext(ISimulator* sim, bool trackAllocatedObjects);
        ~QirExecutionContext();
    };

    struct QirContextScope
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