// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include <cstdint>
#include <memory>

#include "QirRuntimeApi_I.hpp"
#include "QubitManager.hpp"
#include "BasicRuntimeDriverFactory.h"

namespace Microsoft
{
namespace Quantum
{
    class CBasicRuntimeDriver : public IRuntimeDriver
    {
        std::unique_ptr<CQubitManager> qubitManager;

      public:
        CBasicRuntimeDriver()
        {
            qubitManager = std::make_unique<CQubitManager>();
        }

        ~CBasicRuntimeDriver() override
        {
        }

        std::string QubitToString(QubitIdType q) override
        {
            return std::to_string(q);
        }

        QubitIdType AllocateQubit() override
        {
            return qubitManager->Allocate();
        }

        void ReleaseQubit(QubitIdType q) override
        {
            qubitManager->Release(q);
        }

        void ReleaseResult(Result /* result */) override
        {
        }

        bool AreEqualResults(Result r1, Result r2) override
        {
            return r1 == r2;
        }

        ResultValue GetResultValue(Result r) override
        {
            return (r == UseZero()) ? Result_Zero : Result_One;
        }

        Result UseZero() override
        {
            return reinterpret_cast<Result>(0);
        }

        Result UseOne() override
        {
            return reinterpret_cast<Result>(1);
        }
    };

    extern "C" void* CreateBasicRuntimeDriver()
    {
        return (IRuntimeDriver*)new CBasicRuntimeDriver();
    }

} // namespace Quantum
} // namespace Microsoft
