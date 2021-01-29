// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

/*=============================================================================
    QIR assumes a single global execution context.
    To support the dispatch over the qir-bridge, the clients must register their
    Microsoft::Quantum::ISimulator* first.
=============================================================================*/
#include <assert.h>
#include <vector>

#include "quantum__qis.hpp"

#include "QuantumApi_I.hpp"
#include "context.hpp"
#include "qirTypes.hpp"

extern "C"
{
    double quantum__qis__intAsDouble(long value)
    {
        assert(value == static_cast<int32_t>(value));
        return static_cast<double>(value);
    }

    void quantum__qis__cnot(Qubit control, Qubit qubit)
    {
        Microsoft::Quantum::g_context->simulator->AsQuantumGateSet()->ControlledX(1, &control, qubit);
    }

    void quantum__qis__h(Qubit qubit)
    {
        Microsoft::Quantum::g_context->simulator->AsQuantumGateSet()->H(qubit);
    }

    Result quantum__qis__measure(QirArray* paulis, QirArray* qubits)
    {
        const long count = qubits->count;
        assert(count == paulis->count);

        // Pauli consts are {i2} in QIR, but we are using the standard C++ enum type so cannot pass through the
        // buffer and have to allocate a new one instead.
        std::vector<PauliId> pauliIds;
        pauliIds.reserve(count);
        for (int i = 0; i < count; i++)
        {
            pauliIds.push_back(static_cast<PauliId>(*paulis->GetItemPointer(i)));
        }

        return Microsoft::Quantum::g_context->simulator->Measure(
            count, reinterpret_cast<PauliId*>(pauliIds.data()), count, reinterpret_cast<Qubit*>(qubits->buffer));
    }

    Result quantum__qis__mz(Qubit qubit)
    {
        return Microsoft::Quantum::g_context->simulator->M(qubit);
    }

    void quantum__qis__s(Qubit qubit)
    {
        Microsoft::Quantum::g_context->simulator->AsQuantumGateSet()->S(qubit);
    }

    void quantum__qis__t(Qubit qubit)
    {
        Microsoft::Quantum::g_context->simulator->AsQuantumGateSet()->T(qubit);
    }

    void quantum__qis__rx(double theta, Qubit qubit)
    {
        Microsoft::Quantum::g_context->simulator->AsQuantumGateSet()->R(PauliId_X, qubit, theta);
    }

    void quantum__qis__ry(double theta, Qubit qubit)
    {
        Microsoft::Quantum::g_context->simulator->AsQuantumGateSet()->R(PauliId_Y, qubit, theta);
    }

    void quantum__qis__rz(double theta, Qubit qubit)
    {
        Microsoft::Quantum::g_context->simulator->AsQuantumGateSet()->R(PauliId_Z, qubit, theta);
    }

    void quantum__qis__x(Qubit qubit)
    {
        Microsoft::Quantum::g_context->simulator->AsQuantumGateSet()->X(qubit);
    }

    void quantum__qis__y(Qubit qubit)
    {
        Microsoft::Quantum::g_context->simulator->AsQuantumGateSet()->Y(qubit);
    }

    void quantum__qis__z(Qubit qubit)
    {
        Microsoft::Quantum::g_context->simulator->AsQuantumGateSet()->Z(qubit);
    }

    void quantum__qis__crx(QirArray* ctls, double theta, Qubit qubit)
    {
        Microsoft::Quantum::g_context->simulator->AsQuantumGateSet()->ControlledR(
            ctls->count, reinterpret_cast<Qubit*>(ctls->buffer), PauliId_X, qubit, theta);
    }

    void quantum__qis__crz(QirArray* ctls, double theta, Qubit qubit)
    {
        Microsoft::Quantum::g_context->simulator->AsQuantumGateSet()->ControlledR(
            ctls->count, reinterpret_cast<Qubit*>(ctls->buffer), PauliId_Z, qubit, theta);
    }
}