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

#ifdef DBWDBG // Used for reporting timings
#include <chrono>
#endif

namespace Microsoft
{
namespace Quantum
{
#ifdef DBWDBG // Debugging switches used by top level apps
    extern int dbgFusedSpan;
    extern int dbgFusedLimit;
    extern int dbgNumThreads;
    extern int dbgReorder;
#endif

namespace SIMULATOR
{

class Fused
  {
#ifdef DBWDBG // Debugging statistics reported out
    mutable int dbgNfused;
    mutable int dbgSize;
    mutable int dbgNqs;
    mutable int dbgNcs;
    mutable int dbgNgates;
    mutable double dbgElapsed;
    mutable double dbgET1;
    mutable double dbgET2;
    mutable std::chrono::system_clock::time_point prev  = std::chrono::system_clock::now();
#endif

  public:
      Fused() {
#ifdef DBWDBG // Init stats
        dbgNfused   = 0;
        dbgSize     = 0;
        dbgNqs      = 0;
        dbgNcs      = 0;
        dbgNgates   = 0;
        dbgElapsed  = 0.0;
        dbgET1      = 0.0;
        dbgET2      = 0.0;
#endif

        wfnCapacity     = 0u; // used to optimize runtime parameters
        maxFusedSpan    = 6;  // determine span to use at runtime
        maxFusedDepth   = 99; // determine max depth to use at runtime
    }

    inline void reset()
    {
      fusedgates = Fusion();
    }

    const Fusion& get_fusedgates() const {
        return fusedgates;
    }
    
    void set_fusedgates(Fusion newFusedGates) const {
        fusedgates = newFusedGates;
    }

    template <class T, class A>
    void flush(std::vector<T, A>& wfn) const
    {
      if (fusedgates.size() == 0)
        return;
      
      Fusion::Matrix m;
      Fusion::IndexVector qs, cs;

#ifdef DBWDBG // Timing
      std::chrono::system_clock::time_point dbgT1 = std::chrono::system_clock::now();
#endif

      fusedgates.perform_fusion(m, qs, cs);

#ifdef DBWDBG // Timing
      std::chrono::system_clock::time_point dbgT2 = std::chrono::system_clock::now();
      std::chrono::duration<double> dbgE = dbgT2 - dbgT1;
      dbgET1 += dbgE.count();
#endif

      std::size_t cmask = 0;
      for (auto c : cs)
        cmask |= (1ull << c);
      
#ifdef DBWDBG // Gather stats
      dbgNfused++;
      dbgSize += fusedgates.size();
      dbgNqs += fusedgates.num_qubits();
      dbgNcs += fusedgates.num_controls();
      dbgT1 = std::chrono::system_clock::now();
#endif

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

#ifdef DBWDBG // More timing stats
      dbgT2 = std::chrono::system_clock::now();
      dbgE = dbgT2 - dbgT1;
      dbgET2 += dbgE.count();
#endif

      fusedgates = Fusion();

#ifdef DBWDBG // Report out periodically
      std::chrono::system_clock::time_point curr = std::chrono::system_clock::now();
      std::chrono::duration<double> elapsed = curr - prev;
      dbgElapsed = elapsed.count();
      double timeInt = log((float)wfn.capacity()) / log(2.0);
      timeInt = (timeInt * timeInt) / 20.0;

      if (dbgElapsed >= timeInt) { 
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
#endif

    }
    
    template <class M>
    Fusion::Matrix convertMatrix(M const& m) const
    {
      Fusion::Matrix mat(2, Fusion::Matrix::value_type(2));
      for (unsigned i = 0; i < 2; ++i)
        for (unsigned j = 0; j < 2; ++j)
          mat[i][j] = static_cast<ComplexType>(m(i, j));
      return mat;
    }
    
    template <class T, class A, class M>
    void apply_controlled(std::vector<T, A>& wfn, M const& mat, std::vector<unsigned> const& cs, unsigned q) const
    {
#ifdef DBWDBG // Gather gate count stats
        dbgNgates++;
#endif
        Fusion::IndexVector qs = std::vector<unsigned>(1, q);
        fusedgates.insert(convertMatrix(mat), qs, cs);
    }

    template <class T, class A, class M>
    void apply(std::vector<T, A>& wfn, M const& mat, unsigned q) const
    {
      std::vector<unsigned> cs;
      apply_controlled(wfn, mat, cs, q);
    }

    template <class T, class A>
    bool shouldFlush(std::vector<T, A>& wfn, std::vector<unsigned> const& cs, unsigned q)
    {
        // Major runtime logic change here

          // Have to update capacity as the WFN grows
        if (wfnCapacity != wfn.capacity()) {
            wfnCapacity = wfn.capacity();
            char* envNT = NULL;
            size_t len;
#ifdef _MSC_VER
            errno_t err = _dupenv_s(&envNT, &len, "OMP_NUM_THREADS");
#else
            envNT = getenv("OMP_NUM_THREADS");
#endif
            if (envNT == NULL) { // If the user didn't force the number of threads, make an intelligent guess
                int nMaxThrds   = 6;    // Default for big problems
                int nProcs = omp_get_num_procs();
                if (nProcs < nMaxThrds) nMaxThrds = nProcs;
                
#ifdef DBWDBG // Force number of threads
                if (dbgNumThreads > 0) nMaxThrds = dbgNumThreads; //allow for debugging from above
#endif
                omp_set_num_threads(nMaxThrds);
            }

            // Set the max fused depth
            char* envFD = NULL;
#ifdef _MSC_VER
            err = _dupenv_s(&envFD, &len, "QDK_SIM_FUSEDEPTH");
#else
            envFD = getenv("QDK_SIM_FUSEDEPTH");
#endif
            maxFusedDepth = 99;
            if (envFD != NULL && len > 0) {
                maxFusedDepth = atoi(envFD);
            }

            // Set the fused span limit
            char* envFS = NULL;
#ifdef _MSC_VER
            err = _dupenv_s(&envFS, &len, "QDK_SIM_FUSESPAN");
#else
            envFS = getenv("QDK_SIM_FUSESPAN");
#endif
            maxFusedSpan = 4;
            if (envFS != NULL && len > 0) {
                maxFusedSpan = atoi(envFS);
            }

#ifdef DBWDBG // Set fusion depth and span limits
            maxFusedDepth = dbgFusedLimit;
            maxFusedSpan = dbgFusedSpan;
            printf("@@@DBG: OMP_NUM_THREADS=%d fusedSpan=%d fusedDepth=%d wfnCapacity=%u\n", omp_get_max_threads(), maxFusedSpan, maxFusedDepth, (unsigned)wfnCapacity);
#endif
        }

#ifdef DBWDBG // Only really predict if we're in debugging mode
        Fusion::IndexVector qs = std::vector<unsigned>(1, q);
        return (fusedgates.predict(qs, cs) > maxFusedSpan || fusedgates.size() >= (unsigned)maxFusedDepth);
#else
        return false;
#endif
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
