// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#pragma once

#include <unordered_map>

#include "CoreTypes.hpp"

namespace Microsoft
{
namespace Quantum
{
    // The tracker keeps a list of pointers to all qir objects that have been allocated during the lifetime of an
    // execution context and their reference counts, which allows us to check for double-releases and leaks when the
    // actual objects have been released.
    struct QIR_SHARED_API AllocationsTracker
    {
        std::unordered_map<void*, int> allocatedObjects;

        void OnAllocate(void* object);
        void OnAddRef(void* object);
        void OnRelease(void* object);

        void CheckForLeaks() const;
    };

} // namespace Quantum
} // namespace Microsoft