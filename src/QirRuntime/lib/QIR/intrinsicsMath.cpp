// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include <cmath>

extern "C"
{

// Declarations:
bool        quantum__qis__isnan__body(double d);
double      quantum__qis__inf__body();
bool        quantum__qis__isinf__body(double d);

// Implementations:
bool quantum__qis__isnan__body(double d)
{
    return isnan(d);                // https://en.cppreference.com/w/cpp/numeric/math/isnan
}

double quantum__qis__infinity__body()
{
    return INFINITY;                // https://en.cppreference.com/w/c/numeric/math/INFINITY
}

bool quantum__qis__isinf__body(double d)
{
    return isinf(d);                // https://en.cppreference.com/w/cpp/numeric/math/isinf
}

}   // extern "C"
