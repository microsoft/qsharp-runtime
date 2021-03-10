#pragma once

#include <memory>
#include <vector>

#include "QuantumApi_I.hpp"

namespace Microsoft
{
namespace Quantum
{
    // Toffoli Simulator
    QIR_SHARED_API std::unique_ptr<ISimulator> CreateToffoliSimulator();

    // Full State Simulator
    QIR_SHARED_API std::unique_ptr<ISimulator> CreateFullstateSimulator();

    QIR_SHARED_API std::ostream& SetOutputStream(std::ostream& newOStream);
} // namespace Quantum
} // namespace Microsoft