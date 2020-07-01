// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include "simulator/capi.hpp"
#include <cassert>
#include <cmath>
#include <iostream>
#include <fstream>
#include <vector>
#include <complex>
#include <array>
#include <omp.h>
#include <chrono>
#include <regex>
#include <string>
#include <vector>

#include "util/cpuid.hpp" //@@@DBG
#include "capi.hpp"

using namespace std;

// some convenience functions
void CX(unsigned sim_id, unsigned c, unsigned q)
{
    MCX(sim_id,1,&c,q);
}

void CZ(unsigned sim_id, unsigned c, unsigned q)
{
    MCZ(sim_id,1,&c,q);
}

void Ry(unsigned sim_id, double phi, unsigned q)
{
    R(sim_id,2,phi,q);
}

void CRz(unsigned sim_id, double phi, unsigned c, unsigned q)
{
    MCR(sim_id,3,phi,1,&c,q);
}

void CRx(unsigned sim_id, double phi, unsigned c, unsigned q)
{
    MCR(sim_id,1,phi,1,&c,q);
}


void dump(unsigned sim_id, const char* label)
{
    auto dump_callback = [](size_t idx, double r, double i) {
        std::cout << idx << ":\t" << r << '\t' << i << '\n';
        return true;
    };
    auto sim_ids_callback = [](unsigned idx) { std::cout << idx << " "; };

    std::cout << label << "\n" << "wave function for ids (least to most significant): ["; 
    DumpIds(sim_id, sim_ids_callback);
    std::cout << "]\n";
    Dump(sim_id, dump_callback);
}

void test_teleport()
{
    auto sim_id = init();

    unsigned qs[] = { 0, 1, 2 };

    dump(sim_id, "teleport-pre.txt");

    allocateQubit(sim_id, 0);
    allocateQubit(sim_id, 1);

    dump(sim_id, "teleport-start.txt");

    // create a Bell pair
    H(sim_id, 0);
    MCX(sim_id, 1, qs, 1);

    allocateQubit(sim_id, 2);
    // create quantum state
    H(sim_id, 2);
    R(sim_id, 3, 1.1, 2);

    // teleport
    MCX(sim_id, 1, &qs[2], 1);
    H(sim_id, 2);
    M(sim_id, 2);
    M(sim_id, 1);
    MCX(sim_id, 1, &qs[1], 0);
    MCZ(sim_id, 1, &qs[2], 0);

    dump(sim_id, "teleport-middle.txt");

    // check teleportation success
    R(sim_id, 3, (-1.1), 0);
    H(sim_id, 0);
    assert(M(sim_id, 0)==false);

    dump(sim_id, "teleport-end.txt");

    release(sim_id, 0);
    release(sim_id, 1);
    release(sim_id, 2);

    dump(sim_id, "teleport-post.txt");

    destroy(sim_id);
}

std::vector<std::vector<std::int32_t>> loadPrb(int circStart, int circStop) {
    std::vector<std::vector<std::int32_t>> rslt;
    for (int k = circStart; k < circStop; k++) {
        unsigned c = k - 1;
        if (k > 0)
            for (int j = 0; j < 5; j++) {
                std::vector<std::int32_t> nums = { k - 1, k };
                rslt.push_back(nums);
            }
        if (k % 5 == 0) {
            for (int j = 0; j < 5; j++) {
                std::vector<std::int32_t> nums = { k };
                rslt.push_back(nums);
            }
        }
    }
    return rslt;
}

std::vector<std::int32_t> splitNums(const std::string& str, char delim = ',') {
    std::vector<std::int32_t> nums;
    size_t start;
    size_t end = 0;
    while ((start = str.find_first_not_of(delim, end)) != std::string::npos) {
        end = str.find(delim, start);
        nums.push_back(stoi(str.substr(start, end - start)));
    }
    return nums;
}

std::vector<std::vector<std::int32_t>> loadTest(char* fName,bool doClusters) {
    std::vector<std::vector<std::int32_t>> rslt;
    std::vector<std::int32_t> empty;
    string line;
    ifstream file(fName);
    if (!file.is_open()) throw(std::invalid_argument("Can't open input file"));

    int phase = 0;
    if (doClusters) phase = 2;

    regex reOrig("^=== Original:.*");
    regex reGate("^\\s*(\\d+):\\s+(.+)\\[(.*)\\]");
    regex reClusters("^=== Clusters.*");
    regex reCluster("^==== cluster\\[\\s*(\\d+)\\]:.*");
    smatch sm;

    while (getline(file, line)) {
        if (phase == 99) break;
        switch (phase) {
        case 0:
            if (regex_match(line, sm, reOrig)) phase = 1;
            break;
        case 1:
            if (regex_match(line, sm, reGate)) {
                auto qs = splitNums(sm[3]);
                rslt.push_back(qs);
            }
            else phase = 99;
            break;
        case 2:
            if (regex_match(line, reClusters)) 
                phase = 3;
            break;
        case 4:
            if (regex_match(line, sm, reGate)) {
                auto qs = splitNums(sm[3]);
                rslt.push_back(qs);
                break;
            }
            else phase = 3;
        case 3:
            if (regex_match(line, sm, reCluster)) {
                rslt.push_back(empty);
                phase = 4;
            }
            break;
        }
    }
    file.close();
    return rslt;
}

void sprintf0(char* buf, int bufSiz, const char* str) {
#ifdef _MSC_VER
    sprintf_s(buf, bufSiz, str);
#else
    sprintf(buf, "%s", str);
#endif
}

void sprintf1(char* buf, int bufSiz,const char* str, const char* arg1) {
#ifdef _MSC_VER
    sprintf_s(buf, bufSiz, str, arg1);
#else
    sprintf(buf, "%s", str, arg1);
#endif
}

void sprintf3(char* buf, int bufSiz,const char* fmt,const char* arg1, int arg2, int arg3) {
#ifdef _MSC_VER
    sprintf_s(buf, bufSiz, fmt, arg1, arg2, arg3);
#else
    sprintf(buf, fmt, arg1, arg2, arg3);
#endif
}

int numQs(vector<vector<int32_t>> prb) {
    int mx = -1;
    for (auto i : prb)
        for (auto j : i)
            if (j > mx) mx = j;
    return (mx + 1);
}

int main()
{
    int                     nQs, circStart, circStop;
    vector<vector<int32_t>> prb;
    /*
            doRange(0,2) - location in wave function (L,C,H)
                prbIdx: 0=15q 1=26qs 2,3=shor_8_4
                    fuseSpan(1,7)
                        numThreads(1,4) [upto 16 on big machines]
                            simTyp: 1=Generic 2=AVX 3=AVX2 4=AVX512
    */
    const int testCnt = 56;
    int tests[testCnt][5] = {
        // rng prb spn thr sim
        {   1,  2,  4,  4,  4}, // 4 bits Shor
        {   1,  3,  4,  4,  4},
        {   1,  4,  4,  4,  4}, // 6 bits Shor
        {   1,  5,  4,  4,  4},
        {   1,  6,  4,  4,  4}, // 8 bits Shor
        {   1,  7,  4,  4,  4},
        {   1,  8,  4,  4,  4}, // 10 bits Shor
        {   1,  9,  4,  4,  4},
        {   1, 10,  4,  4,  4}, // 12 bits Shor
        {   1, 11,  4,  4,  4},
        {   1,  2,  6,  4,  4}, // 4 bits Shor
        {   1,  3,  6,  4,  4},
        {   1,  4,  6,  4,  4}, // 6 bits Shor
        {   1,  5,  6,  4,  4},
        {   1,  6,  6,  4,  4}, // 8 bits Shor
        {   1,  7,  6,  4,  4},
        {   1,  8,  6,  4,  4}, // 10 bits Shor
        {   1,  9,  6,  4,  4},
        {   1, 10,  6,  4,  4}, // 12 bits Shor
        {   1, 11,  6,  4,  4},
        {   1, 12,  6,  4,  4}, // 14 bits Shor
        {   1, 13,  6,  4,  4},
        // Index: 22
            {   1, 14,  4,  4,  4}, // Suprem_4_4
            {   1, 15,  4,  4,  4},
            {   1, 16,  4,  4,  4}, // Suprem_5_4
            {   1, 17,  4,  4,  4},
            {   1, 18,  6,  4,  4}, // Suprem_4_6
            {   1, 19,  6,  4,  4},
            {   1, 20,  6,  4,  4}, // Suprem_5_6
            {   1, 21,  6,  4,  4},
            // Index: 30
                {   1, 22,  1,  4,  4}, // Suprem_4_4
                {   1, 23,  1,  4,  4}, // Suprem_5_4
            // 32: Big machine test
                {   1, 18,  6,  6,  4}, // Suprem_4_6
                {   1, 19,  6,  6,  4},
                {   1, 20,  6,  6,  4}, // Suprem_5_6
                {   1, 21,  6,  6,  4},
                {   1, 18,  6,  8,  4}, // Suprem_4_6
                {   1, 19,  6,  8,  4},
                {   1, 20,  6,  8,  4}, // Suprem_5_6
                {   1, 21,  6,  8,  4},
                {   1, 18,  6, 10,  4}, // Suprem_4_6
                {   1, 19,  6, 10,  4},
                {   1, 20,  6, 10,  4}, // Suprem_5_6
                {   1, 21,  6, 10,  4},
                {   1, 18,  6, 12,  4}, // Suprem_4_6
                {   1, 19,  6, 12,  4},
                {   1, 20,  6, 12,  4}, // Suprem_5_6
                {   1, 21,  6, 12,  4},
                {   1, 18,  6, 14,  4}, // Suprem_4_6
                {   1, 19,  6, 14,  4},
                {   1, 20,  6, 14,  4}, // Suprem_5_6
                {   1, 21,  6, 14,  4},
                {   1, 18,  6, 16,  4}, // Suprem_4_6
                {   1, 19,  6, 16,  4},
                {   1, 20,  6, 16,  4}, // Suprem_5_6
                {   1, 21,  6, 16,  4},
    };

    const char* xtras[3] = { "", "S0", "S1" };

    for (int idxXtra = 0; idxXtra < 3; idxXtra++) {
        const char* xtra = xtras[idxXtra];
        printf("==== idxXtra: %d\n",idxXtra);

        for (int tIdx = 0; tIdx < testCnt; tIdx++) {
            int doRange = tests[tIdx][0];
            int prbIdx = tests[tIdx][1];
            int fuseSpan = tests[tIdx][2];
            int numThreads = tests[tIdx][3];
            int simTyp = tests[tIdx][4];
            char fName[30];

            if (prbIdx < 2) continue;       // Ony do Shor and Supremacy tests for now
            if (prbIdx == 12) continue;     // Don't do 31 qubit test
            if (prbIdx == 13) continue;     // Don't do 31 qubit test
            if (tIdx >= 32) break;          // Not on a big machine

            if (prbIdx < 2) {
                if (prbIdx == 0) nQs = 15;
                else             nQs = 26;
                circStart = 0;
                circStop = nQs;
                if (doRange == 0) { circStop = 7; }
                if (doRange == 2) { circStart = nQs - 7; }
                sprintf0(fName, sizeof(fName), "bench");
                prb = loadPrb(circStart, circStop);
            }
            else if (prbIdx == 22) {
                sprintf1(fName, sizeof(fName), "suprem%s_4_4.log", xtra);
                prb = loadTest(fName, false);
                nQs = numQs(prb);
            }
            else if (prbIdx == 23) {
                sprintf1(fName, sizeof(fName), "suprem%s_5_4.log", xtra);
                prb = loadTest(fName, false);
                nQs = numQs(prb);
            }
            else if (prbIdx >= 14) {
                int siz = ((prbIdx - 14) / 2 & 1) == 1 ? 5 : 4;
                bool doClus = (prbIdx & 1) == 1;
                sprintf3(fName, sizeof(fName), "suprem%s_%d_%d.log", xtra, siz, fuseSpan);
                prb = loadTest(fName, doClus);
                nQs = numQs(prb);
            }
            else {
                int bits = ((prbIdx & 0xFE) + 2);
                bool doClus = (prbIdx & 1) == 1;
                sprintf3(fName, sizeof(fName), "shor%s_%d_%d.log", xtra, bits, fuseSpan);
                prb = loadTest(fName, doClus);
                nQs = numQs(prb);
            }
            printf("@@@DBG nQs=%d max=%d procs=%d thrds=%d range=%d prb=%d tst=%d fName=%s\n",
                nQs, omp_get_max_threads(), omp_get_num_procs(), omp_get_num_threads(), doRange, prbIdx, tIdx, fName);
            fflush(stdout);

            if (simTyp == 4 && (!Microsoft::Quantum::haveAVX512())) continue;
            if (simTyp == 3 && (!Microsoft::Quantum::haveFMA() || !Microsoft::Quantum::haveAVX2())) continue;
            if (simTyp == 2 && !Microsoft::Quantum::haveAVX()) continue;

            auto sim_id = initDBG(simTyp, fuseSpan, 999, numThreads);

            for (int q = 0; q < nQs; q++) allocateQubit(sim_id, q);

            if (prbIdx < 2) {
                for (int k = 1; k < nQs; k++) {                     // Get everyone entangled
                    unsigned c = k - 1;
                    MCX(sim_id, 1, &c, k);
                }
            }

            std::chrono::system_clock::time_point start = std::chrono::system_clock::now();
            for (int i = 0; i < 100000; i++) {
                for (int i = 0; i < prb.size(); i++) {
                    auto qs = prb[i];
                    switch (qs.size()) {
                    case 0: // Need to force a flush (end of cluster)
                        Flush(sim_id);
                        break;
                    case 1:
                        H(sim_id, qs[0]);
                        break;
                    case 2:
                        CX(sim_id, qs[0], qs[1]);
                        break;
                    case 3:
                    {
                        uint32_t cs[] = { (uint32_t)qs[0], (uint32_t)qs[1] };
                        MCX(sim_id, 2, cs, qs[2]);
                    }
                    break;
                    default:
                        throw(std::invalid_argument("Didn't expect more then 3 wire gates"));
                    }

                    std::chrono::system_clock::time_point curr = std::chrono::system_clock::now();
                    std::chrono::duration<double> elapsed = curr - start;
                    if (elapsed.count() >= 60.0) break;
                }
            }

            destroy(sim_id);
        }
    }
}

#if 0 // OpenMP test
    double thrd1elapsed = 1.0;
    for (int thrds = 1; thrds < 9; thrds++) {
        std::chrono::system_clock::time_point start = std::chrono::system_clock::now();
        omp_set_num_threads(thrds);
        double rslts[8] = { 0,0,0,0,0,0,0,0 };
        int outer = 800000;
        int inner = 2000;
        #pragma omp parallel for schedule(static,outer/100)
        for (int i = 0; i < outer; i++) {
            double x = 1.0;
            for (int j = 0; j < inner; j++) x += sqrt((double)j);
            rslts[omp_get_thread_num()] += x;
        }
        std::chrono::system_clock::time_point curr = std::chrono::system_clock::now();
        std::chrono::duration<double> elapsed = curr - start;
        double elap = elapsed.count();
        if (thrds == 1) thrd1elapsed = elap;
        printf("@@@DBG threads: %d Elapsed: %.2f Factor: %.2f\n", thrds, elap, thrd1elapsed/elap);
    }
}
#endif
