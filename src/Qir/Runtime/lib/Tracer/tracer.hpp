// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
#pragma once

#include <memory>
#include <ostream>
#include <unordered_map>
#include <unordered_set>
#include <vector>

#include "CoreTypes.hpp"
#include "QirRuntimeApi_I.hpp"
#include "TracerTypes.hpp"

namespace Microsoft
{
namespace Quantum
{
    /*==================================================================================================================
        Layer
    ==================================================================================================================*/
    struct QIR_SHARED_API Layer
    {
        // Start time of the layer.
        const Time startTime;

        // Width of the layer on the time axis.
        const Duration duration;

        // Quantum operations, assigned to this layer.
        std::unordered_map<OpId, int /*count of the op with this id*/> operations;

        // Optional id, if the layer represents a global barrier.
        OpId barrierId = -1;

        Layer(Time startTime, Duration duration)
            : startTime(startTime)
            , duration(duration)
        {
        }
    };

    /*==================================================================================================================
        QubitState
    ==================================================================================================================*/
    struct QIR_SHARED_API QubitState
    {
        // The last layer this qubit was used in, `INVALID` means the qubit haven't been used yet in any
        // operations of non-zero duration.
        LayerId layer = INVALID;

        // `lastUsedTime` stores the end time of the last operation, the qubit participated in. It might not match the
        // end time of a layer, if the duration of the last operation is less than duration of the layer. Tracking this
        // time allows us to possibly fit multiple short operations on the same qubit into a single layer.
        Time lastUsedTime = 0;

        std::vector<OpId> pendingZeroDurationOps;
    };

    /*==================================================================================================================
        The tracer implements resource estimation. See readme in this folder for details.
    ==================================================================================================================*/
    class QIR_SHARED_API CTracer : public IRuntimeDriver
    {
        // For now the tracer assumes no reuse of qubits.
        std::vector<QubitState> qubits;

        // The preferred duration of a layer. An operation with longer duration will make the containing layer longer.
        const int preferredLayerDuration = 0;

        // The index into the vector is treated as implicit id of the layer.
        std::vector<Layer> metricsByLayer;

        // The last barrier, injected by the user. No new operations can be added to the barrier or to any of the
        // layer that preceeded it, even if the new operations involve completely new qubits. Thus, the barriers act
        // as permanent fences, that are activated at the moment the tracer executes the corresponding user code and are
        // never removed.
        LayerId globalBarrier = INVALID;

        // The conditional fences are layers that contain measurements for results used to guard conditional branches.
        // The set of fences is a stack (for nested conditionals) but we use vector to store them so we can recalculate
        // the latest (by time) fence when the stack is popped.
        std::vector<LayerId> conditionalFences;

        // We don't expect the stack of conditional fences to be deep, so it's OK to recalculate the latest layer when
        // the stack is modified.
        LayerId latestConditionalFence = INVALID;

        // Mapping of operation ids to user-chosen names, for operations that user didn't name, the output will use
        // operation ids.
        std::unordered_map<OpId, std::string> opNames;

        // Operations we've seen so far (to be able to trim output to include only those that were encounted).
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

        // If no appropriate layer found, returns `REQUESTNEW`.
        LayerId FindLayerToInsertOperationInto(Qubit q, Duration opDuration) const;

        // Returns the index of the created layer.
        LayerId CreateNewLayer(Duration minRequiredDuration);

        // Adds operation with given id into the given layer. Assumes that duration contraints have been satisfied.
        void AddOperationToLayer(OpId id, LayerId layer);

        // Update the qubit state with the new layer information.
        void UpdateQubitState(Qubit q, LayerId layer, Duration opDuration);

        // Considers global barriers and conditional fences to find the fence currently in effect.
        LayerId GetEffectiveFence() const;

        // For the given results finds the latest layer of the measurements that produced the results.
        LayerId FindLatestMeasurementLayer(long count, Result* results);

      public:
        // Returns the later layer of the two. INVALID LayerId is treated as -Infinity, and REQUESTNEW -- as +Infinity.
        static LayerId LaterLayerOf(LayerId l1, LayerId l2);

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
        // IRuntimeDriver interface
        // -------------------------------------------------------------------------------------------------------------
        Qubit AllocateQubit() override;
        void ReleaseQubit(Qubit qubit) override;
        std::string QubitToString(Qubit qubit) override;
        void ReleaseResult(Result result) override;

        bool AreEqualResults(Result, Result) override
        {
            throw std::logic_error("Cannot compare results while tracing!");
        }
        ResultValue GetResultValue(Result) override
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

        struct FenceScope
        {
            CTracer* tracer = nullptr;
            LayerId fence = INVALID;
            explicit FenceScope(CTracer* tracer, long count1, Result* results1, long count2, Result* results2);
            ~FenceScope();
        };

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

    QIR_SHARED_API std::shared_ptr<CTracer> CreateTracer(int preferredLayerDuration);
    QIR_SHARED_API std::shared_ptr<CTracer> CreateTracer(
        int preferredLayerDuration,
        const std::unordered_map<OpId, std::string>& opNames);

} // namespace Quantum
} // namespace Microsoft