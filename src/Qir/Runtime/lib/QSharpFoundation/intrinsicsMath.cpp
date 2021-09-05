// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include <cmath>
#include <random>
#include <stdexcept>
#include "qsharp__foundation__qis.hpp"
#include "qsharp__foundation_internal.hpp"
#include "QirRuntime.hpp"

// Forward declarations:
namespace // Visible in this translation unit only.
{
extern thread_local bool randomizeSeed;
extern int64_t lastGeneratedRndI64;
extern double lastGeneratedRndDouble;
} // namespace

// Implementation:
extern "C"
{

    // Implementations:
    bool __quantum__qis__isnan__body(double d)
    {
        return std::isnan(d); // https://en.cppreference.com/w/cpp/numeric/math/isnan
    }

    double __quantum__qis__infinity__body()
    {
        return (double)INFINITY; // https://en.cppreference.com/w/c/numeric/math/INFINITY
    }

    bool __quantum__qis__isinf__body(double d)
    {
        return std::isinf(d); // https://en.cppreference.com/w/cpp/numeric/math/isinf
    }

    double __quantum__qis__arctan2__body(double y, double x)
    {
        return std::atan2(y, x); // https://en.cppreference.com/w/cpp/numeric/math/atan2
    }

    double __quantum__qis__sinh__body(double theta)
    {
        return std::sinh(theta);
    }

    double __quantum__qis__cosh__body(double theta)
    {
        return std::cosh(theta);
    }

    double __quantum__qis__arcsin__body(double theta)
    {
        return std::asin(theta); // https://en.cppreference.com/w/cpp/numeric/math/asin
    }

    double __quantum__qis__arccos__body(double theta)
    {
        return std::acos(theta); // https://en.cppreference.com/w/cpp/numeric/math/acos
    }

    double __quantum__qis__arctan__body(double theta)
    {
        return std::atan(theta); // https://en.cppreference.com/w/cpp/numeric/math/atan
    }

    double __quantum__qis__ieeeremainder__body(double x, double y)
    {
        return std::remainder(x, y); // https://en.cppreference.com/w/cpp/numeric/math/remainder
    }

    int64_t __quantum__qis__drawrandomint__body(int64_t minimum, int64_t maximum)
    {
        if (minimum > maximum)
        {
            __quantum__rt__fail_cstr(Quantum::Qis::Internal::excStrDrawRandomVal);
        }

        // https://en.cppreference.com/w/cpp/numeric/random/uniform_int_distribution
        // https://en.cppreference.com/w/cpp/numeric/random
        thread_local static std::mt19937_64 gen(randomizeSeed ? std::random_device()() : // Default
                                                    0);                                  // For test purposes only.

        lastGeneratedRndI64 = std::uniform_int_distribution<int64_t>(minimum, maximum)(gen);
        return lastGeneratedRndI64;
    }

    double __quantum__qis__drawrandomdouble__body(double minimum, double maximum)
    {
        if (minimum > maximum)
        {
            __quantum__rt__fail_cstr(Quantum::Qis::Internal::excStrDrawRandomVal);
        }

        // For testing purposes we need separate generators for Int and Double:
        // https://en.cppreference.com/w/cpp/numeric/random/uniform_int_distribution
        // https://en.cppreference.com/w/cpp/numeric/random
        thread_local static std::mt19937_64 gen(randomizeSeed ? std::random_device()() : // Default
                                                    0);                                  // For test purposes only.

        // https://en.cppreference.com/w/cpp/numeric/random/uniform_real_distribution
        lastGeneratedRndDouble = std::uniform_real_distribution<double>(
            minimum, std::nextafter(maximum, std::numeric_limits<double>::max())) // "Notes" section.
            (gen);
        return lastGeneratedRndDouble;
    }

} // extern "C"

namespace // Visible in this translation unit only.
{
thread_local bool randomizeSeed = true;
int64_t lastGeneratedRndI64     = 0;
double lastGeneratedRndDouble   = 0.0;
} // namespace

// For test purposes only:
namespace Quantum
{
namespace Qis
{
    namespace Internal
    {
        char const excStrDrawRandomVal[] = "Invalid Argument: minimum > maximum";

        void RandomizeSeed(bool randomize)
        {
            randomizeSeed = randomize;
        }

        int64_t GetLastGeneratedRandomI64()
        {
            return lastGeneratedRndI64;
        }

        double GetLastGeneratedRandomDouble()
        {
            return lastGeneratedRndDouble;
        }

    } // namespace Internal
} // namespace Qis
} // namespace Quantum
