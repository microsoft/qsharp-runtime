// Copyright © 2017 Microsoft Corporation. All Rights Reserved.

#pragma once

#include <cmath>
#include <complex>
#include <string>

#include "types.hpp"
#include "util/tinymatrix.hpp"

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

namespace Microsoft
{
namespace Quantum
{
namespace SIMULATOR
{
namespace Gates
{

/// a type for runtime basis specification
enum Basis
{
    PauliI,
    PauliX,
    PauliY,
    PauliZ
};

/// a general one qubit gate, storing the qubit number
class OneQubitGate
{
  public:
    OneQubitGate(unsigned q) : qubit_(q)
    {
    }
    unsigned qubit() const
    {
        return qubit_;
    }

  private:
    unsigned qubit_;
};

/// a general one qubit roitation gate, storing the qubit number and angle
class RotationGate : public OneQubitGate
{
  public:
    RotationGate(double phi, unsigned q) : OneQubitGate(q), angle_(phi)
    {
    }
    double angle() const
    {
        return angle_;
    }

  private:
    double angle_;
};

/// The Pauli X gate
class X : public OneQubitGate
{
  public:
    X(unsigned q) : OneQubitGate(q)
    {
    }

    std::string name() const
    {
        return "X";
    }

    TinyMatrix<RealType, 2> matrix() const
    {
        RealType mat[2][2] = {{0., 1.}, {1., 0.}};
        return TinyMatrix<RealType, 2>(mat);
    }
};

/// The Pauli Y gate
class Y : public OneQubitGate
{
  public:
    Y(unsigned q) : OneQubitGate(q)
    {
    }

    std::string name() const
    {
        return "Y";
    }

    TinyMatrix<ComplexType, 2> matrix() const
    {
        using val_t = ComplexType;
        val_t mat[2][2] = {{val_t(0.), val_t(0.)}, {val_t(0.), val_t(0.)}};
        mat[0][1] = val_t(0., -1.);
        mat[1][0] = val_t(0., 1.);
        return TinyMatrix<val_t, 2>(mat);
    }
};

/// The Pauli Z gate
class Z : public OneQubitGate
{
  public:
    Z(unsigned q) : OneQubitGate(q)
    {
    }

    std::string name() const
    {
        return "Z";
    }

    DiagMatrix<RealType, 2> matrix() const
    {
        RealType diag[2] = {1., -1.};
        return DiagMatrix<RealType, 2>(diag);
    }
};

/// The Hadamard gate
class H : public OneQubitGate
{
  public:
    H(unsigned q) : OneQubitGate(q)
    {
    }

    std::string name() const
    {
        return "H";
    }

    TinyMatrix<RealType, 2> matrix() const
    {
        RealType r = std::sqrt(0.5);
        RealType mat[2][2] = {{r, r}, {r, -r}};
        return TinyMatrix<RealType, 2, 2>(mat);
    }
};

/// The Y-version of a Hadamard gate
class HY : public OneQubitGate
{
  public:
    HY(unsigned q) : OneQubitGate(q)
    {
    }

    std::string name() const
    {
        return "HY";
    }

    TinyMatrix<ComplexType, 2> matrix() const
    {
        ComplexType r(std::sqrt(0.5), 0.);
        ComplexType i(0., std::sqrt(0.5));
        ComplexType mat[2][2] = {{r, r}, {i, -i}};
        return TinyMatrix<ComplexType, 2>(mat);
    }
};

/// The adjoint Y-version of a Hadamard gate
class AdjHY : public OneQubitGate
{
  public:
    AdjHY(unsigned q) : OneQubitGate(q)
    {
    }

    std::string name() const
    {
        return "AdjHY";
    }

    TinyMatrix<ComplexType, 2> matrix() const
    {
        ComplexType r(std::sqrt(0.5), 0.);
        ComplexType i(0., std::sqrt(0.5));
        ComplexType mat[2][2] = {{r, -i}, {r, i}};
        return TinyMatrix<ComplexType, 2>(mat);
    }
};

/// The S (phase) gate
class S : public OneQubitGate
{
  public:
    S(unsigned q) : OneQubitGate(q)
    {
    }

    std::string name() const
    {
        return "S";
    }

    DiagMatrix<ComplexType, 2> matrix() const
    {
        using val_t = ComplexType;
        val_t diag[2] = {val_t(1.), val_t(0., 1.)};
        return DiagMatrix<val_t, 2>(diag);
    }
};

/// The adjoint of the S (phase) gate
class AdjS : public OneQubitGate
{
  public:
    AdjS(unsigned q) : OneQubitGate(q)
    {
    }

    std::string name() const
    {
        return "AdjS";
    }

    DiagMatrix<ComplexType, 2> matrix() const
    {
        using val_t = ComplexType;
        val_t diag[2] = {val_t(1.), val_t(0., -1.)};
        return DiagMatrix<val_t, 2>(diag);
    }
};

/// The T (pi/8) gate
class T : public OneQubitGate
{
  public:
    T(unsigned q) : OneQubitGate(q)
    {
    }

    std::string name() const
    {
        return "T";
    }

    DiagMatrix<ComplexType, 2> matrix() const
    {
        using val_t = ComplexType;
        RealType r = std::sqrt(0.5);
        val_t diag[2] = {val_t(1.), val_t(r, r)};
        return DiagMatrix<val_t, 2>(diag);
    }
};

/// The T (pi/8) gate
class AdjT : public OneQubitGate
{
  public:
    AdjT(unsigned q) : OneQubitGate(q)
    {
    }

    std::string name() const
    {
        return "AdjT";
    }

    DiagMatrix<ComplexType, 2> matrix() const
    {
        using val_t = ComplexType;
        RealType r = std::sqrt(0.5);
        val_t diag[2] = {val_t(1.), val_t(r, -r)};
        return DiagMatrix<val_t, 2>(diag);
    }
};

/// The G gate
class G : public RotationGate
{
  public:
    G(RealType phi, unsigned q) : RotationGate(phi, q)
    {
    }

    std::string name() const
    {
        return "G";
    }

    DiagMatrix<ComplexType, 2> matrix() const
    {
        DiagMatrix<ComplexType, 2> d;
        ComplexType arg(0., 0.5 * angle());
        d(0, 0) = d(1, 1) = std::exp(-arg);
        return d;
    }
};

/// The Rx gate
class Rx : public RotationGate
{
  public:
    Rx(RealType phi, unsigned q) : RotationGate(phi, q)
    {
    }

    std::string name() const
    {
        return "Rx";
    }

    TinyMatrix<ComplexType, 2> matrix() const
    {
        using val_t = ComplexType;
        val_t s(0., -std::sin(0.5 * angle()));
        val_t c = std::cos(0.5 * angle());
        val_t mat[2][2] = {{c, s}, {s, c}};
        return TinyMatrix<val_t, 2>(mat);
    }
};

/// The Ry gate
class Ry : public RotationGate
{
  public:
    Ry(RealType phi, unsigned q) : RotationGate(phi, q)
    {
    }

    std::string name() const
    {
        return "Ry";
    }

    TinyMatrix<RealType, 2> matrix() const
    {
        RealType s = std::sin(0.5 * angle());
        RealType c = std::cos(0.5 * angle());
        RealType mat[2][2] = {{c, -s}, {s, c}};
        ;
        return TinyMatrix<RealType, 2>(mat);
    }
};

/// The Rz gate
class Rz : public RotationGate
{
  public:
    Rz(RealType phi, unsigned q) : RotationGate(phi, q)
    {
    }

    std::string name() const
    {
        return "Rz";
    }

    DiagMatrix<ComplexType, 2> matrix() const
    {
        DiagMatrix<ComplexType, 2> d;
        ComplexType arg(0., 0.5 * angle());
        d(0, 0) = std::exp(-arg);
        d(1, 1) = std::exp(arg);
        return d;
    }
};

/// The R1 gate
class R1 : public RotationGate
{
  public:
    R1(RealType phi, unsigned q) : RotationGate(phi, q)
    {
    }

    std::string name() const
    {
        return "R1";
    }

    DiagMatrix<ComplexType, 2> matrix() const
    {
        DiagMatrix<ComplexType, 2> d;
        ComplexType arg(0., angle());
        d(0, 0) = 1.;
        d(1, 1) = std::exp(-arg);
        return d;
    }
};

/// The R1 gate
class R1Frac : public R1
{
  public:
    R1Frac(int k, int n, unsigned q) : R1(M_PI * static_cast<RealType>(k) / static_cast<RealType>(1 << n), q)
    {
    }

    std::string name() const
    {
        return "R1Frac";
    }
};

/// The R gate for rotation around an arbitrary basis
class R : public RotationGate
{
  public:
    R(Basis b, RealType phi, unsigned q) : RotationGate(phi, q), b_(b)
    {
    }

    std::string name() const
    {
        return "R";
    }

    TinyMatrix<ComplexType, 2> matrix() const
    {
        switch (b_)
        {
            case PauliI:
                return G(angle(), qubit()).matrix();
                break;
            case PauliX:
                return Rx(angle(), qubit()).matrix();
                break;
            case PauliY:
                return Ry(angle(), qubit()).matrix();
                break;
            case PauliZ:
                return Rz(angle(), qubit()).matrix();
                break;
            default:
                assert(false);
        }
        // dummy return
        return TinyMatrix<ComplexType, 2>();
    }

  private:
    Basis b_;
};

class RFrac : public R
{
  public:
    RFrac(Basis b, int k, int n, unsigned q) : R(b, -2. * M_PI * static_cast<RealType>(k) / static_cast<RealType>(1 << n), q)
    {
    }
    std::string name() const
    {
        return "RFrac";
    }
};
}
}
}
}
