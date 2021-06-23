// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include <cstdint>
#include "QirTypes.hpp"

QirRange::QirRange()
    : start(0)
    , step(0)
    , end(0)
{
}

QirRange::QirRange(int64_t st, int64_t sp, int64_t en)
    : start(st)
    , step(sp)
    , end(en)
{
}
