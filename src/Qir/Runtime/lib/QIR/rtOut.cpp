// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include <iostream>

#include "QirTypes.hpp"
#include "QirRuntime.hpp"

// Forward declarations:
static std::ostream& GetOutputStream();

// Public API:
extern "C"
{
    void quantum__rt__message(QirString* qstr)   // NOLINT
    {
        GetOutputStream() << qstr->str << std::endl;
    }
}   // extern "C"


// Internal API:
static std::ostream* currentOutputStream = &std::cout; // Log to std::cout by default.

static std::ostream& GetOutputStream()
{
    return *currentOutputStream;
}


namespace Microsoft           // Replace with `namespace Microsoft::Quantum` after migration to C++17.
{
namespace Quantum
{
    std::ostream& SetOutputStream(std::ostream & newOStream)
    {
        std::ostream& oldOStream = *currentOutputStream;
        currentOutputStream = &newOStream;
        return oldOStream;
    }
} // namespace Quantum
} // namespace Microsoft

