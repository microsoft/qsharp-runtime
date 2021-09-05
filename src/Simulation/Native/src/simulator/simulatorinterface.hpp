// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#pragma once

#include "capi.hpp"
#include "gates.hpp"
#include "types.hpp"
#include "util/openmp.hpp"
#include <vector>

namespace Microsoft
{
namespace Quantum
{
namespace Simulator
{

using namespace Microsoft::Quantum::SIMULATOR;
class SimulatorInterface
{
  public:
    SimulatorInterface()
        : mutex_ptr(new recursive_mutex_type())
    {
    }

    virtual ~SimulatorInterface() {}

    virtual std::size_t random(std::size_t n, double* d) = 0;

    virtual double JointEnsembleProbability(std::vector<Gates::Basis> bs, std::vector<unsigned> qs) = 0;

    virtual bool InjectState(
        const std::vector<logical_qubit_id>& qubits,
        const std::vector<ComplexType>& amplitudes) = 0;

    // allocate and release
    virtual void allocateQubit(unsigned q) = 0;
    virtual bool release(unsigned q) = 0;
    virtual unsigned num_qubits() const = 0;

    // single-qubit gates

#define GATE1IMPL(OP) virtual void OP(unsigned q) = 0;
#define GATE1MCIMPL(OP) virtual void C##OP(std::vector<unsigned> const& c, unsigned q) = 0;
#define GATE1(OP) GATE1IMPL(OP) GATE1MCIMPL(OP)

    GATE1(X)
    GATE1(Y)
    GATE1(Z)
    GATE1(H)
    GATE1(T)
    GATE1(S)
    GATE1(AdjT)
    GATE1(AdjS)

#undef GATE1
#undef GATE1IMPL
#undef GATE1CIMPL
#undef GATE1MCIMPL

    // rotations
    virtual void R(Gates::Basis b, double phi, unsigned q) = 0;
    virtual void CR(Gates::Basis b, double phi, std::vector<unsigned> const& c, unsigned q) = 0;

    // Exponential of Pauli operators
    virtual void CExp(
        std::vector<Gates::Basis> bs,
        double phi,
        std::vector<unsigned> const& cs,
        std::vector<unsigned> qs) = 0;

    virtual void Exp(std::vector<Gates::Basis> const& bs, double phi, std::vector<unsigned> const& qs)
    {
        CExp(bs, phi, std::vector<unsigned>(), qs);
    }

    // measurements

    virtual bool M(unsigned q) = 0;
    virtual bool Measure(std::vector<Gates::Basis> bs, std::vector<unsigned> qs) = 0;

    virtual void seed(unsigned s) = 0;
    virtual void reset() = 0;
    virtual ComplexType const* data() const = 0;

    virtual bool subsytemwavefunction(std::vector<unsigned> const& qs, WavefunctionStorage& qubitswfn, double tolerance)
    {
        assert(false);
        return false;
    };

    virtual void dump(bool (*callback)(size_t, double, double))
    {
        assert(false);
    }
    virtual void dump(TDumpToLocationCallback, TDumpLocation)
    {
        assert(false);
    }
    virtual bool dumpQubits(std::vector<logical_qubit_id> const& qs, bool (*callback)(size_t, double, double))
    {
        assert(false);
        return false;
    }
    virtual bool dumpQubits(std::vector<logical_qubit_id> const& qs, TDumpToLocationCallback callback, TDumpLocation location)
    {
        assert(false);
        return false;
    }
    virtual void dumpIds(void (*callback)(unsigned))
    {
        assert(false);
    }

    // apply permutation of basis states to the wave function
    virtual void permuteBasis(
        std::vector<unsigned> const& qs,
        std::size_t table_size,
        std::size_t const* permutation_table,
        bool adjoint = false)
    {
        throw std::runtime_error("this simulator does not support permutation oracle emulation");
    };

    recursive_mutex_type& getmutex() const
    {
        return *mutex_ptr;
    }

  private:
    std::shared_ptr<recursive_mutex_type> mutex_ptr;
};

} // namespace Simulator
} // namespace Quantum
} // namespace Microsoft
