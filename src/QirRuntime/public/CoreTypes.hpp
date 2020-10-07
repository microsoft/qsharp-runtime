#pragma once

// The core types will be exposed in the C-interfaces for interop, thus no
// namespaces or scoped enums can be used to define them.


/*==============================================================================
  Helper types
==============================================================================*/
enum TernaryBool
{
    TernaryBool_False = 0,
    TernaryBool_True = 1,
    TernaryBool_Undefined,
};

/*==============================================================================
  Qubit & Result

  These two types are opaque to the clients: clients cannot directly create, delete,
  copy or check state of qubits and results. QUBIT* and RESULT* should never be
  dereferenced in client's code.
==============================================================================*/
class QUBIT;
typedef QUBIT *Qubit;

class RESULT;
typedef RESULT *Result;

enum ResultValue
{
    Result_Zero = 0,
    Result_One = 1,
    Result_Pending, // indicates that this is a deferred result
};

/*==============================================================================
  PauliId matrices
==============================================================================*/
enum PauliId
{
    PauliId_I = 0,
    PauliId_X = 1,
    PauliId_Z = 2,
    PauliId_Y = 3,
};

static const char PauliChars[4] = {'I', 'X', 'Z', 'Y'};

/*==============================================================================
  Clifford operators
==============================================================================*/
enum CliffordId
{
    CliffordId_H = 1,
    CliffordId_S = 2,
    CliffordId_SH = 3,
    CliffordId_HS = 4,
    CliffordId_HSH = 5,
};
