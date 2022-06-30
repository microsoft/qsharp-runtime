#ifndef IBMQ_QIS_HPP
#define IBMQ_QIS_HPP

#include "CoreTypes.hpp"

// declare %Result* @__quantum__qis__m__body(%Qubit*)

// declare void @__quantum__qis__cnot__body(%Qubit*, %Qubit*)
// declare void @__quantum__qis__sqrtx__body(%Qubit*)
// declare void @__quantum__qis__rz__body(double, %Qubit*)
// declare void @__quantum__qis__x__body(%Qubit*)               // Already

extern "C"
{

    Result __quantum__qis__m__body(QUBIT* qubit); // NOLINT

    void __quantum__qis__sqrtx__body(QUBIT* qubit);  // NOLINT
    void __quantum__qis__cnot__body(QUBIT*, QUBIT*); // NOLINT
    void __quantum__qis__rz__body(double, QUBIT*);   // NOLINT

} // extern "C"

#endif
