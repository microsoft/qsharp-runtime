// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include "QirTypes.hpp"
#include "QirRuntime.hpp" // QIR_SHARED_API for quantum__rt__message.
#include "OutputStream.hpp"
#include "QirOutputHandling.hpp"

// Public API:
extern "C"
{
    void __quantum__rt__message(QirString* qstr) // NOLINT
    {
        std::ostream& currentOutputStream = Microsoft::Quantum::OutputStream::Get();
        currentOutputStream << qstr->str << QOH_REC_DELIMITER;
        currentOutputStream.flush();
    }
} // extern "C"
