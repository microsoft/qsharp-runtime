// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include <iostream>

#include "qirTypes.hpp"
#include "quantum__qis.hpp"

extern "C"
{
    void quantum__qis__message__body(QirString* qstr)   // NOLINT
    {
        std::cout << qstr->str << std::endl;
    }
}   // extern "C"
