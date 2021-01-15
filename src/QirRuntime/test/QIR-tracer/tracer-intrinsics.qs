// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Testing.Tracer
{
    open Microsoft.Quantum.Intrinsic;

    operation Fixup(qs : Qubit[]) : Unit
    {
        for (i in 0..Length(qs)-1)
        {
            X(qs[i]);
        }
    }

    @EntryPoint()
    operation AllIntrinsics() : Bool
    {
        mutable res = false;
        using (qs = Qubit[3])
        {
            X(qs[0]);
            Y(qs[0]);
            Z(qs[1]);
            H(qs[1]);
            CNOT(qs[1], qs[2]);
            Rx(0.3, qs[0]);
            Ry(0.4, qs[1]);
            Rz(0.5, qs[2]);
            //SWAP(qs[0], qs[2]);
            S(qs[1]);
            T(qs[2]);

            Barrier(42, 1);

            Adjoint X(qs[0]);
            Adjoint Y(qs[0]);
            Adjoint Z(qs[1]);
            Adjoint H(qs[1]);
            Adjoint CNOT(qs[1], qs[2]);
            Adjoint Rx(0.3, qs[0]);
            Adjoint Ry(0.4, qs[1]);
            Adjoint Rz(0.5, qs[2]);
            //Adjoint SWAP(qs[0], qs[2]);
            Adjoint S(qs[1]);
            Adjoint T(qs[2]);

            using (c = Qubit())
            {
                Controlled X([c], (qs[0]));
                Controlled Y([c], (qs[0]));
                Controlled Z([c], (qs[1]));
                Controlled H([c], (qs[1]));
                Controlled Rx([c], (0.3, qs[0]));
                Controlled Ry([c], (0.4, qs[1]));
                Controlled Rz([c], (0.5, qs[2]));
                //Controlled SWAP([c], (qs[0], qs[2]));
                Controlled S([c], (qs[1]));
                Controlled T([c], (qs[2]));
            }

            using (cc = Qubit[2])
            {
                Controlled X(cc, (qs[0]));
                Controlled Y(cc, (qs[0]));
                Controlled Z(cc, (qs[1]));
                Controlled H(cc, (qs[1]));
                Controlled Rx(cc, (0.3, qs[0]));
                Controlled Ry(cc, (0.4, qs[1]));
                Controlled Rz(cc, (0.5, qs[2]));
                //Controlled SWAP(cc, (qs[0], qs[2]));
                Controlled S(cc, (qs[1]));
                Controlled T(cc, (qs[2]));
            }

            //let r0 = M(qs[0])
            //ApplyIfZero(r0, (Z, qs[0]));

            let qs12 = [qs[1], qs[2]];
            //let r12 = Measure([PauliY, PauliX], qs12);
            //ApplyIfOne(r12, (Fixup, qs12));
        }
        return true;
    }
}
