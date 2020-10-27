// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#pragma once

#include <cassert>
#include <initializer_list>

#include "diagmatrix.hpp"

namespace Microsoft
{
namespace Quantum
{
namespace SIMULATOR
{

/// A tiny matrix with compile time fixed dimensions

template <class T, unsigned M, unsigned N = M>
class TinyMatrix
{
  public:
    using value_type = T;
    using pointer = value_type*;
    using const_pointer = value_type const*;
    using reference = value_type&;
    using const_reference = value_type const&;
    using size_type = unsigned;

    TinyMatrix() {}

    TinyMatrix(TinyMatrix const&) = default;
    TinyMatrix& operator=(TinyMatrix const&) = default;

    /// initialize from a C-array
    template <class U>
    TinyMatrix(U const (&ini)[M][N])
    {
        for (unsigned i = 0; i < this->rows(); i++)
            for (unsigned j = 0; j < this->cols(); j++)
                mat_[i][j] = static_cast<T>(ini[i][j]);
    }

    /// initialize from an initializer list
    template <class U>
    TinyMatrix(std::initializer_list<std::initializer_list<U>> const& ini)
    {
        int i = 0;
        for (auto const& row : ini)
        {
            int j = 0;
            for (auto const& x : row)
                mat_[i][j++] = x;
            i++;
        }
    }

    /// copy-construct from a matrix with different type
    template <class U>
    TinyMatrix(TinyMatrix<U, M, N> const& rhs)
    {
        for (unsigned i = 0; i < this->rows(); ++i)
            for (unsigned j = 0; j < this->cols(); ++j)
                mat_[i][j] = rhs(i, j);
    }

    /// copy-construct from a diagonal matrix
    template <class U>
    TinyMatrix(DiagMatrix<U, N> const& rhs)
    {
        for (unsigned i = 0; i < this->rows(); ++i)
            for (unsigned j = 0; j < this->cols(); ++j)
                mat_[i][j] = (i == j ? static_cast<T>(rhs(i, j)) : T());
    }

    /// assign from a matrix with a different type
    template <class U>
    TinyMatrix& operator=(DiagMatrix<U, N> const& rhs)
    {
        for (size_type i = 0; i < this->rows(); ++i)
            for (size_type j = 0; j < this->cols(); ++j)
                mat_[i][j] = (i == j ? static_cast<T>(rhs(i, j)) : T());
        return *this;
    }

    constexpr size_type rows() const
    {
        return M;
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
        return mat_[i][j];
    }

    /// access an element
    /// \pre i<rows() && j<cols()
    reference operator()(unsigned i, unsigned j)
    {
        assert(i < this->rows() && j < this->cols());
        return mat_[i][j];
    }

    /// return a pointer to the first element of the matrix
    const_pointer data() const
    {
        return &mat_[0][0];
    }

    /// compare matrices for equality
    template <class U>
    bool operator==(TinyMatrix<U, M, N> const& rhs) const
    {
        for (unsigned i = 0; i < this->rows(); ++i)
            for (unsigned j = 0; j < this->cols(); ++j)
                if (mat_[i][j] != rhs(i, j)) return false;
        return true;
    }

    /// compare two matrices for inequality
    template <class U>
    bool operator!=(TinyMatrix<U, M, N> const& rhs) const
    {
        return !(*this == rhs);
    }

  private:
    value_type mat_[M][N];
};
} // namespace SIMULATOR
} // namespace Quantum
} // namespace Microsoft
