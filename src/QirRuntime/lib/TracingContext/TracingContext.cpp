// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include <algorithm>
#include <assert.h>
#include <iostream>

#include "QAPI.hpp"
#include "ResourceStatistics.hpp"

using namespace Microsoft::Quantum;
ResourceStatistics g_stats;

void QAPI_DestroyContext(QuantumExecutionContext* context) // NOLINT
{
    assert(context == nullptr);

    std::ostringstream os;
    g_stats.Print(os);
    std::cout << os.str();
    g_stats = {0};
}

// Qubit management
EXPORTQAPI Qubit QAPI_AllocateQubit(QuantumExecutionContext*) // NOLINT
{
    g_stats.cQubits++;
    g_stats.cQubitWidth = std::max(g_stats.cQubitWidth, g_stats.cQubits);
    return nullptr;
}
EXPORTQAPI void QAPI_ReleaseQubit(QuantumExecutionContext*, Qubit qubit) // NOLINT
{
    g_stats.cQubits--;
}

EXPORTQAPI void QAPI_CNOT(QuantumExecutionContext*, Qubit control, Qubit target) // NOLINT
{
    g_stats.cCX++;
}

EXPORTQAPI void QAPI_CX(QuantumExecutionContext*, Qubit control, Qubit target) // NOLINT
{
    g_stats.cCX++;
}

EXPORTQAPI void QAPI_X(QuantumExecutionContext*, Qubit target) // NOLINT
{
    g_stats.cX++;
}

EXPORTQAPI void QAPI_ControlledX( // NOLINT
    QuantumExecutionContext*,
    long numControls,
    Qubit controls[],
    Qubit target)
{
    g_stats.cCX++;
}

EXPORTQAPI void QAPI_Y(QuantumExecutionContext*, Qubit target) // NOLINT
{
    g_stats.cY++;
}

EXPORTQAPI void QAPI_ControlledY( // NOLINT
    QuantumExecutionContext*,
    long numControls,
    Qubit controls[],
    Qubit target)
{
    g_stats.cCY++;
}

EXPORTQAPI void QAPI_H(QuantumExecutionContext*, Qubit target) // NOLINT
{
    g_stats.cH++;
}

EXPORTQAPI void QAPI_ControlledH( // NOLINT
    QuantumExecutionContext*,
    long numControls,
    Qubit controls[],
    Qubit target)
{
    g_stats.cCH++;
}

EXPORTQAPI void QAPI_R( // NOLINT
    QuantumExecutionContext*,
    PauliId axis,
    Qubit target,
    double theta)
{
    g_stats.cR++;
}

EXPORTQAPI void QAPI_ControlledR( // NOLINT
    QuantumExecutionContext*,
    long numControls,
    Qubit controls[],
    PauliId axis,
    Qubit target,
    double theta)
{
    g_stats.cCR++;
}
