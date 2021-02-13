// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include <iostream>

#include "qirTypes.hpp"
#include "quantum__qis.hpp"

namespace
{
    std::ostream * currOStream = &std::cout;

    std::ostream& GetQOstream()
    {
        return *currOStream;
    }

} // namespace

std::ostream& SetQOstream(std::ostream & newOStream)
{
    std::ostream& oldOStream = *currOStream;
    currOStream = &newOStream;
    return oldOStream;
}

extern "C"
{
    void quantum__qis__message__body(QirString* qstr)   // NOLINT
    {
        GetQOstream() << qstr->str << std::endl;
    }
}   // extern "C"
