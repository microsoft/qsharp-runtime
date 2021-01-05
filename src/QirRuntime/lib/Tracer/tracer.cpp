// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include <assert.h>

#include "tracer.hpp"

namespace Microsoft
{
namespace Quantum
{
    thread_local std::shared_ptr<CTracer> tracer = nullptr;
    std::shared_ptr<CTracer> CreateTracer()
    {
        tracer = std::make_shared<CTracer>();
        return tracer;
    }

    std::unique_ptr<ISimulator> CreateFullstateSimulator()
    {
        throw std::logic_error("Tracer should not instantiate full state simulator");
    }
} // namespace Quantum
} // namespace Microsoft