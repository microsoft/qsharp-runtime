#pragma once

// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// To be included by the QIS implementation and QIS tests only.
// Not to be included by parties outside QIS.

#include "CoreTypes.hpp"

// For test purposes only:
namespace Quantum // Replace with `namespace Quantum::Qis::Internal` after migration to C++17.
{
namespace Qis
{
    namespace Internal
    {
        QIR_SHARED_API extern char const excStrDrawRandomVal[];

        QIR_SHARED_API void RandomizeSeed(bool randomize);
        QIR_SHARED_API int64_t GetLastGeneratedRandomI64();
        QIR_SHARED_API double GetLastGeneratedRandomDouble();
    } // namespace Internal
} // namespace Qis
} // namespace Quantum
