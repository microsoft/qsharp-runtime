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
    int phase = 0;
    if (doClusters) phase = 2;

    regex reOrig("^=== Original:");
    regex reGate("^\\s*(\\d+):\\s+(.+)\\[(.*)\\]");
    regex reClusters("^=== Clusters .*");
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

int numQs(vector<vector<int32_t>> prb) {
    int mx = -1;
    for (auto i : prb)
        for (auto j : i)
            if (j > mx) mx = j;
    return (mx + 1);
}

int main()
{
    int                     nQs,circStart,circStop;
    vector<vector<int32_t>> prb;

    for (int doRange = 1; doRange < 2; doRange++) {                             // #### 0,3 Location of qubits in WFN
        for (int prbIdx = 2; prbIdx < 4; prbIdx++) {                            // #### 0=15qs 1=26qs, 2,3=shor_4_4 3=shor_4_4
            switch (prbIdx) {
            case 0:
            case 1:
                if (prbIdx == 0) nQs    = 15;
                else             nQs    = 26;
                circStart               = 0;
                circStop                = nQs;
                if (doRange == 0) { circStop  = 7; }
                if (doRange == 2) { circStart = nQs - 7; }
                prb             = loadPrb(circStart,circStop);
                break;
            case 2:
                prb = loadTest("..\\..\\..\\shor_4_4.log", false);
                nQs = numQs(prb);
                break;
            case 3:
                prb = loadTest("..\\..\\..\\shor_4_4.log", true);
                nQs = numQs(prb);
                break;
            }
            printf("@@@DBG nQs=%d max=%d procs=%d thrds=%d range=%d prb=%d\n", 
                nQs, omp_get_max_threads(), omp_get_num_procs(), omp_get_num_threads(),doRange,prbIdx);
            fflush(stdout);
            for (int fuseSpan = 4; fuseSpan < 5; fuseSpan++) {                  // #### 1,8 Span Size
                for (int numThreads = 4; numThreads < 5; numThreads++) {        // #### 1,5 (or 1,17 for big machine)
                    for (int simTyp = 4; simTyp < 5; simTyp++) {                // #### 1,5 (1=Generic,2=AVX,3=AVX2,4=AVX512)
                        if (simTyp == 4 && (!Microsoft::Quantum::haveAVX512())) continue;
                        if (simTyp == 3 && (!Microsoft::Quantum::haveFMA() || !Microsoft::Quantum::haveAVX2())) continue;
                        if (simTyp == 2 && !Microsoft::Quantum::haveAVX()) continue;

                        auto sim_id = initDBG(simTyp, fuseSpan, 999, numThreads);

                        for (int q = 0; q < nQs; q++) allocateQubit(sim_id, q);

                        for (int k = 1; k < nQs; k++) {                     // Get everyone entangled
                            unsigned c = k - 1;
                            MCX(sim_id, 1, &c, k);
                        }

                        std::chrono::system_clock::time_point start = std::chrono::system_clock::now();
                        for (int i=0; i<100000; i++) {
                            for (int i = 0; i < prb.size(); i++) {
                                auto qs = prb[i];
                                switch (qs.size()) {
                                case 0: // Need to force a flush (end of cluster)
                                    break;
                                case 1:
                                    H(sim_id, qs[0]);
                                    break;
                                case 2:
                                    CX(sim_id, qs[0], qs[1]);
                                    break;
                                case 3:
                                {
                                    uint32_t cs[] = { qs[0], qs[1] };
                                    MCX(sim_id, 2, cs, qs[2]);
                                }
                                break;
                                default:
                                    throw(std::invalid_argument("Didn't expect more then 3 wire gates"));
                                }
                            }

                            std::chrono::system_clock::time_point curr = std::chrono::system_clock::now();
                            std::chrono::duration<double> elapsed = curr - start;
                            if (elapsed.count() >= 25.0) break;
                        }

                        destroy(sim_id);
                    }
                }
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
#endif
}
