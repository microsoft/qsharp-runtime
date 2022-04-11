// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#pragma once

#include "gates.hpp"
#include "util/argmaxnrm2.hpp"
#include "util/bititerator.hpp"
#include "util/bitops.hpp"
#include "util/diagmatrix.hpp"
#include "util/tinymatrix.hpp"

#include <atomic>
#include <complex>
namespace Microsoft
{
namespace Quantum
{
namespace SIMULATOR
{
namespace kernels
{

inline std::size_t make_mask(std::vector<unsigned> const& qs)
{
    std::size_t mask = 0;
    for (std::size_t q : qs)
        mask = mask | (1ull << q);
    return mask;
}

template <class T, class A>
void swap(std::vector<T, A>& wfn, unsigned q1, unsigned q2)
{
    if (q1 == q2) return;
    if (q1 > q2) std::swap(q1, q2);
    std::size_t offset1 = 1ull << q1;
    std::size_t offset2 = 1ull << q2;

    std::size_t maskk = offset1 - 1;                  // bits [0...q1-1]
    std::size_t maskj = ((offset2 >> 1) - 1) ^ maskk; // bits [q1...q2-2]
    std::size_t maski = ~((offset2 >> 1) - 1);        // bits [q2-1...]

#ifndef _MSC_VER
#pragma omp parallel for schedule(static)
    for (std::intptr_t i = 0; i < static_cast<std::intptr_t>(wfn.size()); i += 2 * offset2)
        for (std::intptr_t j = 0; j < static_cast<std::intptr_t>(offset2); j += 2 * offset1)
            for (std::intptr_t k = 0; k < static_cast<std::intptr_t>(offset1); k++)
                std::swap(wfn[i + j + k + offset1], wfn[i + j + k + offset2]);
#else
#pragma omp parallel for schedule(static)
    for (std::intptr_t l = 0; l < static_cast<std::intptr_t>(wfn.size()) / 4; ++l)
    {
        std::intptr_t k = l & maskk;
        std::intptr_t j = (l & maskj) << 1;
        std::intptr_t i = (l & maski) << 2;
        std::swap(wfn[i + j + k + offset1], wfn[i + j + k + offset2]);
    }
#endif
}

template <class T, class A>
void jointcollapse(std::vector<T, A>& wfn, std::vector<unsigned> const& qs, bool val)
{
    std::size_t mask = make_mask(qs);

// sum up probabilities for all configuratiions where an odd number of selected bits is set
#pragma omp parallel for schedule(static)
    for (std::intptr_t i = 0; i < static_cast<std::intptr_t>(wfn.size()); i++)
        if (poppar(i & mask) != val) wfn[i] = 0.;
}

template <class T, class A>
unsigned getvalue(
    std::vector<std::complex<T>, A> const& wfn,
    unsigned q,
    double eps = 100. * std::numeric_limits<T>::epsilon())
    __attribute__((noinline)) // TODO(rokuzmin, #885): Try to remove `__attribute__((noinline))` after migrating
                              // to clang-13 on Win and Linux.
{
    std::size_t mask = 1ull << q;
    for (std::size_t i = 0; i < wfn.size(); ++i)
        if (std::abs(wfn[i]) > eps) return (i & mask ? 1 : 0);
    // dummy return
    return 2;
}

template <class T, class A>
void collapse(std::vector<T, A>& wfn, unsigned q, bool val, bool compact = false)
{
    if (compact)
    {
        std::size_t offset = (1ull << q);
        T* base = &wfn[0];
        T* dst = (val ? base : base + offset);
        T* src = dst + offset;
        while (src < base + wfn.size())
        {
            std::copy_n(src, offset, dst);
            src += 2 * offset;
            dst += offset;
        }
        wfn.resize(wfn.size() / 2);
    }
    else
    {
        std::size_t mask = (1ull << q);
        std::size_t state = (val ? mask : 0ul);
#pragma omp parallel for schedule(static)
        for (std::intptr_t i = 0; i < static_cast<std::intptr_t>(wfn.size()); ++i)
            if ((i & mask) != state) wfn[i] = 0.;
    }
}

template <class T, class A>
bool isclassical(
    std::vector<std::complex<T>, A> const& wfn,
    std::size_t q,
    T eps = 100. * std::numeric_limits<T>::epsilon())
{
    std::size_t offset = 1ull << q;
    bool have0 = false;
    bool have1 = false;

    std::size_t maski = ~(offset - 1);
#ifndef _MSC_VER
#pragma omp parallel for schedule(static) reduction(|| : have0, have1)
    for (std::intptr_t i = 0; i < static_cast<std::intptr_t>(wfn.size()); i += 2 * offset)
        for (std::intptr_t j = 0; j < static_cast<std::intptr_t>(offset); ++j)
        {
            have0 = have0 || std::norm(wfn[i + j]) >= eps;
            have1 = have1 || std::norm(wfn[i + j + offset]) >= eps;
        }
#else
#pragma omp parallel for schedule(static) reduction(|| : have0, have1)
    for (std::intptr_t l = 0; l < static_cast<std::intptr_t>(wfn.size()) / 2; l++)
    {
        std::intptr_t j = l % offset;
        std::intptr_t i = ((l & maski) << 1);
        have0 = have0 || std::norm(wfn[i + j]) >= eps;
        have1 = have1 || std::norm(wfn[i + j + offset]) >= eps;
    }
#endif

    if (have0 && have1) return false;
    return true;
}

template <class T, class A>
double jointprobability(std::vector<T, A> const& wfn, std::vector<unsigned> const& qs, bool val = true)
{
    std::size_t mask = 0;
    double prob = 0.;
    for (std::size_t q : qs)
        mask = mask | (1ull << q);
// sum up probabilities for all configuratiions where an odd number of selected bits is set
#pragma omp parallel for schedule(static) reduction(+ : prob)
    for (std::intptr_t i = 0; i < static_cast<std::intptr_t>(wfn.size()); i++)
        if (poppar(i & mask) == val) prob += std::norm(wfn[i]);
    return prob;
}

template <class T, class A>
double probability(std::vector<std::complex<T>, A> const& wfn, unsigned q)
{
    std::size_t offset = 1ull << q;
    T prob = 0.;
    std::size_t maski = ~(offset - 1);
#ifndef _MSC_VER
#pragma omp parallel for schedule(static) reduction(+ : prob)
    for (std::intptr_t i = offset; i < static_cast<std::intptr_t>(wfn.size()); i += 2 * offset)
        for (std::intptr_t d = 0; d < static_cast<std::intptr_t>(offset); ++d)
            prob += std::norm(wfn[i + d]);
#else
#pragma omp parallel for schedule(static) reduction(+ : prob)
    for (std::intptr_t l = 0; l < static_cast<std::intptr_t>(wfn.size()) / 2; l++)
    {
        std::intptr_t j = l % offset;
        std::intptr_t i = offset + ((l & maski) << 1);
        prob += std::norm(wfn[i + j]);
    }
#endif

    return prob;
}

inline bool isDiagonal(std::vector<Gates::Basis> const& b)
{
    for (auto x : b)
        if (x == Gates::PauliX || x == Gates::PauliY) return false;
    return true;
}

// power of square root of -1
inline ComplexType iExp(int power)
{
    using namespace std::literals::complex_literals;
    int p = ((power % 4) + 8) % 4;
    switch (p)
    {
    case 0:
        return 1;
    case 1:
        return 1i;
    case 2:
        return -1;
    case 3:
        return -1i;
    default:
        assert(false);
    }
    return 0;
}

template <class T, class A>
void apply_controlled_exp(
    std::vector<std::complex<T>, A>& wfn,
    std::vector<Gates::Basis> const& b,
    double phi,
    std::vector<unsigned> const& cs,
    std::vector<unsigned> const& qs)
{
    assert(qs.size() > 1);
    unsigned lowest = *std::min_element(qs.begin(), qs.end());

    std::size_t offset = 1ull << lowest;
    std::size_t cmask = make_mask(cs);
    std::size_t cmasku = cmask & (~(offset - 1));

    if (isDiagonal(b))
    {
        std::size_t mask = make_mask(qs);
        ComplexType phase = std::exp(ComplexType(0., -phi));

#pragma omp parallel for schedule(static)
        for (std::intptr_t x = 0; x < static_cast<std::intptr_t>(wfn.size()); x++)
            if ((x & cmask) == cmask) wfn[x] *= (poppar(x & mask) ? phase : std::conj(phase));
    }
    else
    { // see Exp-implementation-details.txt for the explanation of the algorithm below
        std::size_t xy_bits = 0;
        std::size_t yz_bits = 0;
        int y_count = 0;
        for (std::size_t i = 0; i < b.size(); ++i)
        {
            switch (b[i])
            {
            case Gates::PauliX:
                xy_bits |= (1ull << qs[i]);
                break;
            case Gates::PauliY:
                xy_bits |= (1ull << qs[i]);
                yz_bits |= (1ull << qs[i]);
                ++y_count;
                break;
            case Gates::PauliZ:
                yz_bits |= (1ull << qs[i]);
                break;
            case Gates::PauliI:
                break;
            default:
                assert(false);
            }
        }

        T alpha = std::cos(phi);
        ComplexType beta = std::sin(phi) * iExp(3 * y_count + 1);
        ComplexType gamma = std::sin(phi) * iExp(y_count + 1);

#pragma omp parallel for schedule(static)
        for (std::intptr_t x = 0; x < static_cast<std::intptr_t>(wfn.size()); x++)
        {
            std::intptr_t t = x ^ xy_bits;
            if (x < t && ((x & cmask) == cmask))
            {
                auto parity = poppar(x & yz_bits);
                auto a = wfn[x];
                auto b = wfn[t];
                wfn[x] = alpha * a + (parity ? -beta : beta) * b;
                wfn[t] = alpha * b + (parity ? -gamma : gamma) * a;
            }
        }
    }
}

template <class T, class A>
double jointprobability(
    std::vector<T, A> const& wfn,
    std::vector<Gates::Basis> const& b,
    std::vector<unsigned> const& qs,
    bool val = true)
{
    assert(qs.size() > 1);

    double prob = 0.;
    unsigned lowest = *std::min_element(qs.begin(), qs.end());

    std::size_t offset = 1 << lowest;

    if (isDiagonal(b))
    {
        std::size_t mask = make_mask(qs);
#pragma omp parallel for schedule(static) reduction(+ : prob)
        for (std::intptr_t i = 0; i < static_cast<std::intptr_t>(wfn.size()); i++)
            if (poppar(i & mask) == val) prob += std::norm(wfn[i]);
    }
    else
    {
        std::size_t xy_bits = 0;
        std::size_t yz_bits = 0;
        int ipow = 1;
        for (unsigned i = 0; i < b.size(); ++i)
        {
            switch (b[i])
            {
            case Gates::PauliX:
                xy_bits |= (1ull << qs[i]);
                break;
            case Gates::PauliY:
                xy_bits |= (1ull << qs[i]);
                yz_bits |= (1ull << qs[i]);
                ++ipow;
                break;
            case Gates::PauliZ:
                yz_bits |= (1ull << qs[i]);
                break;
            default:
                assert(false);
            }
        }

        auto parity_delta = poppar(xy_bits & yz_bits);
        T alpha1 = 1. / sqrt(2.);
        ComplexType beta1 = iExp(ipow) * alpha1;
        ComplexType sum = 0.;
#pragma omp parallel for schedule(static) reduction(+ : sum)
        for (std::intptr_t x = 0; x < static_cast<std::intptr_t>(wfn.size()); x++)
        {
            std::size_t t = x ^ xy_bits;
            if (x < t)
            {
                auto parity_x = poppar(x & yz_bits);
                auto parity_t = parity_x ^ parity_delta;
                // to be checked - may be wrong
                sum += std::conj(wfn[x]) * (alpha1 * wfn[x] + (parity_x ^ val ? -beta1 : beta1) * wfn[t]);
                sum += std::conj(wfn[t]) * (alpha1 * wfn[t] + (parity_t ? -beta1 : beta1) * wfn[x]);
            }
        }
        using namespace std::literals::complex_literals;
        prob = std::real((0.5 * (sum * ComplexType(0., 1.) + 1.)));
    }

    return prob;
}

// get the 2-norm
template <class T, class A>
double nrm2(std::vector<std::complex<T>, A> const& x)
{
    double sum = 0.;
#pragma omp parallel for schedule(static) reduction(+ : sum)
    for (std::intptr_t i = 0; i < (std::intptr_t)x.size(); ++i)
        sum += x[i].real() * x[i].real() + x[i].imag() * x[i].imag();
    return std::sqrt(sum);
}

template <class T, class A>
void normalize(std::vector<T, A>& wfn)
{
    double scale = 1. / nrm2(wfn);
#pragma omp parallel for schedule(static)
    for (std::intptr_t i = 0; i < static_cast<std::intptr_t>(wfn.size()); ++i)
        wfn[i] *= scale;
}

template <class T, class A1, class A2>
void subsytemwavefunction_by_pivot(
    std::vector<T, A1> const& wfn,
    std::vector<unsigned> const& qs,
    std::vector<T, A2>& qubitswfn,
    std::size_t pivot_position)
{

    const unsigned bit_size = sizeof(std::size_t) * 8;
    assert(qs.size() > 0);
    for (std::size_t i = 0; i < qs.size() - 1; ++i)
    {
        assert(qs[i] < qs[i + 1]);
    }

    std::size_t max = 1ull << qs.size();

    std::vector<size_t> chunks;

    {
#pragma omp single
        chunks = split_interval_in_chunks(max, omp_get_num_threads());
        int thread_id = omp_get_thread_num();
        if (thread_id < chunks.size() - 1)
        {
            std::size_t start = chunks[thread_id];
            bititerator it(start, pivot_position, qs);
            for (std::size_t i = start; i < chunks[thread_id + 1]; ++i, ++it)
            {
                qubitswfn[i] = wfn[it.b];
            }
        }
    }
}

template <class T, class A1, class A2, class A3>
bool istensorproduct(
    std::vector<T, A1> const& wfn,
    std::vector<unsigned> const& qs1,
    std::vector<T, A2> const& wfn1,
    std::vector<unsigned> const& qs2,
    std::vector<T, A3> const& wfn2,
    T phase,
    double tolerance)
{

    const unsigned bit_size = sizeof(std::size_t) * 8;
    assert(wfn.size() == wfn1.size() * wfn2.size());

    assert(wfn1.size() == 1ull << qs1.size());
    assert(wfn2.size() == 1ull << qs2.size());

    assert(qs2 == complement(qs1, static_cast<unsigned>(qs1.size() + qs2.size())));
    assert(qs1 == complement(qs2, static_cast<unsigned>(qs1.size() + qs2.size())));

    std::vector<size_t> chunks = split_interval_in_chunks(wfn1.size(), 1);

    double tol_squared = tolerance * tolerance;

    std::bitset<bit_size> compl_bits(0);
    for (unsigned i : qs2)
    {
        compl_bits.set(i);
    }
    std::size_t compl_st = compl_bits.to_ullong();

    std::atomic<bool> go(true);
    {
        int thread_id = omp_get_thread_num();
        if (thread_id < chunks.size() - 1)
        {
            std::size_t st = chunks[thread_id];
            bititerator it_compl(st, compl_st, qs1);
            bititerator it(st, 0, qs1);
            bititerator it_inner(0, qs2);
            for (std::size_t i = st; i < chunks[thread_id + 1] && go; ++i, ++it, ++it_compl)
            {
                it_inner.b = it.b;
                it_inner.mask_values = it_compl.b;
                T val = phase * wfn1[i];
                for (std::size_t i_inner = 0; i_inner < wfn2.size() && go; ++i_inner, ++it_inner)
                {
                    if (std::norm(val * wfn2[i_inner] - wfn[it_inner.b]) > tol_squared)
                    {
                        go = false;
                    }
                }
            }
        }
    }

    return go;
}

// Extracts wave function for a given subset of qubits. Returns true and writes wave-function into
// qubitswfn if given subset of qubits and its complement are in separable state.
template <class T, class A1, class A2>
bool subsytemwavefunction(
    std::vector<T, A1> const& wfn,
    std::vector<unsigned> const& qs,
    std::vector<T, A2>& qubitswfn,
    double tolerance)
{
    const unsigned bit_size = sizeof(std::size_t) * 8;

    assert(qubitswfn.size() == 1ull << qs.size());
    assert(tolerance > 0.0);

    // We need a sorted list of qubits:
    std::vector<unsigned> sorted(qs);
    std::sort(sorted.begin(), sorted.end());

    std::size_t pivot_position = argmaxnrm2(wfn);
    T pivot = wfn[pivot_position];
    T pivot_phase = std::conj(pivot / std::abs(pivot));

    subsytemwavefunction_by_pivot(wfn, sorted, qubitswfn, pivot_position);
    normalize(qubitswfn);

    unsigned total_qubits = ilog2(wfn.size());

    if (total_qubits > sorted.size())
    {
        std::vector<unsigned> qs_rest = complement(sorted, total_qubits);
        std::vector<T, A1> qubitswfn_rest(1ull << (qs_rest.size()));
        assert(qubitswfn_rest.size() * qubitswfn.size() == wfn.size());
        subsytemwavefunction_by_pivot(wfn, qs_rest, qubitswfn_rest, pivot_position);
        normalize(qubitswfn_rest);

        // it remains to check that we indeed have a tensor product
        if (sorted.size() > qs_rest.size())
        {
            if (!istensorproduct(wfn, sorted, qubitswfn, qs_rest, qubitswfn_rest, pivot_phase, tolerance)) return false;
        }
        else
        {
            if (!istensorproduct(wfn, qs_rest, qubitswfn_rest, sorted, qubitswfn, pivot_phase, tolerance)) return false;
        }
    }

    // put back to original sorting:
    for (std::size_t i = 0; i < qs.size(); ++i)
    {
        if (sorted[i] != qs[i])
        {
            for (std::size_t p = i + 1; p < qs.size(); ++p)
            {
                if (sorted[p] == qs[i])
                {
                    swap(qubitswfn, i, p);
                    std::swap(sorted[p], sorted[i]);
                    break;
                }
            }
        }
    }

    return true;
}
} // namespace kernels
} // namespace SIMULATOR
} // namespace Quantum
} // namespace Microsoft
