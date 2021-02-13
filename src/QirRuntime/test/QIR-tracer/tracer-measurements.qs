// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Testing.Tracer
{
    open Microsoft.Quantum.Intrinsic;

    operation Fixup(qs : Qubit[]) : Unit
    {
        for i in 0..Length(qs)-1
        {
            X(qs[i]);
        }
    }

    operation TestMeasurements(compare : Bool) : Unit
    {
        use qs = Qubit[3]
        {
            let r0 = M(qs[0]);
            let qs12 = [qs[1], qs[2]];
            let r12 = Measure([PauliY, PauliX], qs12);

            if (compare)
            {
                if r0 == Zero
                {
                    X(qs[1]);
                }

                //ApplyIfOne(r12, (Fixup, qs12));
            }
        }
    }
}