// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#pragma once

#include <cstddef>
#include <memory>
#include <new>

#ifdef _WIN32
#include <malloc.h>
#else
#include <cstdlib>
#endif

#include "SafeInt.hpp"

namespace Microsoft
{
namespace Quantum
{
namespace SIMULATOR
{

/// a C++11 allocator for aligned memory

template <typename T, unsigned Align = 64>
class AlignedAlloc
{
  public:
    using pointer = T*;
    using const_pointer = T const*;
    using reference = T&;
    using const_reference = T const&;
    using value_type = T;
    using size_type = std::size_t;
    using difference_type = std::ptrdiff_t;

    template <typename U>
    struct rebind
    {
        using other = AlignedAlloc<U, Align>;
    };

    AlignedAlloc() noexcept
    {
    }

    AlignedAlloc(AlignedAlloc const&) noexcept
    {
    }

    template <typename U>
    AlignedAlloc(AlignedAlloc<U, Align> const&) noexcept
    {
    }

    pointer allocate(size_type n)
    {
        pointer ptr;
        SafeInt<size_type> sz (n);
        sz *= sizeof(T);
#ifdef _WIN32
        ptr = reinterpret_cast<pointer>(_aligned_malloc(sz, Align));
        if (ptr == 0)
            throw std::bad_alloc();
#else
        if (posix_memalign(reinterpret_cast<void**>(&ptr), Align, sz))
            throw std::bad_alloc();
#endif
        return ptr;
    }

    void deallocate(pointer ptr, size_type) noexcept
    {
#ifdef _WIN32
        _aligned_free(ptr);
#else
        std::free(ptr);
#endif
    }

    size_type max_size() const noexcept
    {
        std::allocator<T> a;
        return a.max_size();
    }

    template <typename C, class... Args>
    void construct(C* c, Args&&... args)
    {
        new ((void*)c) C(std::forward<Args>(args)...);
    }

    template <typename C>
    void destroy(C* c)
    {
        c->~C();
    }

    bool operator==(AlignedAlloc const&) const noexcept
    {
        return true;
    }
    bool operator!=(AlignedAlloc const&) const noexcept
    {
        return false;
    }
    template <typename U, unsigned UAlign>
    bool operator==(AlignedAlloc<U, UAlign> const&) const noexcept
    {
        return false;
    }
    template <typename U, unsigned UAlign>
    bool operator!=(AlignedAlloc<U, UAlign> const&) const noexcept
    {
        return true;
    }
};

}
}
}