// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include <cmath>
#include "quantum__qis.hpp"

extern "C"
{

// Implementations:
bool quantum__qis__isnan__body(double d)
{
    return std::isnan(d);           // https://en.cppreference.com/w/cpp/numeric/math/isnan
}

double quantum__qis__infinity__body()
{
    return INFINITY;                // https://en.cppreference.com/w/c/numeric/math/INFINITY
}

bool quantum__qis__isinf__body(double d)
{
    return std::isinf(d);           // https://en.cppreference.com/w/cpp/numeric/math/isinf
}

}   // extern "C"
