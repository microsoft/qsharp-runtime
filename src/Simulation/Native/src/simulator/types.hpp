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

// The positional id is an implementation details of the wave function store and shouldn't be used outside of it.
// The `using` declarations document the intent of the code but provide no compile-time safety. Consider replacing those
// with single member structs with, maybe, implicit conversion to unsigned, but no direct conversion between logical and
// positional qubit ids (having the type might be too cumbersome with arrays, though).

/// Logical qubit id is visible to the clients and is immutable during the lifetime of the qubit.
using logical_qubit_id = unsigned;

/// Positional qubit id describes the order of the qubit in the standard computational basis used by the wave function.
/// It might change as the qubits are allocated/released or reodered.
using positional_qubit_id = unsigned;

} // namespace SIMULATOR
} // namespace Quantum
} // namespace Microsoft
