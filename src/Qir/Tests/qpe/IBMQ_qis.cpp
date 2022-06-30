#include "CoreTypes.hpp"
#include "QirTypes.hpp"
#include "QirRuntime.hpp"
#include "qsharp__core__qis.hpp"

#include "IBMQ_qis.hpp"

extern "C"
{

    Result __quantum__qis__m__body(QUBIT* qubit) // NOLINT
    {
        QirArray* target = __quantum__rt__array_create_1d(sizeof(QUBIT*), 1);
        QirArray* paulis = __quantum__rt__array_create_1d(sizeof(PauliId), 1);

#pragma clang diagnostic push
    // Temporarily disable `-Wcast-align` 
    // (cast from 'char *' to 'QUBIT **' increases required alignment from 1 to 8 [-Werror,-Wcast-align]).
    #pragma clang diagnostic ignored "-Wcast-align"

        // *(QUBIT**)__quantum__rt__array_get_element_ptr_1d(target, 0) = qubit;
        QUBIT** targetPtr = (QUBIT**)__quantum__rt__array_get_element_ptr_1d(target, 0);
        *targetPtr = qubit;

        // *__quantum__rt__array_get_element_ptr_1d(paulis, 0)          = PauliId_Z;
        PauliId* pauliPtr = (PauliId*)__quantum__rt__array_get_element_ptr_1d(paulis, 0);
        *pauliPtr = PauliId_Z;

#pragma clang diagnostic pop

        auto res = __quantum__qis__measure__body(paulis, target);

        __quantum__rt__array_update_reference_count(target, -1);
        __quantum__rt__array_update_reference_count(paulis, -1);

        return res;
    }

    void __quantum__qis__sqrtx__body(QUBIT* qubit) // NOLINT
    {
        __quantum__qis__h__body(qubit);
        __quantum__qis__s__body(qubit);
        __quantum__qis__h__body(qubit);
    }

    void __quantum__qis__cnot__body(QUBIT* controlQ, QUBIT* qubit) // NOLINT
    {
        QirArray* controlQubit = __quantum__rt__array_create_1d(sizeof(QUBIT*), 1);

#pragma clang diagnostic push
    // Temporarily disable `-Wcast-align` 
    // (cast from 'char *' to 'QUBIT **' increases required alignment from 1 to 8 [-Werror,-Wcast-align]).
    #pragma clang diagnostic ignored "-Wcast-align"

        // *(QUBIT**)__quantum__rt__array_get_element_ptr_1d(controlQubit, 0) = controlQ;
        QUBIT** controlQubitPtr = (QUBIT**)__quantum__rt__array_get_element_ptr_1d(controlQubit, 0);
        *controlQubitPtr = controlQ;
#pragma clang diagnostic pop

        __quantum__qis__x__ctl(controlQubit, qubit);

        __quantum__rt__array_update_reference_count(controlQubit, -1);
    }

    void __quantum__qis__rz__body(double angle, QUBIT* qubit) // NOLINT
    {
        __quantum__qis__r__body(PauliId_Z, angle, qubit);
    }

} // extern "C"
