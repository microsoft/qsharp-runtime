// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#pragma once

#include <memory>
#include <vector>

#include "IQuantumApi.hpp"
#include "ITranslator.hpp"
#include "QAPI.hpp"

namespace Microsoft
{
namespace Quantum
{
    // Lockstep simulator executes the provided simulators "in lockstep", one operation
    // at a time. The result value buffer should be allocated by the caller and would contain
    // result values from each simulator after calling `GetResultValue` on a result, that
    // represents a cumulative result of a measurement. If the buffer isn't provided (is null),
    // the individual result values aren't communicated back to the caller.
    std::unique_ptr<IQuantumApi> CreateLockstepSimulator(
        std::vector<IQuantumApi*>&& simulatorsToRunInLockstep,
        ResultValue* resultValuesBuffer /*size of the buffer must be equal the number of simulators*/);

    // The circuit to json translator traces the quantum program and generates json that describes the program.
    std::shared_ptr<ITranslator> CreateCircuitToJsonTranslator();
    std::unique_ptr<IQuantumApi> CreateCircuitPrintingSimulator(std::shared_ptr<ITranslator> translator);
    std::unique_ptr<IQuantumApi> CreateSampleDecomposer(IQuantumApi* owner);

    // Tracing simulator is effectively a translator: it traces the quantum program to collect
    // statistics about it, and returns the representation of the statistics.
    enum OptimizeFor
    {
        OptimizeFor_QubitWidth = 0,
        OptimizeFor_CircuitDepth,
    };
    std::shared_ptr<ITranslator> CreateResourcesTranslator();
    std::unique_ptr<IQuantumApi> CreateTracingSimulator(
        std::shared_ptr<ITranslator> resourcesTranslator,
        OptimizeFor settings);

} // namespace Quantum
} // namespace Microsoft
