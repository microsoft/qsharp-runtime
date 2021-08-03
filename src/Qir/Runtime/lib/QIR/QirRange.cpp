// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include <cstdint>
#include "QirTypes.hpp"
#include "QirRuntime.hpp"

QirRange::QirRange(int64_t st, int64_t sp, int64_t en)
    : start(st)
    , step(sp)
    , end(en)
{
    // An attempt to create a %Range with a zero step should cause a runtime failure.
    // https://github.com/microsoft/qsharp-language/blob/main/Specifications/QIR/Data-Types.md#simple-types
    if(sp == 0)
    {
        quantum__rt__fail_cstr("Attempt to create a range with 0 step");
    }
}
