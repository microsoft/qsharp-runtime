// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include <cassert>

#include "QirContext.hpp"

#include "CoreTypes.hpp"
#include "QirRuntimeApi_I.hpp"
#include "allocationsTracker.hpp"

namespace Microsoft
{
namespace Quantum
{
    std::unique_ptr<QirExecutionContext> g_context = nullptr;
    std::unique_ptr<QirExecutionContext>& GlobalContext() { return g_context; }

    void InitializeQirContext(IRuntimeDriver* driver, bool trackAllocatedObjects)
    {
        assert(g_context == nullptr);
        g_context = std::make_unique<QirExecutionContext>(driver, trackAllocatedObjects);
    }

    void ReleaseQirContext()
    {
        assert(g_context != nullptr);

        if (g_context->trackAllocatedObjects)
        {
            g_context->allocationsTracker->CheckForLeaks();
        }

        g_context.reset(nullptr);
    }

    QirExecutionContext::QirExecutionContext(IRuntimeDriver* drv, bool trackAllocatedObj)
        : driver(drv)
        , trackAllocatedObjects(trackAllocatedObj)
    {
        if (this->trackAllocatedObjects)
        {
            this->allocationsTracker = std::make_unique<AllocationsTracker>();
        }
    }

    // If we just remove this user-declared-and-defined dtor 
    // then it will be automatically defined together with the class definition,
    // which will require the `AllocationsTracker` to be a complete type 
    // everywhere where `public/QirContext.hpp` is included 
    // (we'll have to move `allocationsTracker.hpp` to `public/`).
    QirExecutionContext::~QirExecutionContext() = default;

    void QirExecutionContext::Init(IRuntimeDriver* driver, bool trackAllocatedObjects /*= false*/)
    {
        assert(GlobalContext() == nullptr);
        GlobalContext() = std::make_unique<QirExecutionContext>(driver, trackAllocatedObjects);
    }

    void QirExecutionContext::Deinit()
    {
        assert(GlobalContext() != nullptr);

        if (GlobalContext()->trackAllocatedObjects)
        {
            GlobalContext()->allocationsTracker->CheckForLeaks();
        }

        GlobalContext().reset(nullptr);
    }

    void QirExecutionContext::OnAddRef(void* object)
    {
        if(trackAllocatedObjects)
        {
            this->allocationsTracker->OnAddRef(object);
        }
    }

    void QirExecutionContext::OnRelease(void* object)
    {
        if(this->trackAllocatedObjects)
        {
            this->allocationsTracker->OnRelease(object);
        }
    }

    void QirExecutionContext::OnAllocate(void* object)
    {
        if(this->trackAllocatedObjects)
        {
            this->allocationsTracker->OnAllocate(object);
        }
    }

    IRuntimeDriver* QirExecutionContext::GetDriver() const
    {
        return this->driver;
    }

    QirExecutionContext::Scoped::Scoped(IRuntimeDriver* drv, bool trackAllocatedObj /*= false*/)
    {
        QirExecutionContext::Init(drv, trackAllocatedObj);
    }

    QirExecutionContext::Scoped::~Scoped()
    {
        QirExecutionContext::Deinit();
    }

    QirContextScope::QirContextScope(IRuntimeDriver* driver, bool trackAllocatedObj /*= false*/)
    {
        InitializeQirContext(driver, trackAllocatedObj);
    }
    
    QirContextScope::~QirContextScope()
    {
        ReleaseQirContext();
    }

} // namespace Quantum
} // namespace Microsoft