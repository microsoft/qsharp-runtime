#pragma once

// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// To be included by the QIS implementation and QIS tests only. 
// Not to be included by parties outside QIS.

#ifdef _WIN32
#define QIR_SHARED_API __declspec(dllexport)
#else
#define QIR_SHARED_API
#endif

// For test purposes only:
namespace Quantum { namespace Qis { namespace Internal  // Replace with `namespace Quantum::Qis::Internal` after migration to C++17.
{
    QIR_SHARED_API extern char const excStrDrawRandomInt[]; // = "Invalid Argument: minimum > maximum for DrawRandomInt()";

    QIR_SHARED_API extern std::ostream& SetOutputStream(std::ostream & newOStream);
    QIR_SHARED_API void UseRandomSeed(bool random);         
}}} // namespace Quantum::Qis::Internal
