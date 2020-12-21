// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Testing.Tracer
{
    open Microsoft.Quantum.Intrinsic;

    @EntryPoint()
    operation something() : Union
    {
        using (qs = Qubit[5])
        {
            X(qs[0]);
            Rx(qs[1]);
            CNOT(qs[1], qs[2]);
            
        }
    }
}
