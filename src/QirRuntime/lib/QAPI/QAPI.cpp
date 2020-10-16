#include <assert.h>
#include <vector>

#include "QAPI.hpp"

#include "IQuantumApi.hpp"
#include "SimFactory.hpp"
#include "__quantum__rt.hpp"

using namespace std;
using namespace Microsoft::Quantum;

static IQuantumApi* GetQuantumExecutor(QuantumExecutionContext* context)
{
    return reinterpret_cast<IQuantumApi*>(context->hQuantumApi);
}

QuantumExecutionContext* QAPI_CreateContext_Toffoli() // NOLINT
{
    unique_ptr<IQuantumApi> qapi = CreateToffoliSimulator();
    SetCurrentQuantumApiForQIR(qapi.get());
    return new QuantumExecutionContext{reinterpret_cast<uint64_t>(qapi.release())};
}

QuantumExecutionContext* QAPI_CreateContext_Fullstate() // NOLINT
{
    unique_ptr<IQuantumApi> qapi = CreateFullstateSimulator();
    SetCurrentQuantumApiForQIR(qapi.get());
    return new QuantumExecutionContext{reinterpret_cast<uint64_t>(qapi.release())};
}

void QAPI_DestroyContext(QuantumExecutionContext* context) // NOLINT
{
    SetCurrentQuantumApiForQIR(nullptr);
    delete GetQuantumExecutor(context);
    delete context;
    context = nullptr;
}

// Qubit management
EXPORTQAPI Qubit QAPI_AllocateQubit(QuantumExecutionContext* context) // NOLINT
{
    return GetQuantumExecutor(context)->AllocateQubit();
}
EXPORTQAPI void QAPI_ReleaseQubit(QuantumExecutionContext* context, Qubit qubit) // NOLINT
{
    GetQuantumExecutor(context)->ReleaseQubit(qubit);
}

// Results
EXPORTQAPI void QAPI_ReleaseResult(QuantumExecutionContext* context, Result result) // NOLINT
{
    GetQuantumExecutor(context)->ReleaseResult(result);
}
EXPORTQAPI TernaryBool QAPI_AreEqualResults(QuantumExecutionContext* context, Result r1, Result r2) // NOLINT
{
    return GetQuantumExecutor(context)->AreEqualResults(r1, r2);
}
EXPORTQAPI ResultValue QAPI_GetResultValue(QuantumExecutionContext* context, Result result) // NOLINT
{
    return GetQuantumExecutor(context)->GetResultValue(result);
}
EXPORTQAPI Result QAPI_UseZero(QuantumExecutionContext* context) // NOLINT
{
    return GetQuantumExecutor(context)->UseZero();
}
EXPORTQAPI Result QAPI_UseOne(QuantumExecutionContext* context) // NOLINT
{
    return GetQuantumExecutor(context)->UseOne();
}

// Shortcuts
EXPORTQAPI void QAPI_CNOT(QuantumExecutionContext* context, Qubit control, Qubit target) // NOLINT
{
    GetQuantumExecutor(context)->CNOT(control, target);
}

EXPORTQAPI void QAPI_CX(QuantumExecutionContext* context, Qubit control, Qubit target) // NOLINT
{
    GetQuantumExecutor(context)->CX(control, target);
}

EXPORTQAPI void QAPI_CY(QuantumExecutionContext* context, Qubit control, Qubit target) // NOLINT
{
    GetQuantumExecutor(context)->CY(control, target);
}

EXPORTQAPI void QAPI_CZ(QuantumExecutionContext* context, Qubit control, Qubit target) // NOLINT
{
    GetQuantumExecutor(context)->CZ(control, target);
}

// Elementary operatons
EXPORTQAPI void QAPI_X(QuantumExecutionContext* context, Qubit target) // NOLINT
{
    GetQuantumExecutor(context)->X(target);
}

EXPORTQAPI void QAPI_Y(QuantumExecutionContext* context, Qubit target) // NOLINT
{
    GetQuantumExecutor(context)->Y(target);
}

EXPORTQAPI void QAPI_Z(QuantumExecutionContext* context, Qubit target) // NOLINT
{
    GetQuantumExecutor(context)->Z(target);
}

EXPORTQAPI void QAPI_H(QuantumExecutionContext* context, Qubit target) // NOLINT
{
    GetQuantumExecutor(context)->H(target);
}

EXPORTQAPI void QAPI_S(QuantumExecutionContext* context, Qubit target) // NOLINT
{
    GetQuantumExecutor(context)->S(target);
}

EXPORTQAPI void QAPI_T(QuantumExecutionContext* context, Qubit target) // NOLINT
{
    GetQuantumExecutor(context)->T(target);
}

EXPORTQAPI void QAPI_SWAP(QuantumExecutionContext* context, Qubit target1, Qubit target2) // NOLINT
{
    GetQuantumExecutor(context)->SWAP(target1, target2);
}

EXPORTQAPI void QAPI_Clifford( // NOLINT
    QuantumExecutionContext* context,
    CliffordId cliffordId,
    PauliId pauli,
    Qubit target)
{
    GetQuantumExecutor(context)->Clifford(cliffordId, pauli, target);
}

EXPORTQAPI void QAPI_Unitary( // NOLINT
    QuantumExecutionContext* context,
    long numTargets,
    double** unitary,
    Qubit targets[])
{
    GetQuantumExecutor(context)->Unitary(numTargets, unitary, targets);
}

EXPORTQAPI Result QAPI_M(QuantumExecutionContext* context, Qubit target) // NOLINT
{
    return GetQuantumExecutor(context)->M(target);
}

EXPORTQAPI Result QAPI_Measure( // NOLINT
    QuantumExecutionContext* context,
    long numBases,
    PauliId bases[],
    long numTargets,
    Qubit targets[])
{
    return GetQuantumExecutor(context)->Measure(numBases, bases, numTargets, targets);
}

EXPORTQAPI void QAPI_Reset(QuantumExecutionContext* context, Qubit target) // NOLINT
{
    GetQuantumExecutor(context)->Reset(target);
}

EXPORTQAPI void QAPI_ControlledX( // NOLINT
    QuantumExecutionContext* context,
    long numControls,
    Qubit controls[],
    Qubit target)
{
    GetQuantumExecutor(context)->ControlledX(numControls, controls, target);
}

EXPORTQAPI void QAPI_ControlledY( // NOLINT
    QuantumExecutionContext* context,
    long numControls,
    Qubit controls[],
    Qubit target)
{
    GetQuantumExecutor(context)->ControlledY(numControls, controls, target);
}

EXPORTQAPI void QAPI_ControlledZ( // NOLINT
    QuantumExecutionContext* context,
    long numControls,
    Qubit controls[],
    Qubit target)
{
    GetQuantumExecutor(context)->ControlledZ(numControls, controls, target);
}

EXPORTQAPI void QAPI_ControlledH( // NOLINT
    QuantumExecutionContext* context,
    long numControls,
    Qubit controls[],
    Qubit target)
{
    GetQuantumExecutor(context)->ControlledH(numControls, controls, target);
}

EXPORTQAPI void QAPI_ControlledS( // NOLINT
    QuantumExecutionContext* context,
    long numControls,
    Qubit controls[],
    Qubit target)
{
    GetQuantumExecutor(context)->ControlledS(numControls, controls, target);
}

EXPORTQAPI void QAPI_ControlledT( // NOLINT
    QuantumExecutionContext* context,
    long numControls,
    Qubit controls[],
    Qubit target)
{
    GetQuantumExecutor(context)->ControlledT(numControls, controls, target);
}

EXPORTQAPI void QAPI_ControlledSWAP( // NOLINT
    QuantumExecutionContext* context,
    long numControls,
    Qubit controls[],
    Qubit target1,
    Qubit target2)
{
    GetQuantumExecutor(context)->ControlledSWAP(numControls, controls, target1, target2);
}

EXPORTQAPI void QAPI_ControlledR( // NOLINT
    QuantumExecutionContext* context,
    long numControls,
    Qubit controls[],
    PauliId axis,
    Qubit target,
    double theta)
{
    GetQuantumExecutor(context)->ControlledR(numControls, controls, axis, target, theta);
}
