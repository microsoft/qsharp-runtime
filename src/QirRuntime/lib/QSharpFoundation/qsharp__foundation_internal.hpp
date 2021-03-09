#pragma once

// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// To be included by the QIS implementation and QIS tests only.
// Not to be included by parties outside QIS.

// For test purposes only:
namespace Quantum // Replace with `namespace Quantum::Qis::Internal` after migration to C++17.
{
namespace Qis
{
    namespace Internal
    {
        extern char const excStrDrawRandomInt[];

        void RandomizeSeed(bool randomize);
        int64_t GetLastGeneratedRandomNumber();
    } // namespace Internal
} // namespace Qis
} // namespace Quantum
