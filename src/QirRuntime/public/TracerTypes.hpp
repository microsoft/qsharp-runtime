// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
#pragma once

#include <limits>
#include "CoreTypes.hpp"

namespace Microsoft
{
namespace Quantum
{
    using OpId = int;
    using Time = int;
    using Duration = int;
    using LayerId = int64_t;

    constexpr QIR_SHARED_API LayerId INVALID = std::numeric_limits<LayerId>::min();
    constexpr QIR_SHARED_API LayerId REQUESTNEW = std::numeric_limits<LayerId>::max();
}
}