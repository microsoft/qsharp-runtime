// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include "simulator/capi.hpp"
#include <array>
#include <cassert>
#include <chrono>
#include <cmath>
#include <complex>
#include <fstream>
#include <iostream>
#include <omp.h>
#include <regex>
#include <stdarg.h>
#include <string>
#include <vector>

#include "capi.hpp"
#include "util/cpuid.hpp"
#include <cstdarg>

using namespace std;

// some convenience functions
void CX(unsigned sim_id, unsigned c, unsigned q)
{
    MCX(sim_id, 1, &c, q);
}

void CZ(unsigned sim_id, unsigned c, unsigned q)
{
    MCZ(sim_id, 1, &c, q);
}

void Ry(unsigned sim_id, double phi, unsigned q)
{
    R(sim_id, 2, phi, q);
}

void CRz(unsigned sim_id, double phi, unsigned c, unsigned q)
{
    MCR(sim_id, 3, phi, 1, &c, q);
}

void CRx(unsigned sim_id, double phi, unsigned c, unsigned q)
{
    MCR(sim_id, 1, phi, 1, &c, q);
}

void dump(unsigned sim_id, const char* label)
{
    auto dump_callback = [](size_t idx, double r, double i) {
        std::cout << idx << ":\t" << r << '\t' << i << '\n';
        return true;
    };
    auto sim_ids_callback = [](unsigned idx) { std::cout << idx << " "; };

    std::cout << label << "\n"
              << "wave function for ids (least to most significant): [";
    DumpIds(sim_id, sim_ids_callback);
    std::cout << "]\n";
    Dump(sim_id, dump_callback);
}

std::vector<std::vector<std::int32_t>> loadPrb(int circStart, int circStop)
{
    std::vector<std::vector<std::int32_t>> rslt;
    for (int k = circStart; k < circStop; k++)
    {
        unsigned c = k - 1;
        if (k > 0)
            for (int j = 0; j < 5; j++)
            {
                std::vector<std::int32_t> nums = {k - 1, k};
                rslt.push_back(nums);
            }
        if (k % 5 == 0)
        {
            for (int j = 0; j < 5; j++)
            {
                std::vector<std::int32_t> nums = {k};
                rslt.push_back(nums);
            }
        }
    }
    return rslt;
}

std::vector<std::int32_t> splitNums(const std::string& str, char delim = ',')
{
    std::vector<std::int32_t> nums;
    size_t start;
    size_t end = 0;
    while ((start = str.find_first_not_of(delim, end)) != std::string::npos)
    {
        end = str.find(delim, start);
        nums.push_back(stoi(str.substr(start, end - start)));
    }
    return nums;
}

std::vector<std::vector<std::int32_t>> loadTest(char* fName, bool doClusters)
{
    std::vector<std::vector<std::int32_t>> rslt;
    std::vector<std::int32_t> empty;
    string line;
    ifstream file(fName);
    if (!file.is_open()) throw(std::invalid_argument("Can't open input file"));

    int phase = 0;
    if (doClusters) phase = 2;

    regex reOrig("^=== Original:.*[\r]?");
    regex reGate("^\\s*(\\d+):\\s+(.+)\\[(.*)\\].*[\r]?");
    regex reClusters("^=== Clusters.*[\r]?");
    regex reCluster("^==== cluster\\[\\s*(\\d+)\\]:.*[\r]?");
    smatch sm;

    while (getline(file, line))
    {
        if (phase == 99) break;
        switch (phase)
        {
        case 0:
            if (regex_match(line, sm, reOrig)) phase = 1;
            break;
        case 1:
            if (regex_match(line, sm, reGate))
            {
                auto qs = splitNums(sm[3]);
                rslt.push_back(qs);
            }
            else
                phase = 99;
            break;
        case 2:
            if (regex_match(line, reClusters)) phase = 3;
            break;
        case 4:
            if (regex_match(line, sm, reGate))
            {
                auto qs = splitNums(sm[3]);
                rslt.push_back(qs);
                break;
            }
            else
            {
                phase = 3;
                [[fallthrough]];
            }
        case 3:
            if (regex_match(line, sm, reCluster))
            {
                rslt.push_back(empty);
                phase = 4;
            }
            break;
        }
    }
    file.close();
    return rslt;
}

void mySprintf(char* buf, int bufSiz, const char* fmt, ...)
{
    va_list args;
#ifdef _MSC_VER
    __crt_va_start(args, fmt);
    vsprintf_s(buf, bufSiz, fmt, args);
    __crt_va_end(args);
#else
    va_start(args, fmt);
    vsprintf(buf, fmt, args);
    va_end(args);
#endif
    // perror(buf);
}

int numQs(vector<vector<int32_t>> prb)
{
    int mx = -1;
    for (auto i : prb)
        for (auto j : i)
            if (j > mx) mx = j;
    return (mx + 1);
}

int main()
{
    int nQs;
    vector<vector<int32_t>> prb;
    char fName[30];

    // Perform a small number of loops on the 4x4 advantage circuit.
    int sizR = 4;
    int sizC = 4;
    int loops = 10;
    mySprintf(fName, sizeof(fName), "advantage_%d%d_4.log", sizR, sizC);

    prb = loadTest(fName, false);
    nQs = numQs(prb);
    int gateCnt = (int)prb.size();
    double maxGps = 0.0;

//#ifdef NDEBUG
    double gpsFailureThreshold = 1000.0;
//#else
//    double gpsFailureThreshold = 60.0;
//#endif

    printf("==== Starting %s (%d gates), Failure threshold %.2e gps\n", fName, gateCnt, gpsFailureThreshold);

    auto sim_id = init();
    for (int q = 0; q < nQs; q++)
        allocateQubit(sim_id, q);

    std::chrono::system_clock::time_point start = std::chrono::system_clock::now();
    int itvl = loops / 10;
    for (int i = 0; i < loops; i++)
    {
        for (int j = 0; j < prb.size(); j++)
        {
            auto qs = prb[j];
            uint32_t cs[2];
            switch (qs.size())
            {
            case 0: // No op
                break;
            case 1:
                H(sim_id, qs[0]);
                break;
            case 2:
                CX(sim_id, qs[0], qs[1]);
                break;
            case 3:
                cs[0] = (uint32_t)qs[0];
                cs[1] = (uint32_t)qs[1];
                MCX(sim_id, 2, cs, qs[2]);
                break;
            default:
                throw(std::invalid_argument("Didn't expect more then 3 wire gates"));
            }
        }
        for (int q = 0; q < nQs; q++)
            M(sim_id, q);

        std::chrono::system_clock::time_point curr = std::chrono::system_clock::now();
        std::chrono::duration<double> elapsed = curr - start;
        if (i % itvl == (itvl - 1))
        {
            double gps = (double)gateCnt * (double)i / elapsed.count();
            printf("Loops[%4d]: GPS = %.2e\n", i, gps);
            fflush(stdout);
            if (gps > maxGps) maxGps = gps;
        }
    }
    destroy(sim_id);

    if (maxGps < gpsFailureThreshold) return -1;
}
