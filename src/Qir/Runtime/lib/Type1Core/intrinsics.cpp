// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

/*=============================================================================
    QIR assumes a single global execution context.
    To support the dispatch over the qir-bridge, the clients must register their
    Microsoft::Quantum::IRuntimeDriver* first.
=============================================================================*/
#include <cassert>
#include <vector>

#include "type1__core__qis.hpp"

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
    void quantum__qis__h__body(Qubit qubit)
    {
        GateSet()->H(qubit);
    }

    Result quantum__qis__m__body(Qubit qubit)
    {
        const long count = 1;
        PauliId pauliZ = PauliId_Z;

        return GateSet()->Measure(
            count, &pauliZ, count, &qubit);
    }

    void quantum__qis__rx__body(double angle, QUBIT* qubit)
    {
        return GateSet()->R(PauliId_X, qubit, angle);
    }

    void quantum__qis__ry__body(double angle, QUBIT* qubit)
    {
        return GateSet()->R(PauliId_Y, qubit, angle);
    }

    void quantum__qis__rz__body(double angle, QUBIT* qubit)
    {
        return GateSet()->R(PauliId_Z, qubit, angle);
    }

    void quantum__qis__s__body(Qubit qubit)
    {
        GateSet()->S(qubit);
    }

    void quantum__qis__s__adj(Qubit qubit)
    {
        GateSet()->AdjointS(qubit);
    }

    void quantum__qis__t__body(Qubit qubit)
    {
        GateSet()->T(qubit);
    }

    void quantum__qis__t__adj(Qubit qubit)
    {
        GateSet()->AdjointT(qubit);
    }

    void quantum__qis__x__body(Qubit qubit)
    {
        GateSet()->X(qubit);
    }

    void quantum__qis__x__ctl(Qubit ctl, Qubit qubit)
    {
        GateSet()->ControlledX(
            1, &ctl, qubit);
    }

    void quantum__qis__y__body(Qubit qubit)
    {
        GateSet()->Y(qubit);
    }

    void quantum__qis__z__body(Qubit qubit)
    {
        GateSet()->Z(qubit);
    }

    void quantum__qis__z__ctl(Qubit ctl, Qubit qubit)
    {
        GateSet()->ControlledZ(
            1, &ctl, qubit);
    }

    void quantum__qis__reset__body(Qubit qubit)
    {
        auto res = quantum__qis__m__body(qubit);
        auto driver = Microsoft::Quantum::GlobalContext()->GetDriver();
        if (driver->AreEqualResults(res, driver->UseOne()))
        {
            quantum__qis__x__body(qubit);
        }
    }
}