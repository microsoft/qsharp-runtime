// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
#include <cstdint>

#define FMT_HEADER_ONLY
#include <fmt/core.h>

#include "QirTypes.hpp"

extern "C"
{
    QirString* quantum__qis__formattedi__body(QirString* fmtstr, uint64_t value) // NOLINT
    {
        return new QirString(fmt::format(fmtstr->str.c_str(), value));
    }
}

/*
#include <iostream>

#include "QirTypes.hpp"
#include "quantum__qis.hpp"

// Forward declarations:
static std::ostream& GetOutputStream();

// Public API:
extern "C"
{
    void quantum__qis__message__body(QirString* qstr)   // NOLINT
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


// For test purposes only:
namespace Quantum           // Replace with `namespace Quantum::Qis::Internal` after migration to C++17.
{
namespace Qis
{
    namespace Internal
    {
        std::ostream& SetOutputStream(std::ostream & newOStream)
        {
            std::ostream& oldOStream = *currentOutputStream;
            currentOutputStream = &newOStream;
            return oldOStream;
        }
    } // namespace Internal
} // namespace Qis
} // namespace Quantum

*/