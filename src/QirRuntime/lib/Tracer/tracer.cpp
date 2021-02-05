// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include <cassert>
#include <set>
#include <sstream>

#include "tracer.hpp"

using namespace std;

namespace Microsoft
{
namespace Quantum
{
    thread_local std::shared_ptr<CTracer> tracer = nullptr;
    std::shared_ptr<CTracer> CreateTracer(int preferredLayerDuration)
    {
        tracer = std::make_shared<CTracer>(preferredLayerDuration);
        return tracer;
    }
    std::shared_ptr<CTracer> CreateTracer(int preferredLayerDuration, const std::unordered_map<OpId, std::string>& opNames)
    {
        tracer = std::make_shared<CTracer>(preferredLayerDuration, opNames);
        return tracer;
    }

    //------------------------------------------------------------------------------------------------------------------
    // CTracer's ISimulator implementation
    //------------------------------------------------------------------------------------------------------------------
    Qubit CTracer::AllocateQubit()
    {
        size_t qubit = qubits.size();
        qubits.emplace_back(QubitState{});
        return reinterpret_cast<Qubit>(qubit);
    }
    void CTracer::ReleaseQubit(Qubit /*qubit*/)
    {
        // nothing for now
    }
    std::string CTracer::QubitToString(Qubit q)
    {
        size_t qubitIndex = reinterpret_cast<size_t>(q);
        const QubitState& qstate = this->UseQubit(q);

        stringstream str(std::to_string(qubitIndex));
        str << " last used in layer " << qstate.layer << "(pending zero ops: " << qstate.pendingZeroOps.size() << ")";
        return str.str();
    }
    void CTracer::ReleaseResult(Result /*result*/)
    {
        // nothing to do, we don't allocate results on measurement
    }
    // Although the tracer should never compare results or get their values, it still has to implement UseZero and
    // UseOne methods as they are invoked by the QIR initialization.
    Result CTracer::UseZero()
    {
        return reinterpret_cast<Result>(INVALID);
    }
    Result CTracer::UseOne()
    {
        return reinterpret_cast<Result>(INVALID);
    }

    //------------------------------------------------------------------------------------------------------------------
    // CTracer::CreateNewLayer
    //------------------------------------------------------------------------------------------------------------------
    LayerId CTracer::CreateNewLayer(Duration minRequiredDuration)
    {
        // Create a new layer for the operation.
        Time layerStartTime = 0;
        if (!this->metricsByLayer.empty())
        {
            const Layer& lastLayer = this->metricsByLayer.back();
            layerStartTime = lastLayer.startTime + lastLayer.duration;
        }
        this->metricsByLayer.emplace_back(
            Layer{max(this->preferredLayerDuration, minRequiredDuration), layerStartTime});

        return this->metricsByLayer.size() - 1;
    }

    //------------------------------------------------------------------------------------------------------------------
    // CTracer::FindLayerToInsertOperationInto
    //------------------------------------------------------------------------------------------------------------------
    LayerId CTracer::FindLayerToInsertOperationInto(Qubit q, Duration opDuration) const
    {
        const QubitState& qstate = this->UseQubit(q);

        LayerId layerToInsertInto = INVALID;

        const LayerId firstLayerAfterBarrier =
            this->globalBarrier == INVALID
                ? this->metricsByLayer.empty() ? INVALID : 0
                : this->globalBarrier + 1 == this->metricsByLayer.size() ? INVALID : this->globalBarrier + 1;

        LayerId candidate = max(qstate.layer, firstLayerAfterBarrier);

        if (candidate != INVALID)
        {
            // Find the earliest layer that the operation fits in by duration
            const Layer& candidateLayer = this->metricsByLayer[candidate];
            const Time lastUsedTime = max(qstate.lastUsedTime, candidateLayer.startTime);
            if (lastUsedTime + opDuration <= candidateLayer.startTime + candidateLayer.duration)
            {
                layerToInsertInto = candidate;
            }
            else
            {
                for (candidate += 1; candidate < this->metricsByLayer.size(); ++candidate)
                {
                    if (opDuration <= this->metricsByLayer[candidate].duration)
                    {
                        layerToInsertInto = candidate;
                        break;
                    }
                }
            }
        }
        else if (opDuration <= this->preferredLayerDuration)
        {
            layerToInsertInto = firstLayerAfterBarrier;
        }

        return layerToInsertInto;
    }

    //------------------------------------------------------------------------------------------------------------------
    // CTracer::AddOperationToLayer
    //------------------------------------------------------------------------------------------------------------------
    void CTracer::AddOperationToLayer(OpId id, LayerId layer)
    {
        assert(layer < this->metricsByLayer.size());
        this->metricsByLayer[layer].operations[id] += 1;
    }

    //------------------------------------------------------------------------------------------------------------------
    // CTracer::UpdateQubitState
    //------------------------------------------------------------------------------------------------------------------
    void CTracer::UpdateQubitState(Qubit q, LayerId layer, Duration opDuration)
    {
        QubitState& qstate = this->UseQubit(q);
        for (OpId idPending : qstate.pendingZeroOps)
        {
            this->AddOperationToLayer(idPending, layer);
        }

        // Update the qubit state.
        qstate.layer = layer;
        const Time layerStart = this->metricsByLayer[layer].startTime;
        qstate.lastUsedTime = max(layerStart, qstate.lastUsedTime) + opDuration;
        qstate.pendingZeroOps.clear();
    }

    //------------------------------------------------------------------------------------------------------------------
    // CTracer::TraceSingleQubitOp
    //------------------------------------------------------------------------------------------------------------------
    LayerId CTracer::TraceSingleQubitOp(OpId id, Duration opDuration, Qubit target)
    {
        this->seenOps.insert(id);

        QubitState& qstate = this->UseQubit(target);
        if (opDuration == 0 &&
            (qstate.layer == INVALID || (this->globalBarrier != INVALID && qstate.layer < this->globalBarrier)))
        {
            qstate.pendingZeroOps.push_back(id);
            return INVALID;
        }

        // Figure out the layer this operation should go into.
        LayerId layerToInsertInto = this->FindLayerToInsertOperationInto(target, opDuration);
        if (layerToInsertInto == INVALID)
        {
            layerToInsertInto = this->CreateNewLayer(opDuration);
        }

        // Add the operation and the pending zero-duration ones into the layer.
        this->AddOperationToLayer(id, layerToInsertInto);
        this->UpdateQubitState(target, layerToInsertInto, opDuration);

        return layerToInsertInto;
    }

    //------------------------------------------------------------------------------------------------------------------
    // CTracer::TraceControlledSingleQubitOp
    //------------------------------------------------------------------------------------------------------------------
    LayerId CTracer::TraceMultiQubitOp(
        OpId id,
        Duration opDuration,
        long nFirstGroup,
        Qubit* firstGroup,
        long nSecondGroup,
        Qubit* secondGroup)
    {
        assert(nFirstGroup >= 0);
        assert(nSecondGroup > 0);

        this->seenOps.insert(id);

        // Operations that involve a single qubit can special case duration zero.
        if (nFirstGroup == 0 && nSecondGroup == 1)
        {
            return this->TraceSingleQubitOp(id, opDuration, secondGroup[0]);
        }

        // Special-casing operations of duration zero enables potentially better reuse of qubits, when we'll start
        // optimizing for circuit width. However, tracking _the same_ pending operation across _multiple_ qubits is
        // tricky and not worth the effort, so we don't do it.

        // Figure out the layer this operation should go into.
        LayerId layerToInsertInto = this->FindLayerToInsertOperationInto(secondGroup[0], opDuration);
        for (long i = 1; i < nSecondGroup && layerToInsertInto != INVALID; i++)
        {
            layerToInsertInto =
                max(layerToInsertInto, this->FindLayerToInsertOperationInto(secondGroup[i], opDuration));
        }
        for (long i = 0; i < nFirstGroup && layerToInsertInto != INVALID; i++)
        {
            layerToInsertInto = max(layerToInsertInto, this->FindLayerToInsertOperationInto(firstGroup[i], opDuration));
        }
        if (layerToInsertInto == INVALID)
        {
            layerToInsertInto = this->CreateNewLayer(opDuration);
        }

        // Add the operation into the layer.
        this->AddOperationToLayer(id, layerToInsertInto);

        // Update the state of the involved qubits.
        for (long i = 0; i < nFirstGroup; i++)
        {
            this->UpdateQubitState(firstGroup[i], layerToInsertInto, opDuration);
        }
        for (long i = 0; i < nSecondGroup; i++)
        {
            this->UpdateQubitState(secondGroup[i], layerToInsertInto, opDuration);
        }

        return layerToInsertInto;
    }

    LayerId CTracer::InjectGlobalBarrier(OpId id, Duration duration)
    {
        LayerId layer = this->CreateNewLayer(duration);
        this->metricsByLayer[layer].barrierId = id;
        this->globalBarrier = layer;
        return layer;
    }

    Result CTracer::TraceSingleQubitMeasurement(OpId id, Duration duration, Qubit target)
    {
        LayerId layerId = this->TraceSingleQubitOp(id, duration, target);
        return reinterpret_cast<Result>(layerId);
    }

    Result CTracer::TraceMultiQubitMeasurement(OpId id, Duration duration, long nTargets, Qubit* targets)
    {
        LayerId layerId = this->TraceMultiQubitOp(id, duration, 0, nullptr, nTargets, targets);
        return reinterpret_cast<Result>(layerId);
    }

    //------------------------------------------------------------------------------------------------------------------
    // CTracer::PrintLayerMetrics
    //------------------------------------------------------------------------------------------------------------------
    static std::string GetOperationName(OpId opId, const std::unordered_map<OpId, std::string>& opNames)
    {
        if (opId < 0)
        {
            return "";
        }

        auto nameIt = opNames.find(opId);
        return nameIt == opNames.end() ? std::to_string(opId) : nameIt->second;
    }
    void CTracer::PrintLayerMetrics(std::ostream& out, const std::string& separator, bool printZeroMetrics) const
    {
        // Sort the operations by id so the output is deterministic.
        std::set<OpId> seenOpsOrederedById(this->seenOps.begin(), this->seenOps.end());

        // header row
        out << "layer_id" << separator << "name";
        for (OpId opId : seenOpsOrederedById)
        {
            out << separator << GetOperationName(opId, this->opNames);
        }
        out << std::endl;

        // data rows
        const std::string zeroString = printZeroMetrics ? "0" : "";
        for (const Layer& layer : this->metricsByLayer)
        {
            out << layer.startTime;
            out << separator << GetOperationName(layer.barrierId, this->opNames);

            for (OpId opId : seenOpsOrederedById)
            {
                auto foundInLayer = layer.operations.find(opId);
                out << separator
                    << ((foundInLayer == layer.operations.end()) ? zeroString : std::to_string(foundInLayer->second));
            }
            out << std::endl;
        }
    }
} // namespace Quantum
} // namespace Microsoft