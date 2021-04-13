// Copyright (c) Microsoft Corporation.

// Shim for using QSharp.Core gate set with the Open System Simulator Rust Implementation

#include <stdexcept>
#include "QirTypes.hpp"

extern "C"
{
    void __quantum__qis__cnot__body(Qubit, Qubit); // NOLINT

    void __quantum__qis__x__ctl(QirArray* controls, Qubit qubit) // NOLINT
    {
        if (controls->count != 1)
        {
            throw std::logic_error("operation_not_supported");
        }
        __quantum__qis__cnot__body(reinterpret_cast<Qubit>(*controls->GetItemPointer(0)), qubit);
    }

    Result __quantum__qis__m__body(Qubit); // NOLINT

    Result __quantum__qis__measure__body(QirArray* paulis, QirArray* qubits) // NOLINT
    {
        if (paulis->count != 1 || static_cast<PauliId>(*paulis->GetItemPointer(0)) != PauliId_Z ||
            qubits->count != 1)
        {
            throw std::logic_error("operation_not_supported");
        }
        return __quantum__qis__m__body(reinterpret_cast<Qubit>(*qubits->GetItemPointer(0)));
    }

    void __quantum__qis__y__ctl(QirArray* controls, Qubit qubit) // NOLINT
    {
        throw std::logic_error("operation_not_supported");
    }
    void __quantum__qis__z__ctl(QirArray* controls, Qubit qubit) // NOLINT
    {
        throw std::logic_error("operation_not_supported");
    }
    void __quantum__qis__h__ctl(QirArray* controls, Qubit qubit) // NOLINT
    {
        throw std::logic_error("operation_not_supported");
    }
    void __quantum__qis__s__ctl(QirArray* controls, Qubit qubit) // NOLINT
    {
        throw std::logic_error("operation_not_supported");
    }
    void __quantum__qis__s__ctladj(QirArray* controls, Qubit qubit) // NOLINT
    {
        throw std::logic_error("operation_not_supported");
    }
    void __quantum__qis__t__ctl(QirArray* controls, Qubit qubit) // NOLINT
    {
        throw std::logic_error("operation_not_supported");
    }
    void __quantum__qis__t__ctladj(QirArray* controls, Qubit qubit) // NOLINT
    {
        throw std::logic_error("operation_not_supported");
    }
}