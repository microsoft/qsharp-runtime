// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

/*=============================================================================
    QIR assumes a single global execution context.
    To support the dispatch over the qir-bridge, the clients must register their
    Microsoft::Quantum::IRuntimeDriver* first.
=============================================================================*/
#include <cassert>
#include <vector>

#include "qsharp__core__qis.hpp"

#include "QirRuntimeApi_I.hpp"
#include "QSharpSimApi_I.hpp"
#include "QirContext.hpp"
#include "QirTypes.hpp"

// Pauli consts are {i2} in QIR, likely stored as {i8} in arrays, but we are using the standard C++ enum type based on
// {i32} so cannot pass through the buffer and have to allocate a new one instead and copy.
static std::vector<PauliId> ExtractPauliIds(QirArray* paulis)
{
    const QirArray::TItemCount count = paulis->count;
    std::vector<PauliId> pauliIds;
    pauliIds.reserve(count);
    for (QirArray::TItemCount i = 0; i < count; i++)
    {
        pauliIds.push_back(static_cast<PauliId>(*paulis->GetItemPointer(i)));
    }
    return pauliIds;
}

static Microsoft::Quantum::IQuantumGateSet* GateSet()
{
    return dynamic_cast<Microsoft::Quantum::IQuantumGateSet*>(Microsoft::Quantum::GlobalContext()->GetDriver());
}

extern "C"
{
    void __quantum__qis__exp__body(QirArray* paulis, double angle, QirArray* qubits)
    {
        assert(paulis->count == qubits->count);

        std::vector<PauliId> pauliIds = ExtractPauliIds(paulis);
        GateSet()->Exp((long)(paulis->count), reinterpret_cast<PauliId*>(pauliIds.data()),
                       reinterpret_cast<QubitIdType*>(qubits->buffer), angle);
    }

    void __quantum__qis__exp__adj(QirArray* paulis, double angle, QirArray* qubits)
    {
        __quantum__qis__exp__body(paulis, -angle, qubits);
    }

    void __quantum__qis__exp__ctl(QirArray* ctls, QirExpTuple* args)
    {
        assert(args->paulis->count == args->targets->count);

        std::vector<PauliId> pauliIds = ExtractPauliIds(args->paulis);
        GateSet()->ControlledExp((long)(ctls->count), reinterpret_cast<QubitIdType*>(ctls->buffer),
                                 (long)(args->paulis->count), reinterpret_cast<PauliId*>(pauliIds.data()),
                                 reinterpret_cast<QubitIdType*>(args->targets->buffer), args->angle);
    }

    void __quantum__qis__exp__ctladj(QirArray* ctls, QirExpTuple* args)
    {
        assert(args->paulis->count == args->targets->count);

        QirExpTuple updatedArgs = {args->paulis, -(args->angle), args->targets};

        __quantum__qis__exp__ctl(ctls, &updatedArgs);
    }

    void __quantum__qis__h__body(QUBIT* qubit)
    {
        GateSet()->H(reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__h__ctl(QirArray* ctls, QUBIT* qubit)
    {
        GateSet()->ControlledH((long)(ctls->count), reinterpret_cast<QubitIdType*>(ctls->buffer),
                               reinterpret_cast<QubitIdType>(qubit));
    }

    Result __quantum__qis__measure__body(QirArray* paulis, QirArray* qubits)
    {
        const QirArray::TItemCount count = qubits->count;
        assert(count == paulis->count);

        std::vector<PauliId> pauliIds = ExtractPauliIds(paulis);
        return GateSet()->Measure((long)(count), reinterpret_cast<PauliId*>(pauliIds.data()), (long)(count),
                                  reinterpret_cast<QubitIdType*>(qubits->buffer));
    }

    void __quantum__qis__r__body(PauliId axis, double angle, QUBIT* qubit)
    {
        GateSet()->R(axis, reinterpret_cast<QubitIdType>(qubit), angle);
    }

    void __quantum__qis__r__adj(PauliId axis, double angle, QUBIT* qubit)
    {
        __quantum__qis__r__body(axis, -angle, qubit);
    }

    void __quantum__qis__r__ctl(QirArray* ctls, QirRTuple* args)
    {
        GateSet()->ControlledR((long)(ctls->count), reinterpret_cast<QubitIdType*>(ctls->buffer), args->pauli,
                               reinterpret_cast<QubitIdType>(args->target), args->angle);
    }

    void __quantum__qis__r__ctladj(QirArray* ctls, QirRTuple* args)
    {
        GateSet()->ControlledR((long)(ctls->count), reinterpret_cast<QubitIdType*>(ctls->buffer), args->pauli,
                               reinterpret_cast<QubitIdType>(args->target), -(args->angle));
    }

    void __quantum__qis__s__body(QUBIT* qubit)
    {
        GateSet()->S(reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__s__adj(QUBIT* qubit)
    {
        GateSet()->AdjointS(reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__s__ctl(QirArray* ctls, QUBIT* qubit)
    {
        GateSet()->ControlledS((long)(ctls->count), reinterpret_cast<QubitIdType*>(ctls->buffer),
                               reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__s__ctladj(QirArray* ctls, QUBIT* qubit)
    {
        GateSet()->ControlledAdjointS((long)(ctls->count), reinterpret_cast<QubitIdType*>(ctls->buffer),
                                      reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__t__body(QUBIT* qubit)
    {
        GateSet()->T(reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__t__adj(QUBIT* qubit)
    {
        GateSet()->AdjointT(reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__t__ctl(QirArray* ctls, QUBIT* qubit)
    {
        GateSet()->ControlledT((long)(ctls->count), reinterpret_cast<QubitIdType*>(ctls->buffer),
                               reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__t__ctladj(QirArray* ctls, QUBIT* qubit)
    {
        GateSet()->ControlledAdjointT((long)(ctls->count), reinterpret_cast<QubitIdType*>(ctls->buffer),
                                      reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__x__body(QUBIT* qubit)
    {
        GateSet()->X(reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__x__ctl(QirArray* ctls, QUBIT* qubit)
    {
        GateSet()->ControlledX((long)(ctls->count), reinterpret_cast<QubitIdType*>(ctls->buffer),
                               reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__y__body(QUBIT* qubit)
    {
        GateSet()->Y(reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__y__ctl(QirArray* ctls, QUBIT* qubit)
    {
        GateSet()->ControlledY((long)(ctls->count), reinterpret_cast<QubitIdType*>(ctls->buffer),
                               reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__z__body(QUBIT* qubit)
    {
        GateSet()->Z(reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__z__ctl(QirArray* ctls, QUBIT* qubit)
    {
        GateSet()->ControlledZ((long)(ctls->count), reinterpret_cast<QubitIdType*>(ctls->buffer),
                               reinterpret_cast<QubitIdType>(qubit));
    }
}
