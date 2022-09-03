// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#pragma once

#include "QirRuntime.h"
#include <cstdint>

#ifdef _WIN32
#define QIR_EXPORT_API __declspec(dllexport)
#else
#define QIR_EXPORT_API
#endif

/*==============================================================================
  Qubit & Result

  These two types are opaque to the clients: clients cannot directly create, delete,
  copy or check state of qubits and results. QUBIT* and RESULT* should never be
  dereferenced in client's code.
==============================================================================*/

// Although QIR uses an opaque pointer to the type "QUBIT", it never points to an actual memory
// and is never intended to be dereferenced anywhere - in the client code or in our runtime.
// Runtime always operates in terms of qubit ids, which are integers. Qubit ids are casted
// to this pointer type and stored as pointer values. This is done to ensure that qubit type
// is a unique type in the QIR.

class QUBIT;
typedef intptr_t QubitIdType;

class RESULT;

struct QirRTuple
{
    PauliId pauli;
    double angle;
    QUBIT* target;
};

struct QirExpTuple
{
    QirArray* paulis;
    double angle;
    QirArray* targets;
};

struct QirAssertMeasurementProbabilityTuple
{
    QirArray* bases;
    QirArray* qubits;
    RESULT* result;
    double prob;
    QirString* msg;
    double tol;
};

extern "C"
{
    // Quantum Runtime
    QIR_EXPORT_API QUBIT* __quantum__rt__qubit_allocate();                              // NOLINT
    QIR_EXPORT_API QirArray* __quantum__rt__qubit_allocate_array(int64_t count);        // NOLINT
    QIR_EXPORT_API void __quantum__rt__qubit_release(QUBIT*);                           // NOLINT
    QIR_EXPORT_API void __quantum__rt__qubit_release_array(QirArray*);                  // NOLINT
    QIR_EXPORT_API QirString* __quantum__rt__qubit_to_string(QUBIT*);                   // NOLINT
    QIR_EXPORT_API bool __quantum__rt__result_equal(RESULT*, RESULT*);                  // NOLINT
    QIR_EXPORT_API void __quantum__rt__result_update_reference_count(RESULT*, int32_t); // NOLINT
    QIR_EXPORT_API RESULT* __quantum__rt__result_get_one();                             // NOLINT
    QIR_EXPORT_API RESULT* __quantum__rt__result_get_zero();                            // NOLINT
    QIR_EXPORT_API QirString* __quantum__rt__result_to_string(RESULT*);                 // NOLINT
    QIR_EXPORT_API void __quantum__rt__result_record_output(RESULT*);                   // NOLINT

    // Q# Gate Set
    QIR_EXPORT_API void __quantum__qis__exp__body(QirArray*, double, QirArray*); // NOLINT
    QIR_EXPORT_API void __quantum__qis__exp__adj(QirArray*, double, QirArray*);  // NOLINT
    QIR_EXPORT_API void __quantum__qis__exp__ctl(QirArray*, QirExpTuple*);       // NOLINT
    QIR_EXPORT_API void __quantum__qis__exp__ctladj(QirArray*, QirExpTuple*);    // NOLINT
    QIR_EXPORT_API void __quantum__qis__h__body(QUBIT*);                         // NOLINT
    QIR_EXPORT_API void __quantum__qis__h__ctl(QirArray*, QUBIT*);               // NOLINT
    QIR_EXPORT_API RESULT* __quantum__qis__measure__body(QirArray*, QirArray*);  // NOLINT
    QIR_EXPORT_API void __quantum__qis__r__body(PauliId, double, QUBIT*);        // NOLINT
    QIR_EXPORT_API void __quantum__qis__r__adj(PauliId, double, QUBIT*);         // NOLINT
    QIR_EXPORT_API void __quantum__qis__r__ctl(QirArray*, QirRTuple*);           // NOLINT
    QIR_EXPORT_API void __quantum__qis__r__ctladj(QirArray*, QirRTuple*);        // NOLINT
    QIR_EXPORT_API void __quantum__qis__s__body(QUBIT*);                         // NOLINT
    QIR_EXPORT_API void __quantum__qis__s__adj(QUBIT*);                          // NOLINT
    QIR_EXPORT_API void __quantum__qis__s__ctl(QirArray*, QUBIT*);               // NOLINT
    QIR_EXPORT_API void __quantum__qis__s__ctladj(QirArray*, QUBIT*);            // NOLINT
    QIR_EXPORT_API void __quantum__qis__t__body(QUBIT*);                         // NOLINT
    QIR_EXPORT_API void __quantum__qis__t__adj(QUBIT*);                          // NOLINT
    QIR_EXPORT_API void __quantum__qis__t__ctl(QirArray*, QUBIT*);               // NOLINT
    QIR_EXPORT_API void __quantum__qis__t__ctladj(QirArray*, QUBIT*);            // NOLINT
    QIR_EXPORT_API void __quantum__qis__x__body(QUBIT*);                         // NOLINT
    QIR_EXPORT_API void __quantum__qis__x__ctl(QirArray*, QUBIT*);               // NOLINT
    QIR_EXPORT_API void __quantum__qis__y__body(QUBIT*);                         // NOLINT
    QIR_EXPORT_API void __quantum__qis__y__ctl(QirArray*, QUBIT*);               // NOLINT
    QIR_EXPORT_API void __quantum__qis__z__body(QUBIT*);                         // NOLINT
    QIR_EXPORT_API void __quantum__qis__z__ctl(QirArray*, QUBIT*);               // NOLINT

    // Q# Dump:
    // Note: The param `location` must be `const void*`,
    // but it is called from .ll, where `const void*` is not supported.
    QIR_EXPORT_API void __quantum__qis__dumpmachine__body(uint8_t* location);                    // NOLINT
    QIR_EXPORT_API void __quantum__qis__dumpregister__body(uint8_t* location, QirArray* qubits); // NOLINT

    // Q# Assert Measurement:
    QIR_EXPORT_API void __quantum__qis__assertmeasurementprobability__body( // NOLINT
        QirArray* bases,
        QirArray* qubits,
        RESULT* result,
        double prob,
        QirString* msg,
        double tol);
    QIR_EXPORT_API void __quantum__qis__assertmeasurementprobability__ctl( // NOLINT
        QirArray* ctls,
        QirAssertMeasurementProbabilityTuple* args);
}
