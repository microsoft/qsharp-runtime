// (C) 2018 ETH Zurich, ITP, Thomas Häner and Damian Steiger

#pragma once

#include "config.hpp"
#include "external/fusion.hpp"
#include "simulator/kernels.hpp"
#include <string>
#include <thread>

#include <time.h>

#include <chrono>
#include "cudaquantuminterfaces.h"

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
        wfnCapacity     = 0u;   // used to optimize runtime parameters
        maxFusedSpan    = 4;    // determine span to use at runtime
        maxFusedDepth   = 999;  // determine max depth to use at runtime
        kernelMs = 0;
    }
      uint64_t get_kernel_ms() const {
          return kernelMs;
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

    const int maxSpan() const {
        return maxFusedSpan;
    }

    const int maxDepth() const {
        return maxFusedDepth;
    }

    void flush_gpu(void* gpuContext) const
    {
      if (fusedgates.size() == 0)
        return;
      Fusion::Matrix m;
      Fusion::IndexVector qs, cs;

      fusedgates.perform_fusion(m, qs, cs);
      std::vector<int> controls(cs.size());
      for(size_t i = 0; i  < cs.size(); i++)
      {
        controls[i] = (int) cs[i];
      }
      std::vector<int> targets(qs.size());
      for(size_t i = 0; i  < qs.size(); i++)
      {
        targets[i] = (int) qs[i];
      }
      const size_t qbits = m.size();
      std::vector<std::complex<double>> mm(qbits* qbits);
      size_t m_index = 0;
      for (size_t i = 0; i < qbits; i++)
      {
        for (size_t j = 0; j < qbits; j++)
        {
          mm[i * qbits + j] = m[i][j];
        }
      }
      auto start = std::chrono::duration_cast<std::chrono::milliseconds>(
                   std::chrono::high_resolution_clock::now().time_since_epoch())
                   .count();

      apply_cuquantum_gate(gpuContext, reinterpret_cast<double*>(mm.data()), (int)controls.size(), (int)targets.size(), targets.data(), controls.data());
      auto end = std::chrono::duration_cast<std::chrono::milliseconds>(
                         std::chrono::high_resolution_clock::now().time_since_epoch())
                         .count();
      kernelMs += (end - start);
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
      auto start = std::chrono::duration_cast<std::chrono::milliseconds>(
                   std::chrono::high_resolution_clock::now().time_since_epoch())
                   .count();
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
      auto end = std::chrono::duration_cast<std::chrono::milliseconds>(
                         std::chrono::high_resolution_clock::now().time_since_epoch())
                         .count();
      kernelMs += (end - start);
      fusedgates = Fusion();
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
    
    template <class M>
    void apply_controlled(M const& mat, std::vector<unsigned> const& cs, unsigned q) const
    {
        Fusion::IndexVector qs = std::vector<unsigned>(1, q);
        fusedgates.insert(convertMatrix(mat), qs, cs);
    }

    template <class M>
    void apply(M const& mat, unsigned q) const
    {
      std::vector<unsigned> cs;
      apply_controlled(mat, cs, q);
    }


    bool shouldFlush(size_t wfn_capacity, std::vector<unsigned> const& cs, unsigned q)
    {
        // Major runtime logic change here

          // Have to update capacity as the WFN grows
        if (wfnCapacity != wfn_capacity) {
            wfnCapacity = wfn_capacity;
            char* envNT = NULL;
            size_t len;
#ifdef _OPENMP
#ifdef _MSC_VER
            errno_t err = _dupenv_s(&envNT, &len, "OMP_NUM_THREADS");
#else
            envNT = getenv("OMP_NUM_THREADS");
#endif
            if (envNT == NULL) { // If the user didn't force the number of threads, make an intelligent guess
                int nMaxThrds = std::thread::hardware_concurrency();        // Logical HW threads
                if (nMaxThrds > 4) nMaxThrds/= 2;                           // Assume we have hyperthreading (no consistent/concise way to do this)
                if (wfnCapacity < 1ul << 14)      nMaxThrds = 1;
                else if (wfnCapacity < 1ul << 16) nMaxThrds = 2;
                else if (wfnCapacity < 1ul << 20)
                {
                    if (nMaxThrds > 8) nMaxThrds = 8;                       // Small problem, never use too many
                    else if (nMaxThrds > 3) nMaxThrds = 3;                  // Small problem on a small machine
                }
                omp_set_num_threads(nMaxThrds);
            }
#endif

            // Set the max fused depth
            char* envFD = NULL;
            maxFusedDepth = 999;
#ifdef _MSC_VER
            err = _dupenv_s(&envFD, &len, "QDK_SIM_FUSEDEPTH");
            if (envFD != NULL && len > 0) {
                maxFusedDepth = atoi(envFD);
        }
#else
            envFD = getenv("QDK_SIM_FUSEDEPTH");
            if (envFD != NULL && strlen(envFD) > 0) {
                maxFusedDepth = atoi(envFD);
            }
#endif
            // Set the fused span limit
            char* envFS = NULL;
            maxFusedSpan = 4;                               // General sweet spot
            if (wfnCapacity < 1u << 20) maxFusedSpan = 2;   // Don't pre-fuse small problems
#ifdef _MSC_VER
            err = _dupenv_s(&envFS, &len, "QDK_SIM_FUSESPAN");
            if (envFS != NULL && len > 0) {
                maxFusedSpan = atoi(envFS);
                if (maxFusedSpan > 7) maxFusedSpan = 7;     // Highest we can handle
        }
#else
            envFS = getenv("QDK_SIM_FUSESPAN");
            if (envFS != NULL && strlen(envFS) > 0) {
                maxFusedSpan = atoi(envFS);
            }
#endif

        }
        return false;
    }

  private:
    mutable Fusion fusedgates;

    //: New runtime optimizatin settings
    mutable size_t wfnCapacity;
    mutable int    maxFusedSpan;
    mutable int    maxFusedDepth;

    mutable uint64_t kernelMs;
  };
  
  

}
}
}
