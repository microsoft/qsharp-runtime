// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include <assert.h>
#include <chrono>
#include <iostream>
#include <memory>
#include <random>
#include <string>
#include <vector>

using namespace std;

#define HAVE_INTRINSICS
#define HAVE_AVX512
#define HAVE_FMA
#include "simulator/simulator.hpp"
#include "util/cpuid.hpp"

using namespace Microsoft::Quantum::SimulatorAVX512;


// Executes 2*|reg| quantum ops
void ApplyRotations(SimulatorType& sim, int64_t nAngles, double* angles, vector<logical_qubit_id>& reg)
{
    int n = reg.size();
    assert(nAngles == 2 * n);

    for (int i = 0; i < n; i++)
    {
        sim.Rz(angles[2 * i], reg[i]);
        sim.Rx(angles[2 * i + 1], reg[i]);
    }
}

// Executes 2*|reg| quantum ops
void ApplyLadder(SimulatorType& sim, int64_t nAngles, double* angles, vector<logical_qubit_id>& reg)
{
    int n = reg.size();
    assert(nAngles == 2 * n);

    logical_qubit_id ctl = reg[n - 1];
    sim.CRz(angles[0], ctl, reg[0]);
    sim.CRx(angles[1], ctl, reg[0]);
    for (int i = 0; i < n - 1; i++)
    {
        ctl = reg[i];
        sim.CRz(angles[2 * i + 2], ctl, reg[i + 1]);
        sim.CRx(angles[2 * i + 3], ctl, reg[i + 1]);
    }
}

// Executes on average 1.5*|reg| quantum ops
void ResetAll(SimulatorType& sim, vector<logical_qubit_id>& reg)
{
    for (logical_qubit_id q : reg)
    {
        if (sim.M(q))
        {
            sim.X(q);
        }
    }
}

// Executes n + 1.5n + reps*4n = (4*reps + 2.5)n quantum ops
void NativeCircuit(SimulatorType& sim, int64_t nAngles, double* angles, int64_t nQubits, int64_t reps)
{
    vector<logical_qubit_id> reg;
    reg.reserve(nQubits);
    for (int i = 0; i < nQubits; i++)
    {
        reg.push_back(sim.allocate());
    }
    for (int i = 0; i < reps; i++)
    {
        ApplyRotations(sim, nAngles, angles, reg);
        ApplyLadder(sim, nAngles, angles, reg);
    }
    ResetAll(sim, reg);
    for (logical_qubit_id q : reg)
    {
        sim.release(q);
    }
}

double GetPerf(int nQubits, int reps)
{
    using namespace std::chrono;

    std::uniform_real_distribution<double> d(0.0, 1.0);
    std::mt19937 gen;

    const int nAngles = nQubits * 2;
    vector<double> qrangs;
    qrangs.reserve(nAngles);
    for (int i = 0; i < nAngles; i++)
    {
        qrangs.push_back(d(gen));
    }

    SimulatorType sim;

    auto start = high_resolution_clock::now();
    NativeCircuit(sim, nAngles, qrangs.data(), nQubits, reps);
    int64_t mils = duration_cast<milliseconds>(high_resolution_clock::now() - start).count();

    return ((double)mils) / reps;
}

void RunBenchmarks(int cqs, int creps)
{
    cout << "Running benchmarks..." << endl;

    const int min_qubits = (cqs < 0 ? 3 : cqs);
    const int max_qubits = (cqs < 0 ? 18 : cqs);
    const int min_reps = (creps < 0 ? 10000 : creps);
    const int max_reps = (creps < 0 ? 20000 : creps);

    for (int n = min_qubits; n < max_qubits + 1; n++)
    {
        double sum = 0.0;
        long tot = 0;

        for (int reps = min_reps; reps < max_reps + 1; reps += 1000)
        {
            sum += GetPerf(n, reps);
            tot++;
        }

        cout << n << "," << sum / tot << endl;
    }

    cout << "Benchmarks completed" << endl;
}

int main(int argc, char* argv[])
{
    if (!Microsoft::Quantum::haveAVX512())
    {
        cout << "the benchmark targes AVX512 CPU and doesn't run on other CPUs" << endl;
        return 0;
    }
    if (argc < 3)
    {
        cout << "usage: " << argv[0] << " [number_qubits] [number_reps]" << endl;
        cout << "If number of qubits isn't given will run for 3 through 18 (NB: 18+ takes hours to finish)" << endl;
        cout << "If number of reps isn't given will run for 10000..1000..20000" << endl;
    }
    cout << "Configure abm.exe to run in environment consistent with other benchmarks" << endl;
    cout << "Press 'c' to continue, 'q' to exit: ";
    char go;
    cin >> go;
    if (go == 'q')
    {
        return 0;
    }

    int cqs = -1;
    if (argc > 1)
    {
        cqs = atoi(argv[1]);
    }
    int creps = -1;
    if (argc > 2)
    {
        creps = atoi(argv[2]);
    }
    RunBenchmarks(cqs, creps);
}