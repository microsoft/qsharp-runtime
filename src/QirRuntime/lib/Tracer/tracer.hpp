// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include <limits>
#include <memory>
#include <ostream>
#include <unordered_map>
#include <unordered_set>
#include <vector>

#include "CoreTypes.hpp"
#include "QuantumApi_I.hpp"

namespace Microsoft
{
namespace Quantum
{
    using OpId = int;
    using Time = int;
    using Duration = int;
    using LayerId = size_t;

    constexpr LayerId INVALID = std::numeric_limits<size_t>::max();

    /*==================================================================================================================
        Layer
    ==================================================================================================================*/
    struct Layer
    {
        // Width of the layer on the time axis.
        const Duration duration;

        // Start time of the layer.
        const Time startTime;

        // Quantum operations, assigned to this layer.
        std::unordered_map<OpId, int /*count of the op with this id*/> operations;

        // Optional id, if the layer represents a global barrier.
        OpId barrierId = -1;

        Layer(Duration duration, Time startTime)
            : duration(duration)
            , startTime(startTime)
        {
        }
    };

    /*==================================================================================================================
        QubitState
    ==================================================================================================================*/
    struct QubitState
    {
        // The last layer this qubit was used in, `INVALID` means the qubit haven't been used yet in any
        // operations of non-zero duration.
        LayerId layer = INVALID;

        // For layers with duration greater than one, multiple operations might fit on the same qubit, if the operations
        // are short. `lastUsedTime` is the end time of the last operation, the qubit participated it.
        Time lastUsedTime = 0;

        std::vector<OpId> pendingZeroOps;
    };

    /*==================================================================================================================
        The tracer implements resource estimation. See readme in this folder for details.
    ==================================================================================================================*/
    class CTracer : public ISimulator
    {
        // Start with no reuse of qubits.
        std::vector<QubitState> qubits;

        // The preferred duration of a layer.
        const int preferredLayerDuration = 0;

        // The index into the vector is treated as implicit id of the layer.
        std::vector<Layer> metricsByLayer;

        // The last global barrier, injected by the user. No new operations can be added to the barrier or to any of the
        // layer that preceeded it, even if the new operations involve completely new qubits.
        LayerId globalBarrier = INVALID;

        // Mapping of operation ids to user-chosen names, for operations that user didn't name, the output will use
        // operation ids.
        std::unordered_map<OpId, std::string> opNames;

        // Operations we've seen so far (to be able to trim output to include only these)
        std::unordered_set<OpId> seenOps;

      private:
        QubitState& UseQubit(Qubit q)
        {
            size_t qubitIndex = reinterpret_cast<size_t>(q);
            assert(qubitIndex < this->qubits.size());
            return this->qubits[qubitIndex];
        }
        const QubitState& UseQubit(Qubit q) const
        {
            size_t qubitIndex = reinterpret_cast<size_t>(q);
            assert(qubitIndex < this->qubits.size());
            return this->qubits[qubitIndex];
        }

        // If no appropriate layer found, return `INVALID`
        LayerId FindLayerToInsertOperationInto(Qubit q, Duration opDuration) const;

        // Returns the index of the created layer.
        LayerId CreateNewLayer(Duration minRequiredDuration);

        // Adds operation with given id into the given layer. Assumes that duration contraints have been satisfied.
        void AddOperationToLayer(OpId id, LayerId layer);

        // Update the qubit state with the new layer information
        void UpdateQubitState(Qubit q, LayerId layer, Duration opDuration);

      public:
        explicit CTracer(int preferredLayerDuration)
            : preferredLayerDuration(preferredLayerDuration)
        {
        }

        CTracer(int preferredLayerDuration, const std::unordered_map<OpId, std::string>& opNames)
            : preferredLayerDuration(preferredLayerDuration)
            , opNames(opNames)
        {
        }

        // -------------------------------------------------------------------------------------------------------------
        // ISimulator interface
        // -------------------------------------------------------------------------------------------------------------
        Qubit AllocateQubit() override;
        void ReleaseQubit(Qubit qubit) override;
        std::string QubitToString(Qubit qubit) override;
        void ReleaseResult(Result result) override;

        IQuantumGateSet* AsQuantumGateSet() override
        {
            throw std::logic_error("Not supported: all intrinsics must be converted to tracing operations");
        }
        IDiagnostics* AsDiagnostics() override
        {
            return nullptr;
        }
        Result M(Qubit target) override
        {
            throw std::logic_error("Not supported: all measurements must be converted to tracing operations");
        }
        Result Measure(long numBases, PauliId bases[], long numTargets, Qubit targets[]) override
        {
            throw std::logic_error("Not supported: all measurements must be converted to tracing operations");
        }
        bool AreEqualResults(Result r1, Result r2) override
        {
            throw std::logic_error("Cannot compare results while tracing!");
        }
        ResultValue GetResultValue(Result result) override
        {
            throw std::logic_error("Result values aren't available while tracing!");
        }
        Result UseZero() override;
        Result UseOne() override;

        // -------------------------------------------------------------------------------------------------------------
        // Instead of implementing IQuantumGateSet, the tracer provides 'tracing-by-id' methods. The QIR generation
        // should translate all intrinsics to invoke these methods.
        // The tracer doesn't differentiate between control and target qubits. However, While it could provide a single
        // generic tracing method for and array of qubits, that would require the clients to copy control and target
        // qubits into the same array. To avoid the copy, the tracer provides a method that takes two groups of qubits,
        // where the first one can be empty or can be viewed as the set of controls.
        // -------------------------------------------------------------------------------------------------------------
        LayerId TraceSingleQubitOp(OpId id, Duration duration, Qubit target);
        LayerId TraceMultiQubitOp(
            OpId id,
            Duration duration,
            long nFirstGroup,
            Qubit* firstGroup,
            long nSecondGroup,
            Qubit* secondGroup);

        Result TraceSingleQubitMeasurement(OpId id, Duration duration, Qubit target);
        Result TraceMultiQubitMeasurement(OpId id, Duration duration, long nTargets, Qubit* targets);
        LayerId GetLayerIdOfSourceMeasurement(Result r) const
        {
            return reinterpret_cast<LayerId>(r);
        }

        // -------------------------------------------------------------------------------------------------------------
        // Backing of the rest of the bridge methods.
        // -------------------------------------------------------------------------------------------------------------
        LayerId InjectGlobalBarrier(OpId id, Duration duration);

        // -------------------------------------------------------------------------------------------------------------
        // Configuring the tracer and getting data back from it.
        // -------------------------------------------------------------------------------------------------------------
        // Temporary method for initial testing
        // TODO: replace with a safer accessor
        const std::vector<Layer>& UseLayers()
        {
            return this->metricsByLayer;
        }

        void PrintLayerMetrics(std::ostream& out, const std::string& separator, bool printZeroMetrics) const;
    };

    std::shared_ptr<CTracer> CreateTracer(int preferredLayerDuration);
    std::shared_ptr<CTracer> CreateTracer(
        int preferredLayerDuration,
        const std::unordered_map<OpId, std::string>& opNames);

} // namespace Quantum
} // namespace Microsoft