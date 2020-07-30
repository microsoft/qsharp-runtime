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

#include <chrono>
namespace Microsoft
{
namespace Quantum
{
    extern int dbgFusedSpan;
    extern int dbgFusedLimit;
    extern int dbgNumThreads;
    extern int dbgReorder;

namespace SIMULATOR
{
class Fused
  {
    //@@@DBG: Everything in here is added for debugging
    mutable int dbgNfused;
    mutable int dbgSize;
    mutable int dbgNqs;
    mutable int dbgNcs;
    mutable int dbgNgates;
    mutable double dbgElapsed;
    mutable double dbgET1;
    mutable double dbgET2;
    mutable std::chrono::system_clock::time_point prev  = std::chrono::system_clock::now();

  public:
      Fused() {
        dbgNfused   = 0;
        dbgSize     = 0;
        dbgNqs      = 0;
        dbgNcs      = 0;
        dbgNgates   = 0;
        dbgElapsed  = 0.0;
        dbgET1      = 0.0;
        dbgET2      = 0.0;

        wfnCapacity     = 0u; //@@@DBG used to optimize parameters
        maxFusedSpan    =-1;
        maxFusedDepth   = 99;
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
      
      std::chrono::system_clock::time_point dbgT1 = std::chrono::system_clock::now();
      fusedgates.perform_fusion(m, qs, cs);
      std::chrono::system_clock::time_point dbgT2 = std::chrono::system_clock::now();
      std::chrono::duration<double> dbgE = dbgT2 - dbgT1;
      dbgET1 += dbgE.count();

      std::size_t cmask = 0;
      for (auto c : cs)
        cmask |= (1ull << c);
      
      dbgNfused++;
      dbgSize += fusedgates.size();
      dbgNqs += fusedgates.num_qubits();
      dbgNcs += fusedgates.num_controls();

      dbgT1 = std::chrono::system_clock::now();
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
        case 6:
            ::kernel(wfn, qs[5], qs[4], qs[3], qs[2], qs[1], qs[0], m, cmask);
            break;
        case 7:
            ::kernel(wfn, qs[6], qs[5], qs[4], qs[3], qs[2], qs[1], qs[0], m, cmask);
            break;
      }

      dbgT2 = std::chrono::system_clock::now();
      dbgE = dbgT2 - dbgT1;
      dbgET2 += dbgE.count();

      fusedgates = Fusion();

      std::chrono::system_clock::time_point curr = std::chrono::system_clock::now();
      std::chrono::duration<double> elapsed = curr - prev;
      dbgElapsed = elapsed.count();
      double timeInt = log((float)wfn.capacity()) / log(2.0);
      timeInt = (timeInt * timeInt) / 20.0;

      if (dbgElapsed >= 5) { 
            double nFused = (float)dbgNfused;
            printf("@@@DBG sz=%.2f nQs=%.2f nCs=%.2f flsh=%8.2g gts=%8.2g elap=%5.1f gps=%10.4g (fus=%5.1f%%, ker=%5.1f%%)\n",
                ((float)dbgSize / nFused),
                ((float)dbgNqs / nFused),
                ((float)dbgNcs / nFused),
                nFused,
                (float)dbgNgates,
                dbgElapsed,
                (float)dbgNgates / dbgElapsed,
                dbgET1 * 100.0 / dbgElapsed,
                dbgET2 * 100.0 / dbgElapsed);
          fflush(stdout);
          dbgET1    = 0.0;
          dbgET2    = 0.0;
          prev      = curr;
          dbgNgates = 0;
      }

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
        if (fusedgates.predict(qs, cs) > maxFusedSpan || fusedgates.size() >= maxFusedDepth)  flush(wfn);
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
