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
    using LayerId = int64_t;    // TODO: Use unsigned type.

    constexpr LayerId INVALID = std::numeric_limits<LayerId>::min();
    constexpr LayerId REQUESTNEW = std::numeric_limits<LayerId>::max();
}
}
