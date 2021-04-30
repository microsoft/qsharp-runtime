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
    const long count = paulis->count;
    std::vector<PauliId> pauliIds;
    pauliIds.reserve(count);
    for (long i = 0; i < count; i++)
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
    void quantum__qis__exp__body(QirArray* paulis, double angle, QirArray* qubits)
    {
        assert(paulis->count == qubits->count);

        std::vector<PauliId> pauliIds = ExtractPauliIds(paulis);
        return GateSet()->Exp(
            paulis->count, reinterpret_cast<PauliId*>(pauliIds.data()), reinterpret_cast<Qubit*>(qubits->buffer),
            angle);
    }

    void quantum__qis__exp__adj(QirArray* paulis, double angle, QirArray* qubits)
    {
        quantum__qis__exp__body(paulis, -angle, qubits);
    }

    void quantum__qis__exp__ctl(QirArray* ctls, QirArray* paulis, double angle, QirArray* qubits)
    {
        assert(paulis->count == qubits->count);

        std::vector<PauliId> pauliIds = ExtractPauliIds(paulis);
        return GateSet()->ControlledExp(
            ctls->count, reinterpret_cast<Qubit*>(ctls->buffer), paulis->count,
            reinterpret_cast<PauliId*>(pauliIds.data()), reinterpret_cast<Qubit*>(qubits->buffer), angle);
    }

    void quantum__qis__exp__ctladj(QirArray* ctls, QirArray* paulis, double angle, QirArray* qubits)
    {
        quantum__qis__exp__ctl(ctls, paulis, -angle, qubits);
    }

    void quantum__qis__h__body(Qubit qubit)
    {
        GateSet()->H(qubit);
    }

    void quantum__qis__h__ctl(QirArray* ctls, Qubit qubit)
    {
        GateSet()->ControlledH(
            ctls->count, reinterpret_cast<Qubit*>(ctls->buffer), qubit);
    }

    Result quantum__qis__measure__body(QirArray* paulis, QirArray* qubits)
    {
        const long count = qubits->count;
        assert(count == paulis->count);

        std::vector<PauliId> pauliIds = ExtractPauliIds(paulis);
        return GateSet()->Measure(
            count, reinterpret_cast<PauliId*>(pauliIds.data()), count, reinterpret_cast<Qubit*>(qubits->buffer));
    }

    void quantum__qis__r__body(PauliId axis, double angle, QUBIT* qubit)
    {
        return GateSet()->R(axis, qubit, angle);
    }

    void quantum__qis__r__adj(PauliId axis, double angle, QUBIT* qubit)
    {
        quantum__qis__r__body(axis, -angle, qubit);
     }

    void quantum__qis__r__ctl(QirArray* ctls, PauliId axis, double angle, QUBIT* qubit)
    {
        return GateSet()->ControlledR(
            ctls->count, reinterpret_cast<Qubit*>(ctls->buffer), axis, qubit, angle);
    }

    void quantum__qis__r__ctladj(QirArray* ctls, PauliId axis, double angle, QUBIT* qubit)
    {
        quantum__qis__r__ctl(ctls, axis, -angle, qubit);
    }

    void quantum__qis__s__body(Qubit qubit)
    {
        GateSet()->S(qubit);
    }

    void quantum__qis__s__adj(Qubit qubit)
    {
        GateSet()->AdjointS(qubit);
    }

    void quantum__qis__s__ctl(QirArray* ctls, Qubit qubit)
    {
        GateSet()->ControlledS(
            ctls->count, reinterpret_cast<Qubit*>(ctls->buffer), qubit);
    }

    void quantum__qis__s__ctladj(QirArray* ctls, Qubit qubit)
    {
        GateSet()->ControlledAdjointS(
            ctls->count, reinterpret_cast<Qubit*>(ctls->buffer), qubit);
    }

    void quantum__qis__t__body(Qubit qubit)
    {
        GateSet()->T(qubit);
    }

    void quantum__qis__t__adj(Qubit qubit)
    {
        GateSet()->AdjointT(qubit);
    }

    void quantum__qis__t__ctl(QirArray* ctls, Qubit qubit)
    {
        GateSet()->ControlledT(
            ctls->count, reinterpret_cast<Qubit*>(ctls->buffer), qubit);
    }

    void quantum__qis__t__ctladj(QirArray* ctls, Qubit qubit)
    {
        GateSet()->ControlledAdjointT(
            ctls->count, reinterpret_cast<Qubit*>(ctls->buffer), qubit);
    }

    void quantum__qis__x__body(Qubit qubit)
    {
        GateSet()->X(qubit);
    }

    void quantum__qis__x__ctl(QirArray* ctls, Qubit qubit)
    {
        GateSet()->ControlledX(
            ctls->count, reinterpret_cast<Qubit*>(ctls->buffer), qubit);
    }

    void quantum__qis__y__body(Qubit qubit)
    {
        GateSet()->Y(qubit);
    }

    void quantum__qis__y__ctl(QirArray* ctls, Qubit qubit)
    {
        GateSet()->ControlledY(
            ctls->count, reinterpret_cast<Qubit*>(ctls->buffer), qubit);
    }

    void quantum__qis__z__body(Qubit qubit)
    {
        GateSet()->Z(qubit);
    }

    void quantum__qis__z__ctl(QirArray* ctls, Qubit qubit)
    {
        GateSet()->ControlledZ(
            ctls->count, reinterpret_cast<Qubit*>(ctls->buffer), qubit);
    }
}