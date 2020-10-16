/*=============================================================================
    QIR assumes a single global execution context.
    To support the dispatch over the qir-bridge, the clients must register their
    Microsoft::Quantum::IQuantumApi* first.
=============================================================================*/
#include <assert.h>
#include <vector>

#include "__quantum__qis.hpp"

#include "IQuantumApi.hpp"
#include "qirTypes.hpp"

extern Microsoft::Quantum::IQuantumApi* g_qapi;

extern "C"
{
    Result UseZero()
    {
        return g_qapi->UseZero();
    }

    Result UseOne()
    {
        return g_qapi->UseOne();
    }

    double quantum__qis__intAsDouble(long value)
    {
        assert(value == static_cast<int32_t>(value));
        return static_cast<double>(value);
    }

    void quantum__qis__cnot(Qubit control, Qubit qubit)
    {
        g_qapi->ControlledX(1, &control, qubit);
    }

    void quantum__qis__h(Qubit qubit)
    {
        g_qapi->H(qubit);
    }

    Result quantum__qis__measure(QirArray* paulis, QirArray* qubits)
    {
        assert(!paulis->containsQubits);
        assert(qubits->containsQubits);

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

        return g_qapi->Measure(
            count, reinterpret_cast<PauliId*>(pauliIds.data()), count, reinterpret_cast<Qubit*>(qubits->buffer));
    }

    Result quantum__qis__mz(Qubit qubit)
    {
        return g_qapi->M(qubit);
    }

    void quantum__qis__s(Qubit qubit)
    {
        g_qapi->S(qubit);
    }

    void quantum__qis__t(Qubit qubit)
    {
        g_qapi->T(qubit);
    }

    void quantum__qis__rx(double theta, Qubit qubit)
    {
        g_qapi->R(PauliId_X, qubit, theta);
    }

    void quantum__qis__ry(double theta, Qubit qubit)
    {
        g_qapi->R(PauliId_Y, qubit, theta);
    }

    void quantum__qis__rz(double theta, Qubit qubit)
    {
        g_qapi->R(PauliId_Z, qubit, theta);
    }

    void quantum__qis__x(Qubit qubit)
    {
        g_qapi->X(qubit);
    }

    void quantum__qis__y(Qubit qubit)
    {
        g_qapi->Y(qubit);
    }

    void quantum__qis__z(Qubit qubit)
    {
        g_qapi->Z(qubit);
    }
}