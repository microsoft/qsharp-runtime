// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#pragma once

#include "config.hpp"
#include "gates.hpp"
#include "simulatorinterface.hpp"
#include "util/openmp.hpp"
#include "wavefunction.hpp"

#include <map>
#include <numeric>

namespace Microsoft
{
namespace Quantum
{
namespace SIMULATOR
{

template <class WFN>
class Simulator : public Microsoft::Quantum::Simulator::SimulatorInterface
{
  public:
    using WaveFunctionType = WFN;

    Simulator(unsigned maxlocal = 0u)
        : psi()
    {
    }

    std::size_t random(std::vector<double> const& d)
    {
        recursive_lock_type l(getmutex());
        std::discrete_distribution<std::size_t> dist(d.begin(), d.end());
        return dist(psi.rng());
    }

    std::size_t random(std::size_t n, double* d)
    {
        std::discrete_distribution<std::size_t> dist(d, d + n);
        recursive_lock_type l(getmutex());
        return dist(psi.rng());
    }

    double JointEnsembleProbability(std::vector<Gates::Basis> bs, std::vector<logical_qubit_id> qs)
    {
        removeIdentities(bs, qs);
        if (bs.empty())
        {
            return 0.0;
        }

        recursive_lock_type l(getmutex());
        changebasis(bs, qs, true);
        double p = psi.jointprobability(qs);
        changebasis(bs, qs, false);
        return p;
    }

    bool InjectState(const std::vector<logical_qubit_id>& qubits, const std::vector<ComplexType>& amplitudes)
    {
        recursive_lock_type l(getmutex());
        return psi.inject_state(qubits, amplitudes);
    }

    bool isclassical(logical_qubit_id q)
    {
        recursive_lock_type l(getmutex());
        return psi.isclassical(q);
    }

    // allocate and release
    logical_qubit_id allocate()
    {
        recursive_lock_type l(getmutex());
        return psi.allocate_qubit();
    }

    std::vector<logical_qubit_id> allocate(unsigned n)
    {
        std::vector<logical_qubit_id> qubits;
        qubits.reserve(n);
        recursive_lock_type l(getmutex());

        for (unsigned i = 0; i < n; ++i)
        {
            qubits.push_back(psi.allocate_qubit());
        }
        return qubits;
    }

    void allocateQubit(logical_qubit_id q)
    {
        recursive_lock_type l(getmutex());
        psi.allocate_qubit(q);
    }

    void allocateQubit(std::vector<logical_qubit_id> const& qubits)
    {
        recursive_lock_type l(getmutex());
        for (auto q : qubits)
            psi.allocate_qubit(q);
    }

    bool release(logical_qubit_id q)
    {
        recursive_lock_type l(getmutex());
        flush();
        bool allok = isclassical(q);
        if (allok)
            allok = (psi.getvalue(q) == false);
        else
            M(q);
        psi.release(q);
        return allok;
    }

    bool release(std::vector<logical_qubit_id> const& qs)
    {
        recursive_lock_type l(getmutex());
        bool allok = true;
        for (auto q : qs)
            allok = release(q) && allok;
        return allok;
    }

    // single-qubit gates

#define GATE1IMPL(OP)                                                                                                  \
    void OP(logical_qubit_id q)                                                                                        \
    {                                                                                                                  \
        recursive_lock_type l(getmutex());                                                                                \
        psi.apply(Gates::OP(q));                                                                                       \
    }
#define GATE1CIMPL(OP)                                                                                                 \
    void C##OP(logical_qubit_id c, logical_qubit_id q)                                                                 \
    {                                                                                                                  \
        recursive_lock_type l(getmutex());                                                                                \
        psi.apply_controlled(c, Gates::OP(q));                                                                         \
    }
#define GATE1MCIMPL(OP)                                                                                                \
    void C##OP(std::vector<logical_qubit_id> const& c, logical_qubit_id q)                                             \
    {                                                                                                                  \
        recursive_lock_type l(getmutex());                                                                                \
        psi.apply_controlled(c, Gates::OP(q));                                                                         \
    }
#define GATE1(OP) GATE1IMPL(OP) GATE1CIMPL(OP) GATE1MCIMPL(OP)

    GATE1(X)
    GATE1(Y)
    GATE1(Z)
    GATE1(H)
    GATE1(HY)
    GATE1(T)
    GATE1(S)
    GATE1(AdjHY)
    GATE1(AdjT)
    GATE1(AdjS)

#undef GATE1
#undef GATE1IMPL
#undef GATE1CIMPL
#undef GATE1MCIMPL

#define GATE1IMPL(OP)                                                                                                  \
    void OP(double phi, logical_qubit_id q)                                                                            \
    {                                                                                                                  \
        recursive_lock_type l(getmutex());                                                                                \
        psi.apply(Gates::OP(phi, q));                                                                                  \
    }
#define GATE1CIMPL(OP)                                                                                                 \
    void C##OP(double phi, logical_qubit_id c, logical_qubit_id q)                                                     \
    {                                                                                                                  \
        recursive_lock_type l(getmutex());                                                                                \
        psi.apply_controlled(c, Gates::OP(phi, q));                                                                    \
    }
#define GATE1MCIMPL(OP)                                                                                                \
    void C##OP(double phi, std::vector<logical_qubit_id> const& c, logical_qubit_id q)                                 \
    {                                                                                                                  \
        recursive_lock_type l(getmutex());                                                                                \
        psi.apply_controlled(c, Gates::OP(phi, q));                                                                    \
    }
#define GATE1(OP) GATE1IMPL(OP) GATE1CIMPL(OP) GATE1MCIMPL(OP)

    GATE1(Rx)
    GATE1(Ry)
    GATE1(Rz)

#undef GATE1
#undef GATE1IMPL
#undef GATE1CIMPL
#undef GATE1MCIMPL

    // rotations
    void R(Gates::Basis b, double phi, logical_qubit_id q)
    {
        recursive_lock_type l(getmutex());
        psi.apply(Gates::R(b, phi, q));
    }

    // multi-controlled rotations
    void CR(Gates::Basis b, double phi, std::vector<logical_qubit_id> const& c, logical_qubit_id q)
    {
        recursive_lock_type l(getmutex());
        psi.apply_controlled(c, Gates::R(b, phi, q));
    }

    // Exponential of Pauli operators
    void CExp(
        std::vector<Gates::Basis> bs,
        double phi,
        std::vector<logical_qubit_id> const& cs,
        std::vector<logical_qubit_id> qs)
    {
        if (bs.size() == 0) return;

        logical_qubit_id somequbit = qs.front();
        removeIdentities(bs, qs);

        recursive_lock_type l(getmutex());
        if (bs.size() == 0)
            CR(Gates::PauliI, -2. * phi, cs, somequbit);
        else if (bs.size() == 1)
            CR(bs.front(), -2. * phi, cs, qs.front());
        else
            psi.apply_controlled_exp(bs, phi, cs, qs);
    }

    void Exp(std::vector<Gates::Basis> const& bs, double phi, std::vector<logical_qubit_id> const& qs)
    {
        recursive_lock_type l(getmutex());
        CExp(bs, phi, std::vector<logical_qubit_id>(), qs);
    }

    // measurements

    bool M(logical_qubit_id q)
    {
        recursive_lock_type l(getmutex());
        return psi.measure(q);
    }

    std::vector<bool> MultiM(std::vector<logical_qubit_id> const& qs)
    {
        // ***TODO*** optimized implementation
        recursive_lock_type l(getmutex());
        std::vector<bool> res;
        for (auto q : qs)
            res.push_back(psi.measure(q));
        return res;
    }

    bool Measure(std::vector<Gates::Basis> bs, std::vector<logical_qubit_id> qs)
    {
        recursive_lock_type l(getmutex());
        removeIdentities(bs, qs);
        // ***TODO*** optimized kernels
        changebasis(bs, qs, true);
        bool res = psi.jointmeasure(qs);
        changebasis(bs, qs, false);
        return res;
    }

    void seed(unsigned s)
    {
        recursive_lock_type l(getmutex());
        psi.seed(s);
    }
    void reset()
    {
        recursive_lock_type l(getmutex());
        psi.reset();
    }

    unsigned num_qubits() const
    {
        recursive_lock_type l(getmutex());
        return psi.num_qubits();
    }
    void flush()
    {
        recursive_lock_type l(getmutex());
        psi.flush();
    }
    ComplexType const* data() const
    {
        recursive_lock_type l(getmutex());
        return psi.data().data();
    }

    void dump(bool (*callback)(const char*, double, double))
    {
        recursive_lock_type l(getmutex());
        flush();

        auto wfn = psi.data();
        auto nq = num_qubits();
        std::string label_str(nq, '0');
        for (std::size_t i = 0; i < wfn.size(); i++)
        {
            for (std::size_t j = 0; j < nq; ++j)
                label_str[j] = ((i >> j)&1) ? '1' : '0';
            if (!callback(label_str.c_str(), wfn[i].real(), wfn[i].imag())) return;
        }
    }

    void dump(TDumpToLocationCallback callback, TDumpLocation location) override
    {
        flush();

        auto wfn = psi.data();
        for (std::size_t i = 0; i < wfn.size(); i++)
        {
            if (!callback(i, wfn[i].real(), wfn[i].imag(), location)) return;
        }
    }

    void dumpIds(void (*callback)(logical_qubit_id))
    {
        recursive_lock_type l(getmutex());
        flush();

        std::vector<logical_qubit_id> qubits = psi.get_qubit_ids();
        for (logical_qubit_id q : qubits)
        {
            callback(q);
        }
    }

    bool dumpQubits(std::vector<logical_qubit_id> const& qs, TDumpToLocationCallback callback, TDumpLocation location) override
    {
        assert(qs.size() <= num_qubits());

        WavefunctionStorage wfn(1ull << qs.size());

        if (subsytemwavefunction(qs, wfn, 1e-10))
        {
            for (std::size_t i = 0; i < wfn.size(); i++)
            {
                if (!callback(i, wfn[i].real(), wfn[i].imag(), location)) break;
            }
            return true;
        }
        else
        {
            return false;
        }
    }

    bool dumpQubits(std::vector<logical_qubit_id> const& qs, bool (*callback)(const char*, double, double))
    {
        assert(qs.size() <= num_qubits());

        WavefunctionStorage wfn(1ull << qs.size());
        auto nq = num_qubits();
        std::string label_str(nq, '0');
        if (subsytemwavefunction(qs, wfn, 1e-10))
        {
            for (std::size_t i = 0; i < wfn.size(); i++)
            {
                for (std::size_t j = 0; j < nq; ++j)
                    label_str[j] = ((i >> j)&1) ? '1' : '0';
                if (!callback(label_str.c_str(), wfn[i].real(), wfn[i].imag())) break;
            }
            return true;
        }
        else
        {
            return false;
        }
    }

    // apply permutation of basis states to the wave function
    void permuteBasis(
        std::vector<logical_qubit_id> const& qs,
        std::size_t table_size,
        std::size_t const* permutation_table,
        bool adjoint = false)

    {
#ifndef NDEBUG
        // check the permute function is bijective
        auto test = std::vector<bool>(table_size, false);
        for (size_t i = 0; i < table_size; ++i)
            test.at(permutation_table[i]) = true;
        assert(std::accumulate(test.begin(), test.end(), 0u) == table_size);
#endif

        recursive_lock_type l(getmutex());
        psi.permute_basis(qs, table_size, permutation_table, adjoint);
    }

    bool subsytemwavefunction(std::vector<logical_qubit_id> const& qs, WavefunctionStorage& qubitswfn, double tolerance)
    {
        recursive_lock_type l(getmutex());
        flush();
        return psi.subsytemwavefunction(qs, qubitswfn, tolerance);
    }

  private:
    void changebasis(Gates::Basis b, logical_qubit_id q, bool back)
    {
        if (b == Gates::PauliX)
            H(q);
        else if (b == Gates::PauliY)
        {
            if (back)
                AdjHY(q);
            else
                HY(q);
        }
    }

    void changebasis(std::vector<Gates::Basis> const& bs, std::vector<logical_qubit_id> const& qs, bool back)
    {
        assert(bs.size() == qs.size());
        for (std::size_t i = 0; i < bs.size(); ++i)
            changebasis(bs[i], qs[i], back);
    }

    inline static void removeIdentities(std::vector<Gates::Basis>& b, std::vector<logical_qubit_id>& qs)
    {
        unsigned i = 0;
        while (i != b.size())
        {
            if (b[i] == Gates::PauliI)
            {
                b.erase(b.begin() + i);
                qs.erase(qs.begin() + i);
            }
            else
                ++i;
        }
    }

    WaveFunctionType psi;
};

using WavefunctionType = Wavefunction<ComplexType>;
using SimulatorType = Simulator<WavefunctionType>;

MICROSOFT_QUANTUM_DECL Microsoft::Quantum::Simulator::SimulatorInterface* createSimulator(unsigned = 0u);

} // namespace SIMULATOR
} // namespace Quantum
} // namespace Microsoft
