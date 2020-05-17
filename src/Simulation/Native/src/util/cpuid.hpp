// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include "config.hpp"
#include <iostream>
#ifdef _MSC_VER
#include <intrin.h>
#endif


namespace Microsoft
{
  namespace Quantum
  {
    inline bool haveAVX()
    {
      try
      {
#ifndef _MSC_VER
        return __builtin_cpu_supports("avx");
#else
        int cpuInfo[4];
        __cpuid(cpuInfo,0);
        if (cpuInfo[0]<1)
          return false;
        __cpuid(cpuInfo, 1);
        return cpuInfo[2]&(1u<<28);
#endif
      }
      catch (const std::exception&)
      {
        return false;
      }
    }
  
    inline bool haveAVX512()
    {
      try
      {
#ifndef _MSC_VER
        //__builtin_cpu_init();
        return false; // __builtin_cpu_supports("avx512bw");
#else
        int cpuInfo[4];
        __cpuid(cpuInfo,0);
        if (cpuInfo[0]<7)
          return false;
        __cpuid(cpuInfo, 7);
        return cpuInfo[1]&(1u<<16);
#endif
      }
      catch (const std::exception&)
      {
        return false;
      }
    }

    inline bool haveAVX2()
    {
      try
      {
#ifndef _MSC_VER
        //__builtin_cpu_init();
        return __builtin_cpu_supports("avx2");
#else
        int cpuInfo[4];
        __cpuid(cpuInfo,0);
        if (cpuInfo[0]<7)
          return false;
        __cpuid(cpuInfo, 7);
        return cpuInfo[1]&(1u<<5);
#endif
      }
      catch (const std::exception&)
      {
        return false;
      }
    }

    inline bool haveFMA()
    {
      try
      {
#ifndef _MSC_VER
        //__builtin_cpu_init();
        return __builtin_cpu_supports("avx2");
#else
        int cpuInfo[4];
        __cpuid(cpuInfo,0);
        if (cpuInfo[0]<1)
          return false;
        __cpuid(cpuInfo, 1);
        return cpuInfo[2]&(1u<<12);
#endif
      }
      catch (const std::exception&)
      {
        return false;
      }
    }
  }
}


