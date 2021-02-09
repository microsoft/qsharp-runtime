// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include <cmath>
#include <random>
#include <stdexcept>
#include "quantum__qis.hpp"
#include "quantum__qis_internal.hpp"

extern "C"
{

char const excStrDrawRandomInt[] = "Invalid Argument: minimum > maximum for DrawRandomInt()";

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

double quantum__qis__arctan2__body(double y, double x)
{
    return std::atan2(y, x);        // https://en.cppreference.com/w/cpp/numeric/math/atan2
}

int64_t quantum__qis__drawrandomint__body(int64_t minimum, int64_t maximum)
{
    if(minimum > maximum)
    {
        throw std::invalid_argument( excStrDrawRandomInt );
    }

    // https://en.cppreference.com/w/cpp/numeric/random/uniform_int_distribution
    // https://en.cppreference.com/w/cpp/numeric/random
    thread_local static std::random_device rd;
    thread_local static std::mt19937_64 gen(rd());

    return std::uniform_int_distribution<int64_t>(minimum, maximum)(gen);
}

}   // extern "C"
