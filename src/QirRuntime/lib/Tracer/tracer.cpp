// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include <assert.h>
#include <sstream>

#include "tracer.hpp"

using namespace std;

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

    //------------------------------------------------------------------------------------------------------------------
    // CTracer's ISumulator implementation
    //------------------------------------------------------------------------------------------------------------------
    IQuantumGateSet* CTracer::AsQuantumGateSet()
    {
        return nullptr;
    }
    IDiagnostics* CTracer::AsDiagnostics()
    {
        return nullptr;
    }
    Qubit CTracer::AllocateQubit()
    {
        size_t qubit = qubits.size();
        qubits.push_back({});
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

        stringstream str(qubitIndex);
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
    LayerId CTracer::CreateNewLayer(Duration opDuration)
    {
        // Create a new layer for the operation.
        Time layerStartTime = 0;
        if (!this->metricsByLayer.empty())
        {
            const Layer& lastLayer = this->metricsByLayer.back();
            layerStartTime = lastLayer.startTime + lastLayer.duration;
        }
        this->metricsByLayer.push_back(Layer{max(this->preferredLayerDuration, opDuration), layerStartTime});

        return this->metricsByLayer.size() - 1;
    }

    //------------------------------------------------------------------------------------------------------------------
    // CTracer::FindLayerToInsertOperationInto
    //------------------------------------------------------------------------------------------------------------------
    LayerId CTracer::FindLayerToInsertOperationInto(Qubit q, Duration opDuration) const
    {
        const QubitState& qstate = this->UseQubit(q);

        LayerId layerToInsertInto = INVALID;
        if (qstate.layer != INVALID)
        {
            const Layer& lastUsedIn = this->metricsByLayer[qstate.layer];
            if (qstate.lastUsedTime + opDuration <= lastUsedIn.startTime + lastUsedIn.duration)
            {
                layerToInsertInto = qstate.layer;
            }
            else
            {
                for (LayerId candidate = qstate.layer + 1; candidate < this->metricsByLayer.size(); candidate++)
                {
                    if (opDuration <= this->metricsByLayer[candidate].duration)
                    {
                        layerToInsertInto = candidate;
                        break;
                    }
                }
            }
        }
        else if (opDuration <= this->preferredLayerDuration && !this->metricsByLayer.empty())
        {
            // the qubit hasn't been used in any of the layers yet -- add it to the first layer
            layerToInsertInto = 0;
        }

        if (layerToInsertInto != INVALID && this->globalBarrier != INVALID)
        {
            if (this->globalBarrier + 1 == this->metricsByLayer.size())
            {
                layerToInsertInto = INVALID;
            }
            else
            {
                layerToInsertInto = std::max(layerToInsertInto, this->globalBarrier + 1);
            }
        }

        return layerToInsertInto;
    }

    //------------------------------------------------------------------------------------------------------------------
    // CTracer::AddOperationToLayer
    //------------------------------------------------------------------------------------------------------------------
    void CTracer::AddOperationToLayer(OpId id, LayerId layer)
    {
        assert(layer < this->metricsByLayer.size());
        auto inserted = this->metricsByLayer[layer].operations.insert({id, 1});
        if (!inserted.second)
        {
            assert(inserted.first->first == id);
            inserted.first->second += 1;
        }
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
        int64_t nFirstGroup,
        Qubit* firstGroup,
        int64_t nSecondGroup,
        Qubit* secondGroup)
    {
        assert(nFirstGroup >= 0);
        assert(nSecondGroup > 0);

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
        for (int64_t i = 1; i < nSecondGroup && layerToInsertInto != INVALID; i++)
        {
            layerToInsertInto =
                max(layerToInsertInto, this->FindLayerToInsertOperationInto(secondGroup[i], opDuration));
        }
        for (int64_t i = 0; i < nFirstGroup && layerToInsertInto != INVALID; i++)
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
        for (int64_t i = 0; i < nFirstGroup; i++)
        {
            this->UpdateQubitState(firstGroup[i], layerToInsertInto, opDuration);
        }
        for (int64_t i = 0; i < nSecondGroup; i++)
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

    Result CTracer::TraceMultiQubitMeasurement(OpId id, Duration duration, int64_t nTargets, Qubit* targets)
    {
        LayerId layerId = this->TraceMultiQubitOp(id, duration, 0, nullptr, nTargets, targets);
        return reinterpret_cast<Result>(layerId);
    }
} // namespace Quantum
} // namespace Microsoft