// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include "tinymatrix.hpp"
#include <cassert>
#include <complex>
#include <iostream>

template <class T, unsigned N, unsigned M>
void testsize()
{
    // create a matrix
    Microsoft::Quantum::SIMULATOR::TinyMatrix<T, N, M> mat;

    assert(mat.rows() == N);
    assert(mat.cols() == M);
    assert(mat.size() == N * M);

    // perform element-wise assignment
    for (unsigned i = 0; i < mat.rows(); ++i)
        for (unsigned j = 0; j < mat.cols(); ++j)
            mat(i, j) = static_cast<T>(2. + i + j);

    // test const versrion
    Microsoft::Quantum::SIMULATOR::TinyMatrix<T, N, M> const& matc(mat);

    // test assignment
    for (unsigned i = 0; i < mat.rows(); ++i)
        for (unsigned j = 0; j < mat.cols(); ++j)
            assert(mat(i, j) == 2. + i + j);

    // test copy and comparison
    Microsoft::Quantum::SIMULATOR::TinyMatrix<T, N, M> matb = matc;

    assert(matb == mat);
    assert(matb == matc);
    assert(matc == matb);
    assert(matc == matc);

    if (mat.size() != 0)
        assert(&mat(0, 0) == mat.data());

    // test assignments
    Microsoft::Quantum::SIMULATOR::TinyMatrix<T, N, M> mate;
    Microsoft::Quantum::SIMULATOR::TinyMatrix<T, N, M> matf;
    mate = matc;
    matf = matc;
    assert(mat == mate);
    assert(mat == matf);

    // test not equal
    if (matb.size())
    {
        matb(0, 0) = static_cast<T>(-42.);
        assert(matb != matc);
        assert(matc != matb);
    }
}

template <class T>
void testassign()
{
    double init[2][2] = {{1., 2.}, {3., 4.}};

    Microsoft::Quantum::SIMULATOR::TinyMatrix<T, 2, 2> mat = init;
    for (unsigned i = 0; i < mat.rows(); ++i)
        for (unsigned j = 0; j < mat.cols(); ++j)
            assert(mat(i, j) == 1. + 2. * i + j);
}

template <class T>
void test()
{
    testsize<T, 1, 1>();
    testsize<T, 1, 2>();
    testsize<T, 2, 2>();
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
