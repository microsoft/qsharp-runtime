// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include <cassert>

#include "QirContext.hpp"
#include "QirContext.h"

#include "CoreTypes.hpp"
#include "QirRuntimeApi_I.hpp"

namespace Microsoft
{
namespace Quantum
{
    std::unique_ptr<QirExecutionContext> g_context = nullptr;
    std::unique_ptr<QirExecutionContext>& GlobalContext()
    {
        return g_context;
    }

    void InitializeQirContext(IRuntimeDriver* driver, bool /*trackAllocatedObjects*/)
    {
        assert(g_context == nullptr);
        g_context = std::make_unique<QirExecutionContext>(driver);
    }

    extern "C" void InitializeQirContext(void* driver, bool /*trackAllocatedObjects*/)
    {
        InitializeQirContext((IRuntimeDriver*)driver);
    }

    void ReleaseQirContext()
    {
        assert(g_context != nullptr);

        g_context.reset(nullptr);
    }

    QirExecutionContext::QirExecutionContext(IRuntimeDriver* drv, bool /*trackAllocatedObj*/) : driver(drv)
    {
    }

    void QirExecutionContext::Init(IRuntimeDriver* driver, bool /*trackAllocatedObjects*/)
    {
        assert(GlobalContext() == nullptr);
        GlobalContext() = std::make_unique<QirExecutionContext>(driver);
    }

    void QirExecutionContext::Deinit()
    {
        assert(GlobalContext() != nullptr);

        GlobalContext().reset(nullptr);
    }

    IRuntimeDriver* QirExecutionContext::GetDriver() const
    {
        return this->driver;
    }

    QirExecutionContext::Scoped::Scoped(IRuntimeDriver* drv, bool /*trackAllocatedObj*/)
    {
        QirExecutionContext::Init(drv);
    }

    QirExecutionContext::Scoped::~Scoped()
    {
        QirExecutionContext::Deinit();
    }

    QirContextScope::QirContextScope(IRuntimeDriver* driver, bool /*trackAllocatedObj*/)
    {
        InitializeQirContext(driver);
    }

    QirContextScope::~QirContextScope()
    {
        ReleaseQirContext();
    }

} // namespace Quantum
} // namespace Microsoft
