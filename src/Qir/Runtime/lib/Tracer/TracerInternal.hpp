// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
#ifndef TRACERINTERNAL_HPP
#define TRACERINTERNAL_HPP

#include <memory>
#include "tracer.hpp"

namespace Microsoft
{
namespace Quantum
{
    extern thread_local std::shared_ptr<CTracer> tracer;

} // namespace Quantum
} // namespace Microsoft

#endif // #ifndef TRACERINTERNAL_HPP
