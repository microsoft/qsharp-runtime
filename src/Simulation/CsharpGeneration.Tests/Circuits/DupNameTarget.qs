// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

// Target definition file for testing name collision handling
namespace Microsoft.Quantum.A {
    operation X (q1 : Qubit) : Unit 
    is Adj + Ctl {
        body intrinsic;
        adjoint self;
    }
}

namespace Microsoft.Quantum.B {
    operation X (q1 : Qubit) : Unit 
    is Adj + Ctl {
        body intrinsic;
        adjoint self;
    }
}
