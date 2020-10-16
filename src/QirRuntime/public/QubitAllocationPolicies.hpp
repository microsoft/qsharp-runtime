#pragma once

#include <stack>

#include "BitStates.hpp"
#include "IIdAllocationPolicy.hpp"

using namespace std;
namespace Microsoft
{
namespace Quantum
{
    /*==============================================================================
        The default qubit manager reuses released qubit ids in "Last released -
        first reused" order.
    ==============================================================================*/
    class CReuseLastReleasedQubitAllocationPolicy : public IIdAllocationPolicy
    {
        long lastUsedId = -1;

        // 'used' state is the ground truth about whether the id is used, but we also
        // keep track of released ids in a stack to make reuse of a released id faster.
        BitStates used;
        std::stack<long> released;

      public:
        long AcquireId() override;
        void ReleaseId(long id) override;
    };

    /*==============================================================================
        No reuse of qubits is simple and can be implemented inline by most simulators
        (and, probably, should be for performance reasons). However, for those that
        need to vary the allocation policy, this class provides the option.
    ==============================================================================*/
    class CNoQubitReuseAllocationPolicy : public IIdAllocationPolicy
    {
        long lastUsedId = -1;

      public:
        long AcquireId() override
        {
            return ++this->lastUsedId;
        }
        void ReleaseId(long id) override{};
    };
} // namespace Quantum
} // namespace Microsoft