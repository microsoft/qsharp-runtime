#ifndef FLOATUTILS_HPP
#define FLOATUTILS_HPP

#include <type_traits>

// Comparing floating point values with `==` or `!=` is not reliable. 
// The values can be extremely close but still not exactly equal.
// It is more reliable to check if one value is within certain small tolerance near the other value.
// This template function is for comparing two floating point values.
template<typename TFloat>
inline bool Close(TFloat val1, TFloat val2)
{
    assert(std::is_floating_point_v< std::remove_reference_t<TFloat> > && "Unexpected type is passed as a template argument");

    constexpr TFloat tolerance = 1e-10;

    // Both val1 and val2 can be close (or equal) to the maximum (or minimum) value representable with its type.
    // Adding to (or subtracting from) such a value can cause overflow (or underflow).
    // To avoid the overflow (or underflow) we don't add to the greater value (and don't sutract from a lesser value).
    if(val1 < val2)
    {
        return (val2 - val1) <= tolerance;
    }
    return (val1 - val2) <= tolerance;
}

#endif // #ifndef FLOATUTILS_HPP
