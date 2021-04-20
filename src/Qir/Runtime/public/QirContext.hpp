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

    // Deprecated: Use `QirExecutionContext::Init()` instead.
    QIR_SHARED_API void InitializeQirContext(IRuntimeDriver* driver, bool trackAllocatedObjects = false);
    // Deprecated: Use `QirExecutionContext::Deinit()` instead.
    QIR_SHARED_API void ReleaseQirContext();

    struct QIR_SHARED_API QirExecutionContext
    {
        // Direct access from outside of `QirExecutionContext` is deprecated: The variables are to become `private`. 
        // {
        // Use `Microsoft::Quantum::GlobalContext()->GetDriver()` instead:
        IRuntimeDriver* driver = nullptr;
        // Use `QirExecutionContext::{OnAddRef(), OnRelease(), OnAllocate()}`instead of direct access:
        bool trackAllocatedObjects = false;
        std::unique_ptr<AllocationsTracker> allocationsTracker;
        // }

        static void Init(IRuntimeDriver* simulator, bool trackAllocatedObjects = false);
        static void Deinit();

        QirExecutionContext(IRuntimeDriver* sim, bool trackAllocatedObjects);
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
    };
    
    // Direct access is deprecated, use GlobalContext() instead.
    extern std::unique_ptr<QirExecutionContext> g_context;  
    extern QIR_SHARED_API std::unique_ptr<QirExecutionContext>& GlobalContext();

    // Deprecated, use `QirExecutionContext::Scoped` instead.
    struct QIR_SHARED_API QirContextScope
    {
        QirContextScope(IRuntimeDriver* sim, bool trackAllocatedObjects = false);
        ~QirContextScope();
    };
} // namespace Quantum
} // namespace Microsoft