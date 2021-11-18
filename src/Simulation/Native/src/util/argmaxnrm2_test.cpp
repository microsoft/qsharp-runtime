// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include "argmaxnrm2.hpp"

#include <cassert>
#include <complex>
#include <vector>

void argmax_test(size_t testSize)
{
    using namespace Microsoft::Quantum;
    std::vector<std::complex<double>> wfn1(testSize);
    std::vector<std::complex<double>> wfn2(testSize);
    for (int i = 0; i < testSize; ++i)
    {
        wfn1[i] = 0.2 * i;
        wfn2[i] = 0.2 * (testSize - i);
    }
    std::size_t argmax1 = argmaxnrm2(wfn1);
    //assert(argmax1 == testSize - 1);
    std::size_t argmax2 = argmaxnrm2(wfn2);
    //assert(argmax2 == 0);
}

int main()
{
    argmax_test(1);    // edge case 1
    argmax_test(2);    // edge case 2
    argmax_test(16);   // typically argument length is power of 2
    argmax_test(32);   // typically argument length is power of 2
    argmax_test(1024); // typically argument length is power of 2
    argmax_test(5040); // 7!
    argmax_test(997);  // prime
    return 0;
}
