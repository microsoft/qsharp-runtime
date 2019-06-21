#include "config.hpp"
#include "util/alignedalloc.hpp"
#include <vector>


namespace Microsoft
{
  namespace Quantum
  {
    namespace SIMULATOR
    {
      
#ifndef USE_SINGLE_PRECISION
      using RealType = double;
#else
      using RealType = float;
#endif
      
      using ComplexType = std::complex<RealType>;
      
      using WavefunctionStorage = std::vector<ComplexType, AlignedAlloc<ComplexType,64>>;

    }
  }
}


