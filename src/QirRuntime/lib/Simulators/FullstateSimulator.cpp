// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include <assert.h>
#include <bitset>
#include <complex>
#include <iostream>
#include <memory>
#include <vector>

#include "SimFactory.hpp"
#include "QuantumApi_I.hpp"

using namespace std;

#ifdef _WIN32
#include <windows.h>
typedef HMODULE QUANTUM_SIMULATOR;
#else // not _WIN32
#include <dlfcn.h>
typedef void* QUANTUM_SIMULATOR;
#endif

QUANTUM_SIMULATOR LoadQuantumSimulator()
{
#ifdef _WIN32
    return ::LoadLibraryA("Microsoft.Quantum.Simulator.Runtime.dll");
#elif __APPLE__
    return ::dlopen("libMicrosoft.Quantum.Simulator.Runtime.dylib", RTLD_LAZY);
#else
    auto h = ::dlopen("libMicrosoft.Quantum.Simulator.Runtime.so", RTLD_LAZY);
    std::cout << "**" << h;
    // std::cout << dlerror();
    return h;
#endif
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

namespace Microsoft
{
namespace Quantum
{
    // TODO: is it OK to load/unload the dll for each simulator instance?
    class CFullstateSimulator : public ISimulator, public IQuantumGateSet, public IDiagnostics
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

        const QUANTUM_SIMULATOR handle;
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

        // use for debugging the simulator
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

      public:
        CFullstateSimulator()
            : handle(LoadQuantumSimulator())
        {
            std::cout << "***" << this->handle;
            typedef unsigned (*TInit)();
            static TInit initSimulatorInstance = reinterpret_cast<TInit>(LoadProc(this->handle, "init"));
            std::cout << "***" << (void *) initSimulatorInstance;
            this->simulatorId = initSimulatorInstance();
        }
        ~CFullstateSimulator()
        {
            typedef unsigned (*TDestroy)(unsigned);
            static TDestroy destroySimulatorInstance = reinterpret_cast<TDestroy>(LoadProc(this->handle, "destroy"));

            destroySimulatorInstance(this->simulatorId);

            // TODO: It seems that simulator might still be doing something on background threads so attempting to
            // unload it might crash.
            // UnloadQuantumSimulator(this->handle);
        }

        IQuantumGateSet* AsQuantumGateSet() override
        {
            return this;
        }
        IDiagnostics* AsDiagnostics() override
        {
            return this;
        }

        void GetState(TGetStateCallback callback) override
        {
            typedef bool (*TDump)(unsigned, TGetStateCallback);
            static TDump dump = reinterpret_cast<TDump>(LoadProc(this->handle, "Dump"));
            dump(this->simulatorId, callback);
        }

        virtual std::string QubitToString(Qubit q) override
        {
            return std::to_string(GetQubitId(q));
        }

        Qubit AllocateQubit() override
        {
            typedef void (*TAllocateQubit)(unsigned, unsigned);
            static TAllocateQubit allocateQubit =
                reinterpret_cast<TAllocateQubit>(LoadProc(this->handle, "allocateQubit"));

            const unsigned id = this->nextQubitId;
            allocateQubit(this->simulatorId, id);
            this->nextQubitId++;
            return reinterpret_cast<Qubit>(id);
        }

        void ReleaseQubit(Qubit q) override
        {
            typedef void (*TReleaseQubit)(unsigned, unsigned);
            static TReleaseQubit releaseQubit = reinterpret_cast<TReleaseQubit>(LoadProc(this->handle, "release"));

            releaseQubit(this->simulatorId, GetQubitId(q));
        }

        Result M(Qubit q) override
        {
            typedef unsigned (*TM)(unsigned, unsigned);
            static TM m = reinterpret_cast<TM>(LoadProc(this->handle, "M"));
            return reinterpret_cast<Result>(m(this->simulatorId, GetQubitId(q)));
        }

        Result Measure(long numBases, PauliId bases[], long numTargets, Qubit targets[]) override
        {
            assert(numBases == numTargets);
            typedef unsigned (*TMeasure)(unsigned, unsigned, unsigned*, unsigned*);
            static TMeasure m = reinterpret_cast<TMeasure>(LoadProc(this->handle, "Measure"));
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
            static TSingleQubitGate op = reinterpret_cast<TSingleQubitGate>(LoadProc(this->handle, "X"));
            op(this->simulatorId, GetQubitId(q));
        }

        void ControlledX(long numControls, Qubit controls[], Qubit target) override
        {
            static TSingleQubitControlledGate op =
                reinterpret_cast<TSingleQubitControlledGate>(LoadProc(this->handle, "MCX"));
            vector<unsigned> ids = GetQubitIds(numControls, controls);
            op(this->simulatorId, numControls, ids.data(), GetQubitId(target));
        }

        void Y(Qubit q) override
        {
            static TSingleQubitGate op = reinterpret_cast<TSingleQubitGate>(LoadProc(this->handle, "Y"));
            op(this->simulatorId, GetQubitId(q));
        }

        void ControlledY(long numControls, Qubit controls[], Qubit target) override
        {
            static TSingleQubitControlledGate op =
                reinterpret_cast<TSingleQubitControlledGate>(LoadProc(this->handle, "MCY"));
            vector<unsigned> ids = GetQubitIds(numControls, controls);
            op(this->simulatorId, numControls, ids.data(), GetQubitId(target));
        }

        void Z(Qubit q) override
        {
            static TSingleQubitGate op = reinterpret_cast<TSingleQubitGate>(LoadProc(this->handle, "Z"));
            op(this->simulatorId, GetQubitId(q));
        }

        void ControlledZ(long numControls, Qubit controls[], Qubit target) override
        {
            static TSingleQubitControlledGate op =
                reinterpret_cast<TSingleQubitControlledGate>(LoadProc(this->handle, "MCZ"));
            vector<unsigned> ids = GetQubitIds(numControls, controls);
            op(this->simulatorId, numControls, ids.data(), GetQubitId(target));
        }

        void H(Qubit q) override
        {
            static TSingleQubitGate op = reinterpret_cast<TSingleQubitGate>(LoadProc(this->handle, "H"));
            op(this->simulatorId, GetQubitId(q));
        }

        void ControlledH(long numControls, Qubit controls[], Qubit target) override
        {
            static TSingleQubitControlledGate op =
                reinterpret_cast<TSingleQubitControlledGate>(LoadProc(this->handle, "MCH"));
            vector<unsigned> ids = GetQubitIds(numControls, controls);
            op(this->simulatorId, numControls, ids.data(), GetQubitId(target));
        }

        void S(Qubit q) override
        {
            static TSingleQubitGate op = reinterpret_cast<TSingleQubitGate>(LoadProc(this->handle, "S"));
            op(this->simulatorId, GetQubitId(q));
        }

        void ControlledS(long numControls, Qubit controls[], Qubit target) override
        {
            static TSingleQubitControlledGate op =
                reinterpret_cast<TSingleQubitControlledGate>(LoadProc(this->handle, "MCS"));
            vector<unsigned> ids = GetQubitIds(numControls, controls);
            op(this->simulatorId, numControls, ids.data(), GetQubitId(target));
        }

        void AdjointS(Qubit q) override
        {
            static TSingleQubitGate op = reinterpret_cast<TSingleQubitGate>(LoadProc(this->handle, "AdjS"));
            op(this->simulatorId, GetQubitId(q));
        }

        void ControlledAdjointS(long numControls, Qubit controls[], Qubit target) override
        {
            static TSingleQubitControlledGate op =
                reinterpret_cast<TSingleQubitControlledGate>(LoadProc(this->handle, "MCAdjS"));
            vector<unsigned> ids = GetQubitIds(numControls, controls);
            op(this->simulatorId, numControls, ids.data(), GetQubitId(target));
        }

        void T(Qubit q) override
        {
            static TSingleQubitGate op = reinterpret_cast<TSingleQubitGate>(LoadProc(this->handle, "T"));
            op(this->simulatorId, GetQubitId(q));
        }

        void ControlledT(long numControls, Qubit controls[], Qubit target) override
        {
            static TSingleQubitControlledGate op =
                reinterpret_cast<TSingleQubitControlledGate>(LoadProc(this->handle, "MCT"));
            vector<unsigned> ids = GetQubitIds(numControls, controls);
            op(this->simulatorId, numControls, ids.data(), GetQubitId(target));
        }

        void AdjointT(Qubit q) override
        {
            static TSingleQubitGate op = reinterpret_cast<TSingleQubitGate>(LoadProc(this->handle, "AdjT"));
            op(this->simulatorId, GetQubitId(q));
        }

        void ControlledAdjointT(long numControls, Qubit controls[], Qubit target) override
        {
            static TSingleQubitControlledGate op =
                reinterpret_cast<TSingleQubitControlledGate>(LoadProc(this->handle, "MCAdjT"));
            vector<unsigned> ids = GetQubitIds(numControls, controls);
            op(this->simulatorId, numControls, ids.data(), GetQubitId(target));
        }

        void R(PauliId axis, Qubit target, double theta) override
        {
            typedef unsigned (*TR)(unsigned, unsigned, double, unsigned);
            static TR r = reinterpret_cast<TR>(LoadProc(this->handle, "R"));

            r(this->simulatorId, GetBasis(axis), theta, GetQubitId(target));
        }

        void ControlledR(long numControls, Qubit controls[], PauliId axis, Qubit target, double theta) override
        {
            typedef unsigned (*TMCR)(unsigned, unsigned, double, unsigned, unsigned*, unsigned);
            static TMCR cr = reinterpret_cast<TMCR>(LoadProc(this->handle, "MCR"));

            vector<unsigned> ids = GetQubitIds(numControls, controls);
            cr(this->simulatorId, GetBasis(axis), theta, numControls, ids.data(), GetQubitId(target));
        }

        void Exp(long numTargets, PauliId paulis[], Qubit targets[], double theta) override
        {
            typedef unsigned (*TExp)(unsigned, unsigned, unsigned*, double, unsigned*);
            static TExp exp = reinterpret_cast<TExp>(LoadProc(this->handle, "Exp"));
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
            static TMCExp cexp = reinterpret_cast<TMCExp>(LoadProc(this->handle, "MCExp"));
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
            static TOp jointEnsembleProbability =
                reinterpret_cast<TOp>(LoadProc(this->handle, "JointEnsembleProbability"));

            vector<unsigned> ids = GetQubitIds(numTargets, targets);
            double actualProbability =
                1.0 -
                jointEnsembleProbability(this->simulatorId, numTargets, reinterpret_cast<int*>(bases), ids.data());

            return (std::abs(actualProbability - probabilityOfZero) < precision);
        }
    };

    std::unique_ptr<ISimulator> CreateFullstateSimulator()
    {
        return std::make_unique<CFullstateSimulator>();
    }
} // namespace Quantum
} // namespace Microsoft