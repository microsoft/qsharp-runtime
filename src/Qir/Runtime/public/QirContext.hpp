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

    struct QIR_SHARED_API QirExecutionContext
    {
        static void Init(IRuntimeDriver* simulator, bool trackAllocatedObjects = false);
        static void Deinit();

        QirExecutionContext(IRuntimeDriver* simulator, bool trackAllocatedObjects);
        ~QirExecutionContext();

        void OnAddRef(void* object);
        void OnRelease(void* object);
        void OnAllocate(void* object);

        IRuntimeDriver* GetDriver() const;

        struct QIR_SHARED_API Scoped
        {
            Scoped(IRuntimeDriver* sim, bool trackAllocatedObjects = false);
            ~Scoped();
        };

      private:
        IRuntimeDriver* driver = nullptr;
        bool trackAllocatedObjects = false;
        std::unique_ptr<AllocationsTracker> allocationsTracker;
    };
    
    QIR_SHARED_API std::unique_ptr<QirExecutionContext>& GlobalContext();

} // namespace Quantum
} // namespace Microsoft