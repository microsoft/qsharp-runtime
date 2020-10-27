// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

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

using WavefunctionStorage = std::vector<ComplexType, AlignedAlloc<ComplexType, 64>>;

} // namespace SIMULATOR
} // namespace Quantum
} // namespace Microsoft
