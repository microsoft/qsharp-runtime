// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {

    internal operation PreparePostM(result : Result, qubit : Qubit) : Unit {
        // This platform requires reset after measurement, and then must
        // re-prepare the measured state in the qubit.
        Reset(qubit);
        if (result == One) {
            X(qubit);
        }
    }
}