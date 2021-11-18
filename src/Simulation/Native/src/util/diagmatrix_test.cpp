// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include "diagmatrix.hpp"
#include <cassert>
#include <complex>
#include <iostream>

template <class T, unsigned N>
void testsize()
{
    // create a matrix
    Microsoft::Quantum::SIMULATOR::DiagMatrix<T, N> mat;

    //assert(mat.rows() == N);
    //assert(mat.cols() == N);
    //assert(mat.size() == N * N);

    // perform element-wise assignment
    for (unsigned i = 0; i < mat.rows(); ++i)
        mat(i, i) = static_cast<T>(2. + i);

    // test const versrion
    Microsoft::Quantum::SIMULATOR::DiagMatrix<T, N> const& matc(mat);

    // test assignment
    // for (unsigned i = 0; i < mat.rows(); ++i)
    //     for (unsigned j = 0; j < mat.cols(); ++j)
    //         //assert(matc(i, j) == (i == j ? 2 + i : 0.));

    // test copy and comparison
    Microsoft::Quantum::SIMULATOR::DiagMatrix<T, N> matb = matc;

    //assert(matb == mat);
    //assert(matb == matc);
    //assert(matc == matb);
    //assert(matc == matc);

//    if (mat.size() != 0) //assert(&mat(0, 0) == mat.data());

    // test assignments
    Microsoft::Quantum::SIMULATOR::DiagMatrix<T, N> mate;
    Microsoft::Quantum::SIMULATOR::DiagMatrix<T, N> matf;
    mate = matc;
    matf = matc;
    //assert(mat == mate);
    //assert(mat == matf);

    // test not equal
    if (matb.size())
    {
        matb(0, 0) = static_cast<T>(-42.);
        //assert(matb != matc);
        //assert(matc != matb);
    }
}

template <class T>
void testassign()
{
    double init[2] = {1., 2.};

    Microsoft::Quantum::SIMULATOR::DiagMatrix<T, 2> mat = init;
    //assert(mat(0, 0) == 1.);
    //assert(mat(1, 1) == 2.);
}

template <class T>
void test()
{
    testsize<T, 1>();
    testsize<T, 2>();
    testassign<T>();
}
int main()
{
    test<float>();
    test<float>();
    test<int>();
    test<std::complex<double>>();

    return 0;
}
