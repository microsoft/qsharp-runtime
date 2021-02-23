// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
#pragma once

#include <limits>
namespace Microsoft
{
namespace Quantum
{
    using OpId = int;
    using Time = int;
    using Duration = int;
    using LayerId = size_t;

    constexpr LayerId INVALID = std::numeric_limits<size_t>::max();
}
}