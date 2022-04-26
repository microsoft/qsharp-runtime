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
#include <climits>
#include <chrono>
#include <cstdint>

#include "capi.hpp"


#include "FloatUtils.hpp"
#include "QirTypes.hpp" // TODO: Consider removing dependency on this file.
#include "QirRuntime.hpp"
#include "QirRuntimeApi_I.hpp"
#include "QSharpSimApi_I.hpp"
#include "SimFactory.hpp"
#include "SimFactory.h"
#include "OutputStream.hpp"
#include "QubitManager.hpp"

#ifdef _WIN32
#include <Windows.h>
typedef HMODULE QUANTUM_SIMULATOR;
#else // not _WIN32
#include <dlfcn.h>
typedef void* QUANTUM_SIMULATOR;
#endif

namespace
{
const char* FULLSTATESIMULATORLIB = "Microsoft.Quantum.Simulator.Runtime.dll";
#if defined(__APPLE__)
const char* XPLATFULLSTATESIMULATORLIB = "libMicrosoft.Quantum.Simulator.Runtime.dylib";
#elif !defined(_WIN32)
const char* XPLATFULLSTATESIMULATORLIB = "libMicrosoft.Quantum.Simulator.Runtime.so";
#endif

QUANTUM_SIMULATOR LoadQuantumSimulator()
{
    QUANTUM_SIMULATOR handle = nullptr;
#ifdef _WIN32
    handle = ::LoadLibraryA(FULLSTATESIMULATORLIB);
    if (handle == nullptr)
    {
        throw std::runtime_error(std::string("Failed to load ") + FULLSTATESIMULATORLIB +
                                 " (error code: " + std::to_string(GetLastError()) + ")");
    }
#else
    handle = ::dlopen(FULLSTATESIMULATORLIB, RTLD_LAZY);
    if (handle == nullptr)
    {
        handle = ::dlopen(XPLATFULLSTATESIMULATORLIB, RTLD_LAZY);
        if (handle == nullptr)
        {
            throw std::runtime_error(std::string("Failed to load ") + XPLATFULLSTATESIMULATORLIB + " (" + ::dlerror() +
                                     ")");
        }
    }
#endif
    return handle;
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
    class CFullstateSimulator
        : public IRuntimeDriver
        , public IRestrictedAreaManagement
        , public IQuantumGateSet
        , public IDiagnostics
    {
        typedef void (*TSingleQubitGate)(unsigned /*simulator id*/, unsigned /*qubit id*/);
        typedef void (*TSingleQubitControlledGate)(unsigned /*simulator id*/, unsigned /*number of controls*/,
                                                   unsigned* /*controls*/, unsigned /*qubit id*/);

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

        std::vector<unsigned> GetBases(long num, PauliId* paulis)
        {
            std::vector<unsigned> convertedBases;
            convertedBases.reserve((size_t)num);
            for (auto i = 0; i < num; i++)
            {
                convertedBases.push_back(GetBasis(paulis[i]));
            }
            return convertedBases;
        }

        const QUANTUM_SIMULATOR handle = nullptr;

        using TSimulatorId = unsigned; // TODO: Use `void*` or a fixed-size integer,
                                       // starting in native simulator (breaking change).
        static constexpr TSimulatorId NULL_SIMULATORID = UINT_MAX;
        // Should be `= std::numeric_limits<TSimulatorId>::max()` but the Clang 12.0.0 complains.

        TSimulatorId simulatorId = NULL_SIMULATORID;

        // the QuantumSimulator expects contiguous ids, starting from 0
        std::unique_ptr<CQubitManager> qubitManager;

        unsigned GetQubitId(QubitIdType qubit) const
        {
            // Qubit manager uses unsigned range of intptr_t for qubit ids.
            return static_cast<unsigned>(qubit);
        }

        std::vector<unsigned> GetQubitIds(long num, QubitIdType* qubits) const
        {
            std::vector<unsigned> ids;
            ids.reserve((size_t)num);
            for (long i = 0; i < num; i++)
            {
                ids.push_back(GetQubitId(qubits[i]));
            }
            return ids;
        }

        // Deprecated, use `DumpMachine()` and `DumpRegister()` instead.
        void DumpState()
        {
            std::cout << "*********************" << std::endl;
            this->GetState(
                [](const char* idx, double re, double im)
                {
                    if (!Close(re, 0.0) || !Close(im, 0.0))
                    {
                        std::cout << "|" << idx << ">: " << re << "+" << im << "i" << std::endl;
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

        void UnmarkAsMeasuredSingleQubit(QubitIdType q)
        {
            isMeasured[GetQubitId(q)] = false;
        }

        void UnmarkAsMeasuredQubitList(long num, QubitIdType* qubit)
        {
            for (const auto& id : GetQubitIds(num, qubit))
            {
                isMeasured[id] = false;
            }
        }

      public:
        CFullstateSimulator(uint32_t userProvidedSeed = 0) : handle(LoadQuantumSimulator())
        {
            typedef unsigned (*TInit)();
            static TInit initSimulatorInstance = reinterpret_cast<TInit>(this->GetProc("init"));

            qubitManager      = std::make_unique<CQubitManager>();
            this->simulatorId = initSimulatorInstance();

            typedef void (*TSeed)(unsigned, unsigned);
            static TSeed setSimulatorSeed = reinterpret_cast<TSeed>(this->GetProc("seed"));
            setSimulatorSeed(this->simulatorId,
                             (userProvidedSeed == 0)
                                 ? (unsigned)std::chrono::system_clock::now().time_since_epoch().count()
                                 : (unsigned)userProvidedSeed);
        }
        ~CFullstateSimulator() override
        {
            if (this->simulatorId != NULL_SIMULATORID)
            {
                typedef void (*TDestroy)(unsigned);
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
            typedef void (*TDump)(unsigned, TGetStateCallback);
            static TDump dump = reinterpret_cast<TDump>(this->GetProc("Dump"));
            dump(this->simulatorId, callback);
        }

        virtual std::string QubitToString(QubitIdType q) override
        {
            return std::to_string(q);
        }

        void DumpMachine(const void* location) override;
        void DumpRegister(const void* location, const QirArray* qubits) override;

        QubitIdType AllocateQubit() override
        {
            typedef void (*TAllocateQubit)(unsigned, unsigned);
            static TAllocateQubit allocateQubit = reinterpret_cast<TAllocateQubit>(this->GetProc("allocateQubit"));

            QubitIdType q = qubitManager->Allocate(); // Allocate qubit in qubit manager.
            unsigned id   = GetQubitId(q);            // Get its id.
            allocateQubit(this->simulatorId, id);     // Allocate it in the simulator.
            if (isMeasured.size() < id + 1)
            {
                isMeasured.resize(id + 1, false);
            }
            return q;
        }

        void ReleaseQubit(QubitIdType q) override
        {
            typedef bool (*TReleaseQubit)(unsigned, unsigned);
            static TReleaseQubit releaseQubit = reinterpret_cast<TReleaseQubit>(this->GetProc("release"));

            // Release qubit in the simulator, checking to make sure that release was valid.
            auto id = GetQubitId(q);
            if (!releaseQubit(this->simulatorId, id) && !isMeasured[id])
            {
                // We reject the release of a qubit that is not in the ground state (releaseQubit returns false),
                // and was not recently measured (ie: the last operation was not measurement). This means the
                // state is not well known, and therefore the safety of release is not guaranteed.
                __quantum__rt__fail_cstr("Released qubit neither measured nor in ground state.");
            }
            qubitManager->Release(q); // Release it in the qubit manager.
        }

        // IRestrictedAreaManagement

        virtual void StartArea() override
        {
            qubitManager->StartRestrictedReuseArea();
        }

        virtual void NextSegment() override
        {
            qubitManager->NextRestrictedReuseSegment();
        }
        virtual void EndArea() override
        {
            qubitManager->EndRestrictedReuseArea();
        }

        Result Measure(long numBases, PauliId bases[], long numTargets, QubitIdType targets[]) override
        {
            assert(numBases == numTargets);
            typedef unsigned (*TMeasure)(unsigned, unsigned, unsigned*, unsigned*);
            static TMeasure m         = reinterpret_cast<TMeasure>(this->GetProc("Measure"));
            std::vector<unsigned> ids = GetQubitIds(numTargets, targets);
            if (ids.size() == 1)
            {
                // If measuring exactly one qubit, mark it as measured for tracking.
                isMeasured[ids[0]] = true;
            }
            std::vector<unsigned> convertedBases = GetBases(numBases, bases);

            return reinterpret_cast<Result>(
                m(this->simulatorId, (unsigned)numBases, convertedBases.data(), ids.data()));
        }

        void ReleaseResult(Result /*r*/) override
        {
        }

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

        void X(QubitIdType q) override
        {
            static TSingleQubitGate op = reinterpret_cast<TSingleQubitGate>(this->GetProc("X"));
            op(this->simulatorId, GetQubitId(q));
            UnmarkAsMeasuredSingleQubit(q);
        }

        void ControlledX(long numControls, QubitIdType controls[], QubitIdType target) override
        {
            static TSingleQubitControlledGate op = reinterpret_cast<TSingleQubitControlledGate>(this->GetProc("MCX"));
            std::vector<unsigned> ids            = GetQubitIds(numControls, controls);
            op(this->simulatorId, (unsigned)numControls, ids.data(), GetQubitId(target));
            UnmarkAsMeasuredSingleQubit(target);
            UnmarkAsMeasuredQubitList(numControls, controls);
        }

        void Y(QubitIdType q) override
        {
            static TSingleQubitGate op = reinterpret_cast<TSingleQubitGate>(this->GetProc("Y"));
            op(this->simulatorId, GetQubitId(q));
            UnmarkAsMeasuredSingleQubit(q);
        }

        void ControlledY(long numControls, QubitIdType controls[], QubitIdType target) override
        {
            static TSingleQubitControlledGate op = reinterpret_cast<TSingleQubitControlledGate>(this->GetProc("MCY"));
            std::vector<unsigned> ids            = GetQubitIds(numControls, controls);
            op(this->simulatorId, (unsigned)numControls, ids.data(), GetQubitId(target));
            UnmarkAsMeasuredSingleQubit(target);
            UnmarkAsMeasuredQubitList(numControls, controls);
        }

        void Z(QubitIdType q) override
        {
            static TSingleQubitGate op = reinterpret_cast<TSingleQubitGate>(this->GetProc("Z"));
            op(this->simulatorId, GetQubitId(q));
            UnmarkAsMeasuredSingleQubit(q);
        }

        void ControlledZ(long numControls, QubitIdType controls[], QubitIdType target) override
        {
            static TSingleQubitControlledGate op = reinterpret_cast<TSingleQubitControlledGate>(this->GetProc("MCZ"));
            std::vector<unsigned> ids            = GetQubitIds(numControls, controls);
            op(this->simulatorId, (unsigned)numControls, ids.data(), GetQubitId(target));
            UnmarkAsMeasuredSingleQubit(target);
            UnmarkAsMeasuredQubitList(numControls, controls);
        }

        void H(QubitIdType q) override
        {
            static TSingleQubitGate op = reinterpret_cast<TSingleQubitGate>(this->GetProc("H"));
            op(this->simulatorId, GetQubitId(q));
            UnmarkAsMeasuredSingleQubit(q);
        }

        void ControlledH(long numControls, QubitIdType controls[], QubitIdType target) override
        {
            static TSingleQubitControlledGate op = reinterpret_cast<TSingleQubitControlledGate>(this->GetProc("MCH"));
            std::vector<unsigned> ids            = GetQubitIds(numControls, controls);
            op(this->simulatorId, (unsigned)numControls, ids.data(), GetQubitId(target));
            UnmarkAsMeasuredSingleQubit(target);
            UnmarkAsMeasuredQubitList(numControls, controls);
        }

        void S(QubitIdType q) override
        {
            static TSingleQubitGate op = reinterpret_cast<TSingleQubitGate>(this->GetProc("S"));
            op(this->simulatorId, GetQubitId(q));
            UnmarkAsMeasuredSingleQubit(q);
        }

        void ControlledS(long numControls, QubitIdType controls[], QubitIdType target) override
        {
            static TSingleQubitControlledGate op = reinterpret_cast<TSingleQubitControlledGate>(this->GetProc("MCS"));
            std::vector<unsigned> ids            = GetQubitIds(numControls, controls);
            op(this->simulatorId, (unsigned)numControls, ids.data(), GetQubitId(target));
            UnmarkAsMeasuredSingleQubit(target);
            UnmarkAsMeasuredQubitList(numControls, controls);
        }

        void AdjointS(QubitIdType q) override
        {
            static TSingleQubitGate op = reinterpret_cast<TSingleQubitGate>(this->GetProc("AdjS"));
            op(this->simulatorId, GetQubitId(q));
            UnmarkAsMeasuredSingleQubit(q);
        }

        void ControlledAdjointS(long numControls, QubitIdType controls[], QubitIdType target) override
        {
            static TSingleQubitControlledGate op =
                reinterpret_cast<TSingleQubitControlledGate>(this->GetProc("MCAdjS"));
            std::vector<unsigned> ids = GetQubitIds(numControls, controls);
            op(this->simulatorId, (unsigned)numControls, ids.data(), GetQubitId(target));
            UnmarkAsMeasuredSingleQubit(target);
            UnmarkAsMeasuredQubitList(numControls, controls);
        }

        void T(QubitIdType q) override
        {
            static TSingleQubitGate op = reinterpret_cast<TSingleQubitGate>(this->GetProc("T"));
            op(this->simulatorId, GetQubitId(q));
            UnmarkAsMeasuredSingleQubit(q);
        }

        void ControlledT(long numControls, QubitIdType controls[], QubitIdType target) override
        {
            static TSingleQubitControlledGate op = reinterpret_cast<TSingleQubitControlledGate>(this->GetProc("MCT"));
            std::vector<unsigned> ids            = GetQubitIds(numControls, controls);
            op(this->simulatorId, (unsigned)numControls, ids.data(), GetQubitId(target));
            UnmarkAsMeasuredSingleQubit(target);
            UnmarkAsMeasuredQubitList(numControls, controls);
        }

        void AdjointT(QubitIdType q) override
        {
            static TSingleQubitGate op = reinterpret_cast<TSingleQubitGate>(this->GetProc("AdjT"));
            op(this->simulatorId, GetQubitId(q));
            UnmarkAsMeasuredSingleQubit(q);
        }

        void ControlledAdjointT(long numControls, QubitIdType controls[], QubitIdType target) override
        {
            static TSingleQubitControlledGate op =
                reinterpret_cast<TSingleQubitControlledGate>(this->GetProc("MCAdjT"));
            std::vector<unsigned> ids = GetQubitIds(numControls, controls);
            op(this->simulatorId, (unsigned)numControls, ids.data(), GetQubitId(target));
            UnmarkAsMeasuredSingleQubit(target);
            UnmarkAsMeasuredQubitList(numControls, controls);
        }

        void R(PauliId axis, QubitIdType target, double theta) override
        {
            typedef void (*TR)(unsigned, unsigned, double, unsigned);
            static TR r = reinterpret_cast<TR>(this->GetProc("R"));

            r(this->simulatorId, GetBasis(axis), theta, GetQubitId(target));
            UnmarkAsMeasuredSingleQubit(target);
        }

        void ControlledR(long numControls, QubitIdType controls[], PauliId axis, QubitIdType target,
                         double theta) override
        {
            typedef void (*TMCR)(unsigned, unsigned, double, unsigned, unsigned*, unsigned);
            static TMCR cr = reinterpret_cast<TMCR>(this->GetProc("MCR"));

            std::vector<unsigned> ids = GetQubitIds(numControls, controls);
            cr(this->simulatorId, GetBasis(axis), theta, (unsigned)numControls, ids.data(), GetQubitId(target));
            UnmarkAsMeasuredSingleQubit(target);
            UnmarkAsMeasuredQubitList(numControls, controls);
        }

        void Exp(long numTargets, PauliId paulis[], QubitIdType targets[], double theta) override
        {
            typedef void (*TExp)(unsigned, unsigned, unsigned*, double, unsigned*);
            static TExp exp                      = reinterpret_cast<TExp>(this->GetProc("Exp"));
            std::vector<unsigned> ids            = GetQubitIds(numTargets, targets);
            std::vector<unsigned> convertedBases = GetBases(numTargets, paulis);
            exp(this->simulatorId, (unsigned)numTargets, convertedBases.data(), theta, ids.data());
            UnmarkAsMeasuredQubitList(numTargets, targets);
        }

        void ControlledExp(long numControls, QubitIdType controls[], long numTargets, PauliId paulis[],
                           QubitIdType targets[], double theta) override
        {
            typedef void (*TMCExp)(unsigned, unsigned, unsigned*, double, unsigned, unsigned*, unsigned*);
            static TMCExp cexp                   = reinterpret_cast<TMCExp>(this->GetProc("MCExp"));
            std::vector<unsigned> idsTargets     = GetQubitIds(numTargets, targets);
            std::vector<unsigned> idsControls    = GetQubitIds(numControls, controls);
            std::vector<unsigned> convertedBases = GetBases(numTargets, paulis);
            cexp(this->simulatorId, (unsigned)numTargets, convertedBases.data(), theta, (unsigned)numControls,
                 idsControls.data(), idsTargets.data());
            UnmarkAsMeasuredQubitList(numTargets, targets);
            UnmarkAsMeasuredQubitList(numControls, controls);
        }

        bool Assert(long numTargets, PauliId* bases, QubitIdType* targets, Result result,
                    const char* failureMessage) override
        {
            const double probabilityOfZero = AreEqualResults(result, UseZero()) ? 1.0 : 0.0;
            return AssertProbability(numTargets, bases, targets, probabilityOfZero, 1e-10, failureMessage);
        }

        bool AssertProbability(long numTargets, PauliId bases[], QubitIdType targets[], double probabilityOfZero,
                               double precision, const char* /*failureMessage*/) override
        {
            typedef double (*TOp)(unsigned id, unsigned n, int* b, unsigned* q);
            static TOp jointEnsembleProbability = reinterpret_cast<TOp>(this->GetProc("JointEnsembleProbability"));

            std::vector<unsigned> ids            = GetQubitIds(numTargets, targets);
            std::vector<unsigned> convertedBases = GetBases(numTargets, bases);
            double actualProbability =
                1.0 - jointEnsembleProbability(this->simulatorId, (unsigned)numTargets,
                                               reinterpret_cast<int*>(convertedBases.data()), ids.data());

            return (std::abs(actualProbability - probabilityOfZero) < precision);
        }

      private:
        std::ostream& GetOutStream(const void* location, std::ofstream& outFileStream);
        void DumpMachineImpl(std::ostream& outStream);
        void DumpRegisterImpl(std::ostream& outStream, const QirArray* qubits);
        void GetStateTo(TDumpLocation location, TDumpToLocationCallback callback);
        bool GetRegisterTo(TDumpLocation location, TDumpToLocationCallback callback, const QirArray* qubits);

        // This bit std::vector tracks whether the last operation on a given qubit was Measure.
        // Note that `std::vector<bool>` is already specialized to use an underlying bitfied to save space.
        // See: https://www.cplusplus.com/reference/vector/vector-bool/
        std::vector<bool> isMeasured;

      private:
        TDumpToLocationCallback const dumpToLocationCallback = [](size_t idx, double re, double im,
                                                                  TDumpLocation location) -> bool
        {
            std::ostream& outStream = *reinterpret_cast<std::ostream*>(location);

            if (!Close(re, 0.0) || !Close(im, 0.0))
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
        for (QirArray::TItemCount idx = 0; idx < qubits->count; ++idx)
        {
            if (idx != 0)
            {
                outStream << "; ";
            }
            outStream << (uintptr_t)((reinterpret_cast<QubitIdType*>(qubits->GetItemPointer(0)))[idx]);
        }
        outStream << ':' << std::endl;

        if (!this->GetRegisterTo((TDumpLocation)&outStream, dumpToLocationCallback, qubits))
        {
            outStream << "## Qubits were entangled with an external qubit. Cannot dump corresponding wave function. ##"
                      << std::endl;
        }
        outStream.flush();
    }

    bool CFullstateSimulator::GetRegisterTo(TDumpLocation location, TDumpToLocationCallback callback,
                                            const QirArray* qubits)
    {
        std::vector<unsigned> ids =
            GetQubitIds((long)(qubits->count), reinterpret_cast<QubitIdType*>(qubits->GetItemPointer(0)));
        static TDumpQubitsToLocationAPI dumpQubitsToLocation =
            reinterpret_cast<TDumpQubitsToLocationAPI>(this->GetProc("DumpQubitsToLocation"));
        return dumpQubitsToLocation(this->simulatorId, (unsigned)(qubits->count), ids.data(), callback, location);
    }

    void CFullstateSimulator::GetStateTo(TDumpLocation location, TDumpToLocationCallback callback)
    {
        static TDumpToLocationAPI dumpTo = reinterpret_cast<TDumpToLocationAPI>(this->GetProc("DumpToLocation"));

        dumpTo(this->simulatorId, callback, location);
    }

    std::ostream& CFullstateSimulator::GetOutStream(const void* location, std::ofstream& outFileStream)
    {
        // If the location is not nullptr and not empty string then dump to a file:
        if ((location != nullptr) && (((static_cast<const QirString*>(location))->str) != ""))
        {
            // Open the file for appending:
            const std::string& filePath = (static_cast<const QirString*>(location))->str;

            bool openException = false;
            try
            {
                outFileStream.open(filePath, std::ofstream::out | std::ofstream::app);
            }
            catch (const std::ofstream::failure& e)
            {
                openException = true;
                std::cerr << "Exception caught: \"" << e.what() << "\".\n";
            }

            if (((outFileStream.rdstate() & std::ofstream::failbit) != 0) || openException)
            {
                std::cerr << "Failed to open dump file \"" + filePath + "\".\n";
                return OutputStream::Get(); // Dump to std::cout.
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

    std::unique_ptr<IRuntimeDriver> CreateFullstateSimulator(uint32_t userProvidedSeed /*= 0*/)
    {
        return std::make_unique<CFullstateSimulator>(userProvidedSeed);
    }

    extern "C" void* CreateFullstateSimulatorC(uint32_t userProvidedSeed)
    {
        return (IRuntimeDriver*)new CFullstateSimulator(userProvidedSeed);
    }

} // namespace Quantum
} // namespace Microsoft
