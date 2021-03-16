// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include "QirRuntimeApi_I.hpp"
#include "SimFactory.hpp"
#include "QirContext.hpp"
#include "QirTypes.hpp"

#ifdef _WIN32
#define EXPORTAPI extern "C" __declspec(dllexport)
#else
#define EXPORTAPI extern "C"
#endif
EXPORTAPI void SetupQirToRunOnFullStateSimulator()
{
    // Leak the simulator, because the QIR only creates one and it will exist for the duration of the session
    InitializeQirContext(Microsoft::Quantum::CreateFullstateSimulator().release(), false /*trackAllocatedObjects*/);
}