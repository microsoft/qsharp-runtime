// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include <assert.h>
#include <chrono>
#include <iostream>
#include <memory>
#include <random>
#include <string>

#include "CoreTypes.hpp"
#include "QuantumApi_I.hpp"
#include "SimFactory.hpp"

using namespace Microsoft::Quantum;
using namespace std;

// QIR Entry point
extern "C" void StreamlinedBenchmarks_Benchmark( // NOLINT
    int64_t nAngles,
    double* angles,
    int64_t nQubits,
    int64_t reps,
    bool linear);

// Can manually add calls to DebugLog in the ll files for debugging.
extern "C" void DebugLog(int64_t value)
{
    std::cout << value << std::endl;
}
extern "C" void DebugLogPtr(char* value)
{
    std::cout << (const void*)value << std::endl;
}

// executes 2n quantum ops
void ApplyRotations(ISimulator* sim, int64_t nAngles, double* angles, vector<Qubit>& reg)
{
    IQuantumGateSet* qapi = sim->AsQuantumGateSet();
    int n = reg.size();
    assert(nAngles == 2 * n);

    for (int i = 0; i < n; i++)
    {
        qapi->R(PauliId_Z, reg[i], angles[2 * i]);
        qapi->R(PauliId_X, reg[i], angles[2 * i + 1]);
    }
}
// executes 2n quantum ops
void ApplyLadder(ISimulator* sim, int64_t nAngles, double* angles, vector<Qubit>& reg)
{
    IQuantumGateSet* qapi = sim->AsQuantumGateSet();
    int n = reg.size();
    assert(nAngles == 2 * n);

    Qubit ctl = reg[n - 1];
    qapi->ControlledR(1, &ctl, PauliId_Z, reg[0], angles[0]);
    qapi->ControlledR(1, &ctl, PauliId_X, reg[0], angles[1]);
    for (int i = 0; i < n - 1; i++)
    {
        ctl = reg[i];
        qapi->ControlledR(1, &ctl, PauliId_Z, reg[i + 1], angles[2 * i + 2]);
        qapi->ControlledR(1, &ctl, PauliId_X, reg[i + 1], angles[2 * i + 3]);
    }
}
// executes ~1.5n quantum ops
void ResetAll(ISimulator* sim, vector<Qubit>& reg)
{
    IQuantumGateSet* qapi = sim->AsQuantumGateSet();
    Result one = sim->UseOne();
    for (Qubit q : reg)
    {
        if (sim->AreEqualResults(one, sim->M(q)))
        {
            qapi->X(q);
        }
    }
}
// executes n allocations and ~1.5n + reps*4n quantum ops
void NativeCircuit(ISimulator* sim, int64_t nAngles, double* angles, int64_t nQubits, int64_t reps, bool linear)
{
    IQuantumGateSet* qapi = sim->AsQuantumGateSet();
    vector<Qubit> reg;
    reg.reserve(nQubits);
    for (int i = 0; i < nQubits; i++)
    {
        reg.push_back(sim->AllocateQubit());
    }

    if (linear)
    {
        for (int i = 0; i < reps; i++)
        {
            ApplyRotations(sim, nAngles, angles, reg);
            ApplyLadder(sim, nAngles, angles, reg);
        }
    }
    else
    {
        for (int i = 0; i < reps; i++)
        {
            for (int k = 0; k < nQubits; k++)
            {
                ApplyRotations(sim, 2*nQubits, &angles[2*k*nQubits], reg);
                ApplyLadder(sim, 2*nQubits, &angles[2*k*nQubits], reg);
            }
        }
    }

    ResetAll(sim, reg);
    for (Qubit q : reg)
    {
        sim->ReleaseQubit(q);
    }
}

/* ported from C#
    static double getPerf(long nQ, long reps)
    {
        Random rnd = new Random(-1);
        double[] rangs = new double[2L * nQ];
        for (long j = 0; j < 2L *nQ; j++)
        {
            rangs[j] = rnd.NextDouble();
        }
        IQArray<double> qrangs = new QArray<double>(rangs);
        double ret = 0.0;
        using (var sim = new QuantumSimulator())
        {
            var strt = DateTime.Now;
            var rslt = OnCircuit.Run(sim, qrangs, nQ, reps).Result;
            ret = ((double)(DateTime.Now - strt).TotalMilliseconds)/((double) reps); // msec per ~4n quantum ops
        }
        //Console.WriteLine("LX:DBG: done with nQ= " + nQ.ToString());
        return ret;
    }
*/
double GetPerf(int nQubits, int reps, bool viaQir, bool linear)
{
    using namespace std::chrono;

    std::uniform_real_distribution<double> d(0.0, 1.0);
    std::mt19937 gen;

    const int nAngles = linear ? nQubits * 2 : nQubits * nQubits * 2;
    vector<double> qrangs;
    qrangs.reserve(nAngles);
    for (int i = 0; i < nAngles; i++)
    {
        qrangs.push_back(d(gen));
    }

    unique_ptr<ISimulator> sim = CreateFullstateSimulator();

    auto start = high_resolution_clock::now();
    if (viaQir)
    {
        SetSimulatorForQIR(sim.get());
        StreamlinedBenchmarks_Benchmark(nAngles, qrangs.data(), nQubits, reps, linear);
    }
    else
    {
        NativeCircuit(sim.get(), nAngles, qrangs.data(), nQubits, reps, linear);
    }

    int64_t mils = duration_cast<milliseconds>(high_resolution_clock::now() - start).count();

    return ((double)mils) / reps; // msec per ~4n quantum ops
}

/* ported from C#:
    static void Main(string[] args)
    {
        var verbose = false;
        Console.WriteLine("Running benchmarks...");

        //BUGBUG: why does it crash with n=2L?
        for (long n = 3L; n < 21L; n++)
        {
            var sum = 0.0;
            var tot = 0.00;
            for (long reps = 10000L; reps < 20001L; reps += 1000L)
            {
                sum += getPerf(n, reps);
                tot++;
            }

            if (verbose)
            {
                Console.WriteLine("Time for " + n.ToString() + " qubits: " +
                            (sum / tot).ToString() + " mSec");
            }
            else
            {
                Console.WriteLine("{" + n.ToString() + ","+(sum / tot).ToString() + "},");
            }
        }
        Console.WriteLine("Benchmarks completed");
    }
*/
void RunBenchmarks(bool viaQir, bool linear, int cqs, int creps)
{
    cout << "Running benchmarks..." << endl;

    const int minQubits = (cqs < 0 ? 3 : cqs);
    const int maxQubits = (cqs < 0 ? 18 : cqs);
    const int minReps = (creps < 0 ? 10000 : creps);
    const int maxReps = (creps < 0 ? 20000 : creps);

    for (int n = minQubits; n < maxQubits + 1; n++)
    {
        double sum = 0.0;
        long tot = 0;

        for (int reps = minReps; reps < maxReps + 1; reps += 1000)
        {
            sum += GetPerf(n, reps, viaQir, linear);
            tot++;
        }

        cout << n << "," << sum / tot << endl;
    }

    cout << "Benchmarks completed" << endl;
}

int main(int argc, char* argv[])
{
    try
    {
        if (argc < 3)
        {
            cout << "usage: " << argv[0] << " 0|1 0|1 [number_qubits] [number_reps]" << endl;
            cout << "  1st argument: 0 - use QIR, 1 - don't use QIR" << endl;
            cout << "  2nd argument: 0 - linear,  1 - quadratic" << endl;
            cout << "  3rd argument: If number of qubits isn't given will run for 3 through 18 (NB: 18+ takes hours to "
                    "finish)"
                 << endl;
            cout << "  4th argument: if not provided with run reps for 10000..1000..20000" << endl;
            return 0;
        }
        cout << "Configure abm.exe to run in environment consistent with other benchmarks" << endl;
        cout << "Press 'c' to continue, 'q' to exit: ";
        char go;
        cin >> go;
        if (go == 'q')
        {
            return 0;
        }

        bool viaQir = (atoi(argv[1]) == 0);
        bool linear = (atoi(argv[2]) == 0);
        int cqs = -1;
        if (argc > 3)
        {
            cqs = atoi(argv[3]);
            if (cqs < 3)
            {
                cout << "Must use at least 3 qubits" << endl;
                return 0;
            }
        }
        int creps = -1;
        if (argc > 4)
        {
            creps = atoi(argv[4]);
        }
        RunBenchmarks(viaQir, linear, cqs, creps);
    }
    catch (...)
    {
        cout << "something went wrong..." << endl;
    }
}
