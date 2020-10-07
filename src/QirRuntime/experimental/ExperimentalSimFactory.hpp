#pragma once

#include <memory>
#include <vector>

#include "QAPI.hpp"
#include "IQuantumApi.hpp"
#include "ITranslator.hpp"

namespace quantum
{
    // Lockstep simulator executes the provided simulators "in lockstep", one operation
    // at a time. The result value buffer should be allocated by the caller and would contain
    // result values from each simulator after calling `GetResultValue` on a result, that
    // represents a cumulative result of a measurement. If the buffer isn't provided (is null),
    // the individual result values aren't communicated back to the caller.
    std::unique_ptr<IQuantumApi> CreateLockstepSimulator(
        std::vector<IQuantumApi*>&& simulatorsToRunInLockstep,
        ResultValue* resultValuesBuffer /*size of the buffer must be equal the number of simulators*/);

    // IonQ translator traces the quantum program to generate ionq-json that describes the program.
    std::shared_ptr<ITranslator> CreateIonqTranslator();
    std::unique_ptr<IQuantumApi> CreateIonqSimulator(std::shared_ptr<ITranslator> ionqTranslator);

    // Transing simulator is effectively a translator: it traces the quantum program to collect
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

} // namespace quantum
