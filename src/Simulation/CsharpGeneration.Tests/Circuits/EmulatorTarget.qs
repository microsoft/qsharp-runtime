// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

// Target definition file for an emulated routine, for testing target generation.
namespace Microsoft.Quantum.QftEmulator {
    operation QFT (target : Qubit[]) : Unit
    is Adj + Ctl {
        body intrinsic;
    }
}


