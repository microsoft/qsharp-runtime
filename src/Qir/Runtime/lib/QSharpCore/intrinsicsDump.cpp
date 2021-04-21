#include "QirContext.hpp"
#include "QSharpSimApi_I.hpp"
#include "QirRuntimeApi_I.hpp"
#include "qsharp__core__qis.hpp"

static Microsoft::Quantum::IDiagnostics* GetDiagnostics()
{
    return dynamic_cast<Microsoft::Quantum::IDiagnostics*>(Microsoft::Quantum::GlobalContext()->GetDriver());
}

// Implementation:
extern "C"
{
    void quantum__qis__dumpmachine__body(uint8_t* location)
    {
        GetDiagnostics()->DumpMachine(location);
    }

    void quantum__qis__dumpregister__body(uint8_t* location, const QirArray* qubits)
    {
        GetDiagnostics()->DumpRegister(location, qubits);
    }
} // extern "C"
