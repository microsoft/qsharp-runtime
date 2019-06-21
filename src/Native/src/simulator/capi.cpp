// Copyright © 2017 Microsoft Corporation. All Rights Reserved.

#include "simulator/capi.hpp"
#include "simulator/simulator.hpp"
#include "simulator/factory.hpp"
using namespace Microsoft::Quantum::Simulator;

extern "C" {

// init and cleanup
MICROSOFT_QUANTUM_DECL unsigned init()
{
  return Microsoft::Quantum::Simulator::create();
}
  
MICROSOFT_QUANTUM_DECL void destroy(unsigned id)
  {
    Microsoft::Quantum::Simulator::destroy(id);
  }

MICROSOFT_QUANTUM_DECL void seed(unsigned id, unsigned s)
{
  psis[id]->seed(s);
}

// non-quantum
MICROSOFT_QUANTUM_DECL std::size_t random_choice(unsigned id, std::size_t n, double* p)
{
    return psis[id]->random(n, p);
}

MICROSOFT_QUANTUM_DECL double JointEnsembleProbability(unsigned id, unsigned n, int* b, unsigned* q)
{
    std::vector<Gates::Basis> bv;
    for (unsigned i = 0; i < n; ++i)
        bv.push_back(static_cast<Gates::Basis>(*(b + i)));
    std::vector<unsigned> qv(q, q + n);
    return psis[id]->JointEnsembleProbability( bv, qv);
}


MICROSOFT_QUANTUM_DECL void allocateQubit(unsigned id, unsigned q)
{
    psis[id]->allocateQubit(q);
}

MICROSOFT_QUANTUM_DECL void release(unsigned id,unsigned q)
{
    psis[id]->release(q);
}

MICROSOFT_QUANTUM_DECL unsigned num_qubits(unsigned id)
{
  return psis[id]->num_qubits();
}

#define FWDGATE1(G)                                                                                                    \
MICROSOFT_QUANTUM_DECL void G(unsigned id, unsigned q)                                                                          \
    {                                                                                                                  \
        psis[id]->G(q);                                                                           \
    }
#define FWDGATE2(G)                                                                                                    \
    MICROSOFT_QUANTUM_DECL void G(unsigned id, unsigned q1, unsigned q2)                                                            \
    {                                                                                                                  \
        psis[id]->G(q1, q2);                                                                      \
    }
#define FWDGATE3(G)                                                                                                    \
    MICROSOFT_QUANTUM_DECL void G(unsigned id, unsigned q1, unsigned q2, unsigned q3)                                               \
    {                                                                                                                  \
        psis[id]->G(q1, q2, q3);                                                                  \
    }
#define FWDCSGATE1(G)                                                                                                  \
    MICROSOFT_QUANTUM_DECL void MC##G(unsigned id, unsigned n, unsigned* c, unsigned q)                                             \
    {                                                                                                                  \
        std::vector<unsigned> vc(c, c + n);                                                                            \
        psis[id]->C##G(vc, q);                                                                    \
    }
#define FWD(G) FWDGATE1(G) FWDCSGATE1(G)

// single-qubit gates
FWD(X)
FWD(Y)
FWD(Z)
FWD(H)
FWD(S)
FWD(T)
FWD(AdjS)
FWD(AdjT)

#undef FWDGATE1
#undef FWDGATE2
#undef FWDGATE3
#undef FWDCSGATE1
#undef FWD
  
// rotations
    
MICROSOFT_QUANTUM_DECL void R(unsigned id, unsigned b, double phi, unsigned q)
{
    psis[id]->R(static_cast<Gates::Basis>(b), phi, q);
}
  
// multi-controlled rotations
MICROSOFT_QUANTUM_DECL void MCR(unsigned id, unsigned b, double phi, unsigned nc, unsigned* c, unsigned q)
{
    std::vector<unsigned> cv(c, c + nc);
    psis[id]->CR(static_cast<Gates::Basis>(b), phi, cv, q);
}

// Exponential of Pauli operators
MICROSOFT_QUANTUM_DECL void Exp(unsigned id, unsigned n, unsigned* b, double phi, unsigned* q)
{
    std::vector<Gates::Basis> bv;
    for (unsigned i = 0; i < n; ++i)
        bv.push_back(static_cast<Gates::Basis>(*(b + i)));
    std::vector<unsigned> qv(q, q + n);
    psis[id]->Exp(bv, phi, qv);
}
MICROSOFT_QUANTUM_DECL void MCExp(unsigned id, unsigned n, unsigned* b, double phi, unsigned nc, unsigned* c, unsigned* q)
{
    std::vector<Gates::Basis> bv;
    for (unsigned i = 0; i < n; ++i)
        bv.push_back(static_cast<Gates::Basis>(*(b + i)));
    std::vector<unsigned> qv(q, q + n);
    std::vector<unsigned> cv(c, c + nc);
    psis[id]->CExp(bv, phi, cv, qv);
}
/*
MICROSOFT_QUANTUM_DECL void ExpFrac(unsigned id, unsigned n, unsigned* b, int k, int m, unsigned* q)
{
    Exp(id, n, b, M_PI * static_cast<RealType>(k) / static_cast<RealType>(1 << m), q);
}

MICROSOFT_QUANTUM_DECL void MCExpFrac(unsigned id, unsigned n, unsigned* b, int k, int m, unsigned nc, unsigned* c, unsigned* q)
{
    MCExp(id, n, b, M_PI * static_cast<RealType>(k) / static_cast<RealType>(1 << m), nc, c, q);
}
*/
    
// measurements
MICROSOFT_QUANTUM_DECL unsigned M(unsigned id, unsigned q)
{
    return (unsigned)psis[id]->M(q);
}
MICROSOFT_QUANTUM_DECL unsigned Measure(unsigned id, unsigned n, unsigned* b, unsigned* q)
{
    std::vector<Gates::Basis> bv;
    for (unsigned i = 0; i < n; ++i)
        bv.push_back(static_cast<Gates::Basis>(*(b + i)));
    std::vector<unsigned> qv(q, q + n);
    return (unsigned)psis[id]->Measure(bv, qv);
}
    
    /*
MICROSOFT_QUANTUM_DECL void MultiM(unsigned id, unsigned n, unsigned* q, unsigned* res)
{
  std::vector<unsigned> qv(q, q + n);
  auto r = psis[id]->MultiM(qv);
  std::copy_n(r.begin(), n, res);
}

// wave function cheat
MICROSOFT_QUANTUM_DECL std::complex<double> const* wavefunction(unsigned id)
{
    return psis[id]->data();
}
*/
    
// apply permutation of basis states to the wave function
MICROSOFT_QUANTUM_DECL void PermuteBasis(unsigned id, unsigned n, unsigned* q, std::size_t table_size,
    std::size_t *permutation_table)
{
    const std::vector<unsigned> qs(q, q + n);
    psis[id]->permuteBasis(qs, table_size, permutation_table, false);
}
MICROSOFT_QUANTUM_DECL void AdjPermuteBasis(unsigned id, unsigned n, unsigned* q, std::size_t table_size,
    std::size_t *permutation_table)
{
    const std::vector<unsigned> qs(q, q + n);
    psis[id]->permuteBasis(qs, table_size, permutation_table, true);
}


// dump wavefunction to given callback until callback returns false
MICROSOFT_QUANTUM_DECL void Dump(unsigned id, bool (*callback)(size_t, double, double))
{
    psis[id]->dump(callback);
}

// dump the wavefunction of the subset of qubits to the given callback returns false
MICROSOFT_QUANTUM_DECL bool DumpQubits(unsigned id, unsigned n, unsigned* q, bool(*callback)(size_t, double, double))
{
    std::vector<unsigned> qs(q, q + n);
    return psis[id]->dumpQubits(qs, callback);
}

// dump the list of logical qubit ids to given callback
MICROSOFT_QUANTUM_DECL void DumpIds(unsigned id, void(*callback)(unsigned))
{
    psis[id]->dumpIds(callback);
}

}
