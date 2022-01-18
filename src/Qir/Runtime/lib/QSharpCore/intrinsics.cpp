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
#include "QirRuntime.hpp"
#include "QirRuntimeApi_I.hpp"
#include "QSharpSimApi_I.hpp"
#include "QirContext.hpp"
#include "QirTypes.hpp"

// Pauli consts are {i2} in QIR, likely stored as {i8} in arrays, but we are using the standard C++ enum type based on
// {i32} so cannot pass through the buffer and have to allocate a new one instead and copy.
static std::vector<PauliId> ExtractPauliIds(QirArray* paulis)
{
    const QirArray::TItemCount count = (QirArray::TItemCount)__quantum__rt__array_get_size_1d(paulis);
    std::vector<PauliId> pauliIds;
    pauliIds.reserve(count);
    for (QirArray::TItemCount i = 0; i < count; i++)
    {
        pauliIds.push_back(static_cast<PauliId>(*__quantum__rt__array_get_element_ptr_1d(paulis, i)));
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
        assert(__quantum__rt__array_get_size_1d(paulis) == __quantum__rt__array_get_size_1d(qubits));

        std::vector<PauliId> pauliIds = ExtractPauliIds(paulis);
        GateSet()->Exp((long)(__quantum__rt__array_get_size_1d(paulis)), reinterpret_cast<PauliId*>(pauliIds.data()),
                       reinterpret_cast<QubitIdType*>(__quantum__rt__array_get_element_ptr_1d(qubits, 0)), angle);
    }

    void __quantum__qis__exp__adj(QirArray* paulis, double angle, QirArray* qubits)
    {
        __quantum__qis__exp__body(paulis, -angle, qubits);
    }

    void __quantum__qis__exp__ctl(QirArray* ctls, QirExpTuple* args)
    {
        assert(__quantum__rt__array_get_size_1d(args->paulis) == __quantum__rt__array_get_size_1d(args->targets));

        std::vector<PauliId> pauliIds = ExtractPauliIds(args->paulis);
        GateSet()->ControlledExp(
            (long)(__quantum__rt__array_get_size_1d(ctls)),
            reinterpret_cast<QubitIdType*>(__quantum__rt__array_get_element_ptr_1d(ctls, 0)),
            (long)(__quantum__rt__array_get_size_1d(args->paulis)), reinterpret_cast<PauliId*>(pauliIds.data()),
            reinterpret_cast<QubitIdType*>(__quantum__rt__array_get_element_ptr_1d(args->targets, 0)), args->angle);
    }

    void __quantum__qis__exp__ctladj(QirArray* ctls, QirExpTuple* args)
    {
        assert(__quantum__rt__array_get_size_1d(args->paulis) == __quantum__rt__array_get_size_1d(args->targets));

        QirExpTuple updatedArgs = {args->paulis, -(args->angle), args->targets};

        __quantum__qis__exp__ctl(ctls, &updatedArgs);
    }

    void __quantum__qis__h__body(QUBIT* qubit)
    {
        GateSet()->H(reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__h__ctl(QirArray* ctls, QUBIT* qubit)
    {
        GateSet()->ControlledH((long)(__quantum__rt__array_get_size_1d(ctls)),
                               reinterpret_cast<QubitIdType*>(__quantum__rt__array_get_element_ptr_1d(ctls, 0)),
                               reinterpret_cast<QubitIdType>(qubit));
    }

    Result __quantum__qis__measure__body(QirArray* paulis, QirArray* qubits)
    {
        const QirArray::TItemCount count = (QirArray::TItemCount)__quantum__rt__array_get_size_1d(qubits);
        assert(count == __quantum__rt__array_get_size_1d(paulis));

        std::vector<PauliId> pauliIds = ExtractPauliIds(paulis);
        return GateSet()->Measure((long)(count), reinterpret_cast<PauliId*>(pauliIds.data()), (long)(count),
                                  reinterpret_cast<QubitIdType*>(__quantum__rt__array_get_element_ptr_1d(qubits, 0)));
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
        GateSet()->ControlledR((long)(__quantum__rt__array_get_size_1d(ctls)),
                               reinterpret_cast<QubitIdType*>(__quantum__rt__array_get_element_ptr_1d(ctls, 0)),
                               args->pauli, reinterpret_cast<QubitIdType>(args->target), args->angle);
    }

    void __quantum__qis__r__ctladj(QirArray* ctls, QirRTuple* args)
    {
        GateSet()->ControlledR((long)(__quantum__rt__array_get_size_1d(ctls)),
                               reinterpret_cast<QubitIdType*>(__quantum__rt__array_get_element_ptr_1d(ctls, 0)),
                               args->pauli, reinterpret_cast<QubitIdType>(args->target), -(args->angle));
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
        GateSet()->ControlledS((long)(__quantum__rt__array_get_size_1d(ctls)),
                               reinterpret_cast<QubitIdType*>(__quantum__rt__array_get_element_ptr_1d(ctls, 0)),
                               reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__s__ctladj(QirArray* ctls, QUBIT* qubit)
    {
        GateSet()->ControlledAdjointS((long)(__quantum__rt__array_get_size_1d(ctls)),
                                      reinterpret_cast<QubitIdType*>(__quantum__rt__array_get_element_ptr_1d(ctls, 0)),
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
        GateSet()->ControlledT((long)(__quantum__rt__array_get_size_1d(ctls)),
                               reinterpret_cast<QubitIdType*>(__quantum__rt__array_get_element_ptr_1d(ctls, 0)),
                               reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__t__ctladj(QirArray* ctls, QUBIT* qubit)
    {
        GateSet()->ControlledAdjointT((long)(__quantum__rt__array_get_size_1d(ctls)),
                                      reinterpret_cast<QubitIdType*>(__quantum__rt__array_get_element_ptr_1d(ctls, 0)),
                                      reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__x__body(QUBIT* qubit)
    {
        GateSet()->X(reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__x__ctl(QirArray* ctls, QUBIT* qubit)
    {
        GateSet()->ControlledX((long)(__quantum__rt__array_get_size_1d(ctls)),
                               reinterpret_cast<QubitIdType*>(__quantum__rt__array_get_element_ptr_1d(ctls, 0)),
                               reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__y__body(QUBIT* qubit)
    {
        GateSet()->Y(reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__y__ctl(QirArray* ctls, QUBIT* qubit)
    {
        GateSet()->ControlledY((long)(__quantum__rt__array_get_size_1d(ctls)),
                               reinterpret_cast<QubitIdType*>(__quantum__rt__array_get_element_ptr_1d(ctls, 0)),
                               reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__z__body(QUBIT* qubit)
    {
        GateSet()->Z(reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__z__ctl(QirArray* ctls, QUBIT* qubit)
    {
        GateSet()->ControlledZ((long)(__quantum__rt__array_get_size_1d(ctls)),
                               reinterpret_cast<QubitIdType*>(__quantum__rt__array_get_element_ptr_1d(ctls, 0)),
                               reinterpret_cast<QubitIdType>(qubit));
    }
}
