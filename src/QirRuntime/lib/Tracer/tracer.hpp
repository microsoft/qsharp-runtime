// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include <memory>

#include "CoreTypes.hpp"
#include "QuantumApi_I.hpp"

namespace Microsoft
{
namespace Quantum
{
    /*======================================================================================================================
        TracedQubit
    ======================================================================================================================*/
    struct TracedQubit
    {
        static const long INVALID = -1;

        long id = INVALID;

        // Last layer the qubit was used in, `INVALID` means the qubit haven't been used yet in any operations of
        // non-zero duration.
        int layer = INVALID;
    };

    /*======================================================================================================================
        The tracer implements resource estimation. See readme in this folder for details.
    ======================================================================================================================*/
    class CTracer : public ISimulator
    {
        // Start with no reuse of qubits.
        long lastQubitId = -1;

      public:
        IQuantumGateSet* AsQuantumGateSet() override
        {
            return nullptr;
        }
        IDiagnostics* AsDiagnostics() override
        {
            return nullptr;
        }
        Qubit AllocateQubit() override
        {
            return reinterpret_cast<Qubit>(++lastQubitId);
        }
        void ReleaseQubit(Qubit qubit) override
        {
            // nothing for now
        }
        std::string QubitToString(Qubit qubit) override
        {
            throw std::logic_error("not_implemented");
        }
        Result M(Qubit target) override
        {
            throw std::logic_error("not_implemented");
        }
        Result Measure(long numBases, PauliId bases[], long numTargets, Qubit targets[]) override
        {
            throw std::logic_error("not_implemented");
        }
        void ReleaseResult(Result result) override
        {
            throw std::logic_error("not_implemented");
        }
        bool AreEqualResults(Result r1, Result r2) override
        {
            throw std::logic_error("not_implemented");
        }
        ResultValue GetResultValue(Result result) override
        {
            throw std::logic_error("not_implemented");
        }
        Result UseZero() override
        {
            return reinterpret_cast<Result>(0);
        }
        Result UseOne() override
        {
            return reinterpret_cast<Result>(1);
        }

        void TraceSingleQubitOp(int32_t id, int32_t duration, TracedQubit* target)
        {
            // figure out the layering, etc.
        }
    };

    std::shared_ptr<CTracer> CreateTracer();

} // namespace Quantum
} // namespace Microsoft