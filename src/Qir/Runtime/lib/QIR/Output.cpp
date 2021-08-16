#include <ostream> // std::endl
#include "QirTypes.hpp"
#include "QirRuntime.hpp" // QIR_SHARED_API for quantum__rt__message.
#include "OutputStream.hpp"

// Public API:
extern "C"
{
    void quantum__rt__message(QirString* qstr) // NOLINT
    {
        Microsoft::Quantum::OutputStream::Get() << qstr->str << std::endl;
    }
} // extern "C"
