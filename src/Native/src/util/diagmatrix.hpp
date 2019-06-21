// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#pragma once

#include <cassert>
#include <initializer_list>

namespace Microsoft
{
namespace Quantum
{
namespace SIMULATOR
{

/// A tiny diagonal matrix with compile time fixed dimensions

template <class T, unsigned N>
class DiagMatrix
{
  public:
    using value_type = T;
    using pointer = value_type*;
    using const_pointer = value_type const*;
    using reference = value_type&;
    using const_reference = value_type const&;
    using size_type = unsigned;

    DiagMatrix()
    {
    }

    DiagMatrix(DiagMatrix const&) = default;
    DiagMatrix& operator=(DiagMatrix const&) = default;

    /// initialize from a C-array
    template <class U>
    DiagMatrix(U const (&ini)[N])
    {
        for (unsigned i = 0; i < N; i++)
            diag_[i] = static_cast<T>(ini[i]);
    }

    /// initialize from an initializer list
    template <class U>
    DiagMatrix(std::initializer_list<U> const& ini)
    {
        int i = 0;
        for (auto const& x : ini)
            diag_[i++] = x;
    }

    /// copy-construct from a matrix with different type
    template <class U>
    DiagMatrix(DiagMatrix<U, N> const& rhs)
    {
        for (unsigned i = 0; i < this->rows(); ++i)
            diag_[i] = rhs(i, i);
    }

    /// assign from a matrix with a different type
    template <class U>
    DiagMatrix& operator=(DiagMatrix<U, N> const& rhs)
    {
        for (size_type i = 0; i < this->rows(); ++i)
            diag_[i] = rhs(i, i);
        return *this;
    }

    constexpr size_type rows() const
    {
        return N;
    }
    constexpr size_type cols() const
    {
        return N;
    }
    constexpr size_type size() const
    {
        return rows() * cols();
    }

    /// access an element
    /// \pre i<rows() && j<cols()
    value_type operator()(unsigned i, unsigned j) const
    {
        assert(i < this->rows() && j < this->cols());
        return i == j ? diag_[i] : static_cast<value_type>(0.);
    }

    /// access an element
    /// \pre i<rows() && j<cols()
    reference operator()(unsigned i, unsigned j)
    {
        assert(i < this->rows() && j < this->cols());
        assert(i == j);
        return diag_[i];
    }

    /// return a pointer to the first element of the matrix
    const_pointer data() const
    {
        return &diag_[0];
    }

    /// compare matrices for equality
    template <class U>
    bool operator==(DiagMatrix<U, N> const& rhs) const
    {
        for (unsigned i = 0; i < this->rows(); ++i)
            if (diag_[i] != rhs(i, i))
                return false;
        return true;
    }

    /// compare two matrices for inequality
    template <class U>
    bool operator!=(DiagMatrix<U, N> const& rhs) const
    {
        return !(*this == rhs);
    }

  private:
    value_type diag_[N];
};
}
}
}
