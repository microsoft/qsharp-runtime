// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Testing.QIR
{

    open Microsoft.Quantum.Intrinsic;

    @EntryPoint()
    operation RandomBit() : Result {
        
        using (q = Qubit()) {
            H(q);
            return M(q);
        }
    }
}
