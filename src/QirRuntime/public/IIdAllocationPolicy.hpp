#pragma once

namespace quantum
{
    /*=================================================================================
        The Id Allocation Policy assignes and keeps track of ids that can be used by
        IQuantumApi implementers to manage logical qubits.
    =================================================================================*/
    struct IIdAllocationPolicy
    {
        virtual ~IIdAllocationPolicy() {}
        virtual long AcquireId() = 0;
        virtual void ReleaseId(long id) = 0;
    };
} // namespace quantum