// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include <iostream>

#include "qirTypes.hpp"
#include "quantum__qis.hpp"

// Forward declarations:
static std::ostream& GetQOstream();

// Public API:
extern "C"
{
    void quantum__qis__message__body(QirString* qstr)   // NOLINT
    {
        GetQOstream() << qstr->str << std::endl;
    }
}   // extern "C"


// Internal API:
static  std::ostream * currOStream = &std::cout;    // Log to std::cout by default.

static  std::ostream& GetQOstream()
{
    return *currOStream;
}


// For test purposes only:
namespace Quantum { namespace Qis { namespace Internal  // Replace with `namespace Quantum::Qis::Internal` after migration to C++17.
{

std::ostream& SetOutputStream(std::ostream & newOStream)
{
    std::ostream& oldOStream = *currOStream;
    currOStream = &newOStream;
    return oldOStream;
}

}}} // namespace Quantum::Qis::Internal

