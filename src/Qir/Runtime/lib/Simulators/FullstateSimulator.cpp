// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include <cassert>
#include <bitset>
#include <complex>
#include <exception>
#include <iostream>
#include <memory>
#include <vector>
#include <fstream>

#include "capi.hpp"

#include "QirTypes.hpp"
#include "QirRuntime.hpp"
#include "QirRuntimeApi_I.hpp"
#include "QSharpSimApi_I.hpp"
#include "SimFactory.hpp"
#include "OutputStream.hpp"

using namespace std;

#ifdef _WIN32
#include <windows.h>
typedef HMODULE QUANTUM_SIMULATOR;
#else // not _WIN32
#include <dlfcn.h>
typedef void* QUANTUM_SIMULATOR;
#endif

namespace
{
#ifdef _WIN32
const char* FULLSTATESIMULATORLIB = "Microsoft.Quantum.Simulator.Runtime.dll";
#elif __APPLE__
const char* FULLSTATESIMULATORLIB = "libMicrosoft.Quantum.Simulator.Runtime.dylib";
#else
const char* FULLSTATESIMULATORLIB = "libMicrosoft.Quantum.Simulator.Runtime.so";
#endif

QUANTUM_SIMULATOR LoadQuantumSimulator()
{
    QUANTUM_SIMULATOR handle = 0;
#ifdef _WIN32
    handle = ::LoadLibraryA(FULLSTATESIMULATORLIB);
    if (handle == NULL)
    {
        throw std::runtime_error(
            std::string("Failed to load ") + FULLSTATESIMULATORLIB +
            " (error code: " + std::to_string(GetLastError()) + ")");
    }
#else
    handle = ::dlopen(FULLSTATESIMULATORLIB, RTLD_LAZY);
    if (handle == nullptr)
    {
        throw std::runtime_error(
            std::string("Failed to load ") + FULLSTATESIMULATORLIB + " (" + ::dlerror() + ")");
    }
#endif
    return handle;
}

bool UnloadQuantumSimulator(QUANTUM_SIMULATOR handle)
{
#ifdef _WIN32
    return ::FreeLibrary(handle);
#else // not _WIN32
    return ::dlclose(handle);
#endif
}

void* LoadProc(QUANTUM_SIMULATOR handle, const char* procName)
{
#ifdef _WIN32
    return reinterpret_cast<void*>(::GetProcAddress(handle, procName));
#else // not _WIN32
    return ::dlsym(handle, procName);
#endif
}
} // namespace

namespace Microsoft
{
namespace Quantum
{
    // TODO: is it OK to load/unload the dll for each simulator instance?
    class CFullstateSimulator : public IRuntimeDriver, public IQuantumGateSet, public IDiagnostics
    {
        typedef void (*TSingleQubitGate)(unsigned /*simulator id*/, unsigned /*qubit id*/);
        typedef void (*TSingleQubitControlledGate)(
            unsigned /*simulator id*/,
            unsigned /*number of controls*/,
            unsigned* /*controls*/,
            unsigned /*qubit id*/);

        // QuantumSimulator defines paulis as:
        // enum Basis
        // {
        //     PauliI = 0,
        //     PauliX = 1,
        //     PauliY = 3,
        //     PauliZ = 2
        // };
        // which (surprise!) matches our definition of PauliId enum
        static inline unsigned GetBasis(PauliId pauli)
        {
            return static_cast<unsigned>(pauli);
        }

        const QUANTUM_SIMULATOR handle = 0;
        unsigned simulatorId = -1;
        unsigned nextQubitId = 0; // the QuantumSimulator expects contiguous ids, starting from 0

        unsigned GetQubitId(Qubit qubit) const
        {
            return static_cast<unsigned>(reinterpret_cast<size_t>(qubit));
        }

        vector<unsigned> GetQubitIds(long num, Qubit* qubits) const
        {
            vector<unsigned> ids;
            ids.reserve(num);
            for (long i = 0; i < num; i++)
            {
                ids.push_back(static_cast<unsigned>(reinterpret_cast<size_t>(qubits[i])));
            }
            return ids;
        }

        // Deprecated, use `DumpMachine()` and `DumpRegister()` instead.
        void DumpState()
        {
            std::cout << "*********************" << std::endl;
            this->GetState([](size_t idx, double re, double im) {
                if (re != 0 || im != 0)
                {
                    std::cout << "|" << std::bitset<8>(idx) << ">: " << re << "+" << im << "i" << std::endl;
                }
                return true;
            });
            std::cout << "*********************" << std::endl;
        }

        void* GetProc(const char* name)
        {
            void* proc = LoadProc(this->handle, name);
            if (proc == nullptr)
            {
                throw std::runtime_error(std::string("Failed to find '") + name + "' proc in " + FULLSTATESIMULATORLIB);
            }
            return proc;
        }

      public:
        CFullstateSimulator()
            : handle(LoadQuantumSimulator())
        {
            typedef unsigned (*TInit)();
            static TInit initSimulatorInstance = reinterpret_cast<TInit>(this->GetProc("init"));

            this->simulatorId = initSimulatorInstance();
        }
        ~CFullstateSimulator()
        {
            if (this->simulatorId != -1)
            {
                typedef unsigned (*TDestroy)(unsigned);
                static TDestroy destroySimulatorInstance =
                    reinterpret_cast<TDestroy>(LoadProc(this->handle, "destroy"));
                assert(destroySimulatorInstance);
                destroySimulatorInstance(this->simulatorId);

                // TODO: It seems that simulator might still be doing something on background threads so attempting to
                // unload it might crash.
                // UnloadQuantumSimulator(this->handle);
            }
        }

        // Deprecated, use `DumpMachine()` and `DumpRegister()` instead.
        void GetState(TGetStateCallback callback) override
        {
            typedef bool (*TDump)(unsigned, TGetStateCallback);
            static TDump dump = reinterpret_cast<TDump>(this->GetProc("Dump"));
            dump(this->simulatorId, callback);
        }

        virtual std::string QubitToString(Qubit q) override
        {
            return std::to_string(GetQubitId(q));
        }

        void DumpMachine(const void* location) override;
        void DumpRegister(const void* location, const QirArray* qubits) override;

        Qubit AllocateQubit() override
        {
            typedef void (*TAllocateQubit)(unsigned, unsigned);
            static TAllocateQubit allocateQubit = reinterpret_cast<TAllocateQubit>(this->GetProc("allocateQubit"));

            const unsigned id = this->nextQubitId;
            allocateQubit(this->simulatorId, id);
            this->nextQubitId++;
            return reinterpret_cast<Qubit>(id);
        }

        void ReleaseQubit(Qubit q) override
        {
            typedef void (*TReleaseQubit)(unsigned, unsigned);
            static TReleaseQubit releaseQubit = reinterpret_cast<TReleaseQubit>(this->GetProc("release"));

            releaseQubit(this->simulatorId, GetQubitId(q));
        }

        Result Measure(long numBases, PauliId bases[], long numTargets, Qubit targets[]) override
        {
            assert(numBases == numTargets);
            typedef unsigned (*TMeasure)(unsigned, unsigned, unsigned*, unsigned*);
            static TMeasure m = reinterpret_cast<TMeasure>(this->GetProc("Measure"));
            vector<unsigned> ids = GetQubitIds(numTargets, targets);
            return reinterpret_cast<Result>(
                m(this->simulatorId, numBases, reinterpret_cast<unsigned*>(bases), ids.data()));
        }

        void ReleaseResult(Result r) override {}

        ResultValue GetResultValue(Result r) override
        {
            const unsigned val = static_cast<unsigned>(reinterpret_cast<size_t>(r));
            assert(val == 0 || val == 1);
            return (val == 0) ? Result_Zero : Result_One;
        }

        Result UseZero() override
        {
            return reinterpret_cast<Result>(0);
        }

        Result UseOne() override
        {
            return reinterpret_cast<Result>(1);
        }

        bool AreEqualResults(Result r1, Result r2) override
        {
            return (r1 == r2);
        }

        void X(Qubit q) override
        {
            static TSingleQubitGate op = reinterpret_cast<TSingleQubitGate>(this->GetProc("X"));
            op(this->simulatorId, GetQubitId(q));
        }

        void ControlledX(long numControls, Qubit controls[], Qubit target) override
        {
            static TSingleQubitControlledGate op = reinterpret_cast<TSingleQubitControlledGate>(this->GetProc("MCX"));
            vector<unsigned> ids = GetQubitIds(numControls, controls);
            op(this->simulatorId, numControls, ids.data(), GetQubitId(target));
        }

        void Y(Qubit q) override
        {
            static TSingleQubitGate op = reinterpret_cast<TSingleQubitGate>(this->GetProc("Y"));
            op(this->simulatorId, GetQubitId(q));
        }

        void ControlledY(long numControls, Qubit controls[], Qubit target) override
        {
            static TSingleQubitControlledGate op = reinterpret_cast<TSingleQubitControlledGate>(this->GetProc("MCY"));
            vector<unsigned> ids = GetQubitIds(numControls, controls);
            op(this->simulatorId, numControls, ids.data(), GetQubitId(target));
        }

        void Z(Qubit q) override
        {
            static TSingleQubitGate op = reinterpret_cast<TSingleQubitGate>(this->GetProc("Z"));
            op(this->simulatorId, GetQubitId(q));
        }

        void ControlledZ(long numControls, Qubit controls[], Qubit target) override
        {
            static TSingleQubitControlledGate op = reinterpret_cast<TSingleQubitControlledGate>(this->GetProc("MCZ"));
            vector<unsigned> ids = GetQubitIds(numControls, controls);
            op(this->simulatorId, numControls, ids.data(), GetQubitId(target));
        }

        void H(Qubit q) override
        {
            static TSingleQubitGate op = reinterpret_cast<TSingleQubitGate>(this->GetProc("H"));
            op(this->simulatorId, GetQubitId(q));
        }

        void ControlledH(long numControls, Qubit controls[], Qubit target) override
        {
            static TSingleQubitControlledGate op = reinterpret_cast<TSingleQubitControlledGate>(this->GetProc("MCH"));
            vector<unsigned> ids = GetQubitIds(numControls, controls);
            op(this->simulatorId, numControls, ids.data(), GetQubitId(target));
        }

        void S(Qubit q) override
        {
            static TSingleQubitGate op = reinterpret_cast<TSingleQubitGate>(this->GetProc("S"));
            op(this->simulatorId, GetQubitId(q));
        }

        void ControlledS(long numControls, Qubit controls[], Qubit target) override
        {
            static TSingleQubitControlledGate op = reinterpret_cast<TSingleQubitControlledGate>(this->GetProc("MCS"));
            vector<unsigned> ids = GetQubitIds(numControls, controls);
            op(this->simulatorId, numControls, ids.data(), GetQubitId(target));
        }

        void AdjointS(Qubit q) override
        {
            static TSingleQubitGate op = reinterpret_cast<TSingleQubitGate>(this->GetProc("AdjS"));
            op(this->simulatorId, GetQubitId(q));
        }

        void ControlledAdjointS(long numControls, Qubit controls[], Qubit target) override
        {
            static TSingleQubitControlledGate op =
                reinterpret_cast<TSingleQubitControlledGate>(this->GetProc("MCAdjS"));
            vector<unsigned> ids = GetQubitIds(numControls, controls);
            op(this->simulatorId, numControls, ids.data(), GetQubitId(target));
        }

        void T(Qubit q) override
        {
            static TSingleQubitGate op = reinterpret_cast<TSingleQubitGate>(this->GetProc("T"));
            op(this->simulatorId, GetQubitId(q));
        }

        void ControlledT(long numControls, Qubit controls[], Qubit target) override
        {
            static TSingleQubitControlledGate op = reinterpret_cast<TSingleQubitControlledGate>(this->GetProc("MCT"));
            vector<unsigned> ids = GetQubitIds(numControls, controls);
            op(this->simulatorId, numControls, ids.data(), GetQubitId(target));
        }

        void AdjointT(Qubit q) override
        {
            static TSingleQubitGate op = reinterpret_cast<TSingleQubitGate>(this->GetProc("AdjT"));
            op(this->simulatorId, GetQubitId(q));
        }

        void ControlledAdjointT(long numControls, Qubit controls[], Qubit target) override
        {
            static TSingleQubitControlledGate op =
                reinterpret_cast<TSingleQubitControlledGate>(this->GetProc("MCAdjT"));
            vector<unsigned> ids = GetQubitIds(numControls, controls);
            op(this->simulatorId, numControls, ids.data(), GetQubitId(target));
        }

        void R(PauliId axis, Qubit target, double theta) override
        {
            typedef unsigned (*TR)(unsigned, unsigned, double, unsigned);
            static TR r = reinterpret_cast<TR>(this->GetProc("R"));

            r(this->simulatorId, GetBasis(axis), theta, GetQubitId(target));
        }

        void ControlledR(long numControls, Qubit controls[], PauliId axis, Qubit target, double theta) override
        {
            typedef unsigned (*TMCR)(unsigned, unsigned, double, unsigned, unsigned*, unsigned);
            static TMCR cr = reinterpret_cast<TMCR>(this->GetProc("MCR"));

            vector<unsigned> ids = GetQubitIds(numControls, controls);
            cr(this->simulatorId, GetBasis(axis), theta, numControls, ids.data(), GetQubitId(target));
        }

        void Exp(long numTargets, PauliId paulis[], Qubit targets[], double theta) override
        {
            typedef unsigned (*TExp)(unsigned, unsigned, unsigned*, double, unsigned*);
            static TExp exp = reinterpret_cast<TExp>(this->GetProc("Exp"));
            vector<unsigned> ids = GetQubitIds(numTargets, targets);
            exp(this->simulatorId, numTargets, reinterpret_cast<unsigned*>(paulis), theta, ids.data());
        }

        void ControlledExp(
            long numControls,
            Qubit controls[],
            long numTargets,
            PauliId paulis[],
            Qubit targets[],
            double theta) override
        {
            typedef unsigned (*TMCExp)(unsigned, unsigned, unsigned*, double, unsigned, unsigned*, unsigned*);
            static TMCExp cexp = reinterpret_cast<TMCExp>(this->GetProc("MCExp"));
            vector<unsigned> idsTargets = GetQubitIds(numTargets, targets);
            vector<unsigned> idsControls = GetQubitIds(numControls, controls);
            cexp(
                this->simulatorId, numTargets, reinterpret_cast<unsigned*>(paulis), theta, numControls,
                idsControls.data(), idsTargets.data());
        }

        bool Assert(long numTargets, PauliId* bases, Qubit* targets, Result result, const char* failureMessage) override
        {
            const double probabilityOfZero = AreEqualResults(result, UseZero()) ? 1.0 : 0.0;
            return AssertProbability(numTargets, bases, targets, probabilityOfZero, 1e-10, failureMessage);
        }

        bool AssertProbability(
            long numTargets,
            PauliId bases[],
            Qubit targets[],
            double probabilityOfZero,
            double precision,
            const char* failureMessage) override
        {
            typedef double (*TOp)(unsigned id, unsigned n, int* b, unsigned* q);
            static TOp jointEnsembleProbability = reinterpret_cast<TOp>(this->GetProc("JointEnsembleProbability"));

            vector<unsigned> ids = GetQubitIds(numTargets, targets);
            double actualProbability =
                1.0 -
                jointEnsembleProbability(this->simulatorId, numTargets, reinterpret_cast<int*>(bases), ids.data());

            return (std::abs(actualProbability - probabilityOfZero) < precision);
        }

      private:
        std::ostream& GetOutStream(const void* location, std::ofstream& outFileStream);
        void DumpMachineImpl(std::ostream& outStream);
        void DumpRegisterImpl(std::ostream& outStream, const QirArray* qubits);
        void GetStateTo(TDumpLocation location, TDumpToLocationCallback callback);
        bool GetRegisterTo(TDumpLocation location, TDumpToLocationCallback callback, const QirArray* qubits);

      private:
        TDumpToLocationCallback const dumpToLocationCallback = [](size_t idx, double re, double im, TDumpLocation location) -> bool
            {
                std::ostream& outStream = *reinterpret_cast<std::ostream*>(location);

                if (re != 0 || im != 0)
                {
                    outStream << "|" << std::bitset<8>(idx) << ">: " << re << "+" << im << "i" << std::endl;
                }
                return true;
            };
    }; // class CFullstateSimulator

    void CFullstateSimulator::DumpMachineImpl(std::ostream& outStream)
    {
        outStream << "# wave function for qubits (least to most significant qubit ids):" << std::endl;
        this->GetStateTo((TDumpLocation)&outStream, dumpToLocationCallback);
        outStream.flush();
    }

    void CFullstateSimulator::DumpRegisterImpl(std::ostream& outStream, const QirArray* qubits)
    {
        outStream << "# wave function for qubits with ids (least to most significant): ";
        for(int64_t idx = 0; idx < qubits->count; ++idx)
        {
            if(idx != 0)
            {
                outStream << "; ";
            }
            outStream << (uintptr_t)(((void **)(qubits->buffer))[idx]);
        }
        outStream << ':' << std::endl;

        if(!this->GetRegisterTo((TDumpLocation)&outStream, dumpToLocationCallback, qubits))
        {
            outStream << "## Qubits were entangled with an external qubit. Cannot dump corresponding wave function. ##" << std::endl;
        }
        outStream.flush();
    }

    bool CFullstateSimulator::GetRegisterTo(TDumpLocation location, TDumpToLocationCallback callback, const QirArray* qubits)
    {
        vector<unsigned> ids = GetQubitIds((long)(qubits->count), (Qubit*)(qubits->buffer));

        static TDumpQubitsToLocationAPI dumpQubitsToLocation =
            reinterpret_cast<TDumpQubitsToLocationAPI>(this->GetProc("DumpQubitsToLocation"));
        return dumpQubitsToLocation(
            this->simulatorId, (unsigned)(qubits->count), ids.data(), callback,
            location);
    }

    void CFullstateSimulator::GetStateTo(TDumpLocation location, TDumpToLocationCallback callback)
    {
        static TDumpToLocationAPI dumpTo = reinterpret_cast<TDumpToLocationAPI>(this->GetProc("DumpToLocation"));
        
        dumpTo(this->simulatorId, callback, location);
    }

    std::ostream& CFullstateSimulator::GetOutStream(const void* location, std::ofstream& outFileStream)
    {
        // If the location is not nullptr and not empty string then dump to a file:
        if((location != nullptr) &&
            (((static_cast<const QirString *>(location))->str) != ""))
        {
            // Open the file for appending:
            const std::string& filePath = (static_cast<const QirString *>(location))->str;

            bool openException = false;
            try
            {
                outFileStream.open(filePath, std::ofstream::out | std::ofstream::app);
            }
            catch(const std::ofstream::failure& e)
            {
                openException = true;
                std::cerr << "Exception caught: \"" << e.what() << "\".\n";
            }
            
            if(   ((outFileStream.rdstate() & std::ofstream::failbit) != 0)
               || openException)
            {
                std::cerr << "Failed to open dump file \"" + filePath + "\".\n";
                return OutputStream::Get();     // Dump to std::cout.
            }

            return outFileStream;
        }

        // Otherwise dump to std::cout:
        return OutputStream::Get();
    }

    void CFullstateSimulator::DumpMachine(const void* location)
    {
        std::ofstream outFileStream;
        std::ostream& outStream = GetOutStream(location, outFileStream);
        DumpMachineImpl(outStream);
    }

    void CFullstateSimulator::DumpRegister(const void* location, const QirArray* qubits)
    {
        std::ofstream outFileStream;
        std::ostream& outStream = GetOutStream(location, outFileStream);
        DumpRegisterImpl(outStream, qubits);
    }

    std::unique_ptr<IRuntimeDriver> CreateFullstateSimulator()
    {
        return std::make_unique<CFullstateSimulator>();
    }
} // namespace Quantum
} // namespace Microsoft