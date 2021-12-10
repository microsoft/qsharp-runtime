// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
#include "omp.h"
#include <iostream>
#include <chrono>
#include <sstream>
#include <vector>
#include "simulator/kernels.hpp"
#include "simulator/types.hpp"

#include <time.h>
#ifdef _WIN32
#include <Windows.h>
#include <sysinfoapi.h>
#else
#include <sys/sysinfo.h>
#endif

class CTiming
{
  public:
    CTiming(const std::string& nameIn, int32_t timesIn = 1) :name(nameIn), times(timesIn)
    {
        start = std::chrono::duration_cast<std::chrono::microseconds>(
                    std::chrono::high_resolution_clock::now().time_since_epoch())
                    .count();
        startCpu = GetCpuTimeMs();
    }

    ~CTiming()
    {
        auto end = std::chrono::duration_cast<std::chrono::microseconds>(
                       std::chrono::high_resolution_clock::now().time_since_epoch())
                       .count();
        double wallTimeMs = ((double)(end - start)) / 1000.0;

#ifdef _WIN32
        endCpu = GetCpuTimeMs();
        SYSTEM_INFO info;
        GetSystemInfo(&info);
        auto nCores = info.dwNumberOfProcessors;
#else
        endCpu       = GetCpuTimeMs();
        auto nCores  = get_nprocs();
#endif
        try
        {
            std::cout << name  << " total: " << wallTimeMs << ", average:" << wallTimeMs / times << " ms,";
            std::cout << " CPU utilization ratio: " << (endCpu - startCpu) / (wallTimeMs * nCores)
                      << ", cores: " << nCores << std::endl;
        }
        catch (...)
        {
        }
    }

  private:
    double GetCpuTimeMs()
    {
#ifdef _WIN32
        uint64_t cycles;
        bool done = QueryProcessCycleTime(GetCurrentProcess(), &cycles);
        if (!done)
        {
            std::cout << "Failed to query process cpu time" << std::endl;
        }

        double cpuMs = ((double)cycles) / CLOCKS_PER_SEC;
#else
        double cpuMs = ((double)clock()) * 1000. / CLOCKS_PER_SEC;
#endif
        return cpuMs;
    }
    std::string name;
    int64_t start;
    int32_t times;
    double startCpu;
    double endCpu;
};

using namespace Microsoft::Quantum::SIMULATOR;
using namespace Microsoft::Quantum::SIMULATOR::kernels;
static const std::string nrm2_name("nrm2") ;
static const std::string nrm2_avx512_name("nrm2_avx512") ;
static const std::string normalize_name("normalize") ;
static const std::string normalizeavx512_name("normalize avx512") ;

void test_nrm2(WavefunctionStorage& wfn, int loops)
{
    /* {
        CTiming timer(nrm2_name, loops);
        for (int i = 0; i < loops; i++)
        {
            nrm2(wfn);
        }
    }*/
    {
        CTiming timer(nrm2_avx512_name, loops);
        for (int i = 0; i < loops; i++)
        {
            nrm2_avx512(wfn);
        }
    }
}

void test_normalize(WavefunctionStorage& wfn, int loops)
{
    /* {
        CTiming timer(normalize_name, loops);
        for (int i = 0; i < loops; i++)
        {
            normalize(wfn);
        }
    }*/
    {
        CTiming timer(normalizeavx512_name, loops);
        for (int i = 0; i < loops; i++)
        {
            normalize_avx512(wfn);
        }
    }
}
typedef void (*TestFuncP)(WavefunctionStorage& wfn, int loops);

static std::vector<TestFuncP> testFuncs ={test_nrm2, test_normalize};

int main(int argc, char** argv)
{
    int funcId = 0;
    int loops = 5;
    int qubits_num = 28;
    if (argc > 1)
    {
        std::stringstream inputFuncId(argv[1]);
        inputFuncId >> funcId;
    }
    if (argc > 2)
    {
        std::stringstream inputLoops(argv[2]);
        inputLoops >> loops;
    }
    if (argc > 3)
    {
        std::stringstream inputQubits(argv[3]);
        inputQubits >> qubits_num;
    }

    std::cout<<"Function: "<<funcId<<", loops: "<<loops<<", Qubits: "<<qubits_num<<std::endl;

    WavefunctionStorage qubits(1ULL << qubits_num);

#pragma omp parallel for schedule(static)
    for(int64_t i = 0; (size_t)i < qubits.size(); i++)
    {
        qubits[i] = {1., 1.};
    }

    testFuncs[funcId](qubits, loops);

    return 0;
}
