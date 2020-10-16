#pragma once

#include <stdint.h>

#include "CoreTypes.hpp"

#ifdef _WIN32
#define EXPORTQAPI extern "C" __declspec(dllexport)
#else
#define EXPORTQAPI extern "C"
#endif

typedef uint64_t QAPI_HANDLE;

// QuantumExecutionContext collects handles to internal interfaces, used to drive execution.
// The meaning of handles in the array is defined by the concrete type of the main quantum api target.
struct QuantumExecutionContext
{
    QAPI_HANDLE hQuantumApi;
    // anything else?
};

// Factory methods for various simulators we provide.
EXPORTQAPI QuantumExecutionContext* QAPI_CreateContext_Toffoli();   // NOLINT
EXPORTQAPI QuantumExecutionContext* QAPI_CreateContext_Fullstate(); // NOLINT

EXPORTQAPI void QAPI_DestroyContext(QuantumExecutionContext* context); // NOLINT

// Qubit management
EXPORTQAPI Qubit QAPI_AllocateQubit(QuantumExecutionContext* context);            // NOLINT
EXPORTQAPI void QAPI_ReleaseQubit(QuantumExecutionContext* context, Qubit qubit); // NOLINT

// Results
EXPORTQAPI void ReleaseResult(QuantumExecutionContext* context, Result result);                 // NOLINT
EXPORTQAPI TernaryBool AreEqualResults(QuantumExecutionContext* context, Result r1, Result r2); // NOLINT
EXPORTQAPI ResultValue GetResultValue(QuantumExecutionContext* context, Result result);         // NOLINT
EXPORTQAPI Result UseZero(QuantumExecutionContext* context);                                    // NOLINT
EXPORTQAPI Result UseOne(QuantumExecutionContext* context);                                     // NOLINT

// Shortcuts
EXPORTQAPI void QAPI_CNOT(QuantumExecutionContext* context, Qubit control, Qubit target); // NOLINT
EXPORTQAPI void QAPI_CX(QuantumExecutionContext* context, Qubit control, Qubit target);   // NOLINT
EXPORTQAPI void QAPI_CY(QuantumExecutionContext* context, Qubit control, Qubit target);   // NOLINT
EXPORTQAPI void QAPI_CZ(QuantumExecutionContext* context, Qubit control, Qubit target);   // NOLINT

// Elementary operatons
EXPORTQAPI void QAPI_X(QuantumExecutionContext* context, Qubit target);                    // NOLINT
EXPORTQAPI void QAPI_Y(QuantumExecutionContext* context, Qubit target);                    // NOLINT
EXPORTQAPI void QAPI_Z(QuantumExecutionContext* context, Qubit target);                    // NOLINT
EXPORTQAPI void QAPI_H(QuantumExecutionContext* context, Qubit target);                    // NOLINT
EXPORTQAPI void QAPI_S(QuantumExecutionContext* context, Qubit target);                    // NOLINT
EXPORTQAPI void QAPI_T(QuantumExecutionContext* context, Qubit target);                    // NOLINT
EXPORTQAPI void QAPI_SWAP(QuantumExecutionContext* context, Qubit target1, Qubit target2); // NOLINT
EXPORTQAPI void QAPI_Clifford(                                                             // NOLINT
    QuantumExecutionContext* context,
    CliffordId cliffordId,
    PauliId pauli,
    Qubit target);
EXPORTQAPI void QAPI_Unitary( // NOLINT
    QuantumExecutionContext* context,
    long numTargets,
    double** unitary,
    Qubit targets[]);

EXPORTQAPI Result QAPI_M(QuantumExecutionContext* context, Qubit target); // NOLINT
EXPORTQAPI Result QAPI_Measure(                                           // NOLINT
    QuantumExecutionContext* context,
    long numBases,
    PauliId bases[],
    long numTargets,
    Qubit targets[]);
EXPORTQAPI void QAPI_Reset(QuantumExecutionContext* context, Qubit target); // NOLINT

EXPORTQAPI void QAPI_R(QuantumExecutionContext* context, PauliId axis, Qubit target, double theta); // NOLINT
EXPORTQAPI void QAPI_RFraction(                                                                     // NOLINT
    QuantumExecutionContext* context,
    PauliId axis,
    Qubit target,
    long numerator,
    int power);
EXPORTQAPI void QAPI_R1(QuantumExecutionContext* context, Qubit target, double theta);                      // NOLINT
EXPORTQAPI void QAPI_R1Fraction(QuantumExecutionContext* context, Qubit target, long numerator, int power); // NOLINT
EXPORTQAPI void QAPI_Exp(                                                                                   // NOLINT
    QuantumExecutionContext* context,
    long numTargets,
    PauliId paulis[],
    Qubit targets[],
    double theta);
EXPORTQAPI void QAPI_ExpFraction( // NOLINT
    QuantumExecutionContext* context,
    long numTargets,
    PauliId paulis[],
    Qubit targets[],
    long numerator,
    int power);

// Multicontrolled operations
EXPORTQAPI void QAPI_ControlledX( // NOLINT
    QuantumExecutionContext* context,
    long numControls,
    Qubit controls[],
    Qubit target);
EXPORTQAPI void QAPI_ControlledY( // NOLINT
    QuantumExecutionContext* context,
    long numControls,
    Qubit controls[],
    Qubit target);
EXPORTQAPI void QAPI_ControlledZ( // NOLINT
    QuantumExecutionContext* context,
    long numControls,
    Qubit controls[],
    Qubit target);
EXPORTQAPI void QAPI_ControlledH( // NOLINT
    QuantumExecutionContext* context,
    long numControls,
    Qubit controls[],
    Qubit target);
EXPORTQAPI void QAPI_ControlledS( // NOLINT
    QuantumExecutionContext* context,
    long numControls,
    Qubit controls[],
    Qubit target);
EXPORTQAPI void QAPI_ControlledT( // NOLINT
    QuantumExecutionContext* context,
    long numControls,
    Qubit controls[],
    Qubit target);
EXPORTQAPI void QAPI_ControlledSWAP( // NOLINT
    QuantumExecutionContext* context,
    long numControls,
    Qubit controls[],
    Qubit target1,
    Qubit target2);
EXPORTQAPI void QAPI_ControlledClifford( // NOLINT
    QuantumExecutionContext* context,
    long numControls,
    Qubit controls[],
    CliffordId cliffordId,
    PauliId pauli,
    Qubit target);
EXPORTQAPI void QAPI_ControlledUnitary( // NOLINT
    QuantumExecutionContext* context,
    long numControls,
    Qubit controls[],
    long numTargets,
    double** unitary,
    Qubit targets[]);

EXPORTQAPI void QAPI_ControlledR( // NOLINT
    QuantumExecutionContext* context,
    long numControls,
    Qubit controls[],
    PauliId axis,
    Qubit target,
    double theta);
EXPORTQAPI void QAPI_ControlledRFraction( // NOLINT
    QuantumExecutionContext* context,
    long numControls,
    Qubit controls[],
    PauliId axis,
    Qubit target,
    long numerator,
    int power);
EXPORTQAPI void QAPI_ControlledR1( // NOLINT
    QuantumExecutionContext* context,
    long numControls,
    Qubit controls[],
    Qubit target,
    double theta);
EXPORTQAPI void QAPI_ControlledR1Fraction( // NOLINT
    QuantumExecutionContext* context,
    long numControls,
    Qubit controls[],
    Qubit target,
    long numerator,
    int power);
EXPORTQAPI void QAPI_ControlledExp( // NOLINT
    QuantumExecutionContext* context,
    long numControls,
    Qubit controls[],
    long numTargets,
    PauliId paulis[],
    Qubit targets[],
    double theta);
EXPORTQAPI void QAPI_ControlledExpFraction( // NOLINT
    QuantumExecutionContext* context,
    long numControls,
    Qubit controls[],
    long numTargets,
    PauliId paulis[],
    Qubit targets[],
    long numerator,
    int power);

// Adjoint operations
EXPORTQAPI void QAPI_SAdjoint(QuantumExecutionContext* context, Qubit target); // NOLINT
EXPORTQAPI void QAPI_TAdjoint(QuantumExecutionContext* context, Qubit target); // NOLINT
EXPORTQAPI void QAPI_ControlledSAdjoint(                                       // NOLINT
    QuantumExecutionContext* context,
    long numControls,
    Qubit controls[],
    Qubit target);
EXPORTQAPI void QAPI_ControlledTAdjoint( // NOLINT
    QuantumExecutionContext* context,
    long numControls,
    Qubit controls[],
    Qubit target);

EXPORTQAPI void QAPI_Assert( // NOLINT
    QuantumExecutionContext* context,
    long numTargets,
    PauliId bases[],
    Qubit targets[],
    Result result,
    char* failureMessage);
EXPORTQAPI void QAPI_AssertProbability( // NOLINT
    QuantumExecutionContext* context,
    long numTargets,
    PauliId bases[],
    Qubit targets[],
    double probabilityOfZero,
    double precision,
    char* failureMessage);
