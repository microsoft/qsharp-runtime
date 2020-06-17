// (C) 2018 ETH Zurich, ITP, Thomas Häner and Damian Steiger

#pragma once

#include "config.hpp"
#include "external/fusion.hpp"
#include "simulator/kernels.hpp"

#ifndef HAVE_INTRINSICS
#include "external/nointrin/kernels.hpp"
#else
#ifdef HAVE_AVX512
#include "external/avx512/kernels.hpp"
#else
#ifdef HAVE_FMA
#include "external/avx2/kernels.hpp"
#else
#include "external/avx/kernels.hpp"
#endif
#endif
#endif

namespace Microsoft
{
namespace Quantum
{
namespace SIMULATOR
{

class Fused
  {
  public:
      Fused() {
        wfnCapacity     = 0u; // used to optimize runtime parameters
        maxFusedSpan    =-1;  // determine span to use at runtime
        maxFusedDepth   = 99; // determine max depth to use at runtime
    }

    inline void reset()
    {
      fusedgates = Fusion();
    }

    
    template <class T, class A>
    void flush(std::vector<T, A>& wfn) const
    {
      if (fusedgates.size() == 0)
        return;
      
      Fusion::Matrix m;
      Fusion::IndexVector qs, cs;
      
      fusedgates.perform_fusion(m, qs, cs);

      std::size_t cmask = 0;
      for (auto c : cs)
        cmask |= (1ull << c);
      
      switch (qs.size())
      {
        case 1:
          ::kernel(wfn, qs[0], m, cmask);
          break;
        case 2:
          ::kernel(wfn, qs[1], qs[0], m, cmask);
          break;
        case 3:
          ::kernel(wfn, qs[2], qs[1], qs[0], m, cmask);
          break;
        case 4:
          ::kernel(wfn, qs[3], qs[2], qs[1], qs[0], m, cmask);
          break;
        case 5:
          ::kernel(wfn, qs[4], qs[3], qs[2], qs[1], qs[0], m, cmask);
          break;
      }

      fusedgates = Fusion();
    }
    
    template <class T, class A1, class A2>
    bool subsytemwavefunction(std::vector<T, A1>& wfn,
                              std::vector<unsigned> const& qs,
                              std::vector<T, A2>& qubitswfn,
                              double tolerance)
    {
      flush(wfn); // we have to flush before we can extract the state
      return kernels::subsytemwavefunction(wfn, qs, qubitswfn, tolerance);
    }
    
    template <class M>
    Fusion::Matrix convertMatrix(M const& m)
    {
      Fusion::Matrix mat(2, Fusion::Matrix::value_type(2));
      for (unsigned i = 0; i < 2; ++i)
        for (unsigned j = 0; j < 2; ++j)
          mat[i][j] = static_cast<ComplexType>(m(i, j));
      return mat;
    }
    
    template <class T, class A, class M>
    void apply_controlled(std::vector<T, A>& wfn, M const& mat, std::vector<unsigned> const& cs, unsigned q)
    {
      // Major runtime logic change here

        // Have to update capacity as the WFN grows
        if (wfnCapacity != wfn.capacity()) {
            wfnCapacity     = wfn.capacity();
            char* envNT = NULL;
            size_t len;
#ifdef _MSC_VER
            errno_t err = _dupenv_s(&envNT, &len, "OMP_NUM_THREADS");
#else
            envNT = getenv("OMP_NUM_THREADS");
#endif
            if (envNT == NULL) { // If the user didn't force the number of threads, make an intelligent guess
                int nMaxThrds = 4;
                if (wfnCapacity < 1ul << 20) nMaxThrds = 3;
                int nProcs = omp_get_num_procs();
                if (nProcs < 3) nMaxThrds = nProcs;
                omp_set_num_threads(nMaxThrds);
            }

            // This is now pretty much unlimited, could be set in the future
            maxFusedDepth = 99;

            // Default for large problems (optimized with benchmarks)
            maxFusedSpan = 3;

            // Reduce size for small problems (optimized with benchmarks)
            if (wfnCapacity < 1ul << 20) maxFusedSpan = 2;
        }

        // New rules of when to stop fusing
        Fusion::IndexVector qs      = std::vector<unsigned>(1, q);
        if (fusedgates.predict(qs, cs) > maxFusedSpan || fusedgates.size() >= maxFusedDepth) flush(wfn);
        fusedgates.insert(convertMatrix(mat), qs, cs);
    }

    template <class T, class A, class M>
    void apply(std::vector<T, A>& wfn, M const& mat, unsigned q)
    {
      std::vector<unsigned> cs;
      apply_controlled(wfn, mat, cs, q);
    }
  private:
    mutable Fusion fusedgates;

    //: New runtime optimizatin settings
    mutable size_t wfnCapacity;
    mutable int    maxFusedSpan;
    mutable int    maxFusedDepth;
  };
  
  

}
}
}
