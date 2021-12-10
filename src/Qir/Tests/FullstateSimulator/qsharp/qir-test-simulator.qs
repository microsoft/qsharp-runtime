// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

// This test uses all operations from the quantum instruction set that targets full state simulator.
// We are not validating the result, only that the test can compile and run against the simulator.
namespace Microsoft.Quantum.Testing.QIR
{
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Measurement;

    operation InvokeAllVariants(op : (Qubit => Unit is Adj + Ctl)) : Int
    {
        mutable res = 0;
        use (target, ctls) = (Qubit(), Qubit[2])
        {
            op(target);
            Adjoint op(target);
            if (M(target) != Zero) { set res = 1; }
            else
            {
                H(ctls[0]);
                H(ctls[1]);
                Controlled op(ctls, target);
                Adjoint Controlled op(ctls, target);
                if (M(target) != Zero) { set res = 2; }
                else
                {
                    H(ctls[0]);
                    H(ctls[1]);
                }
            }
        }
        return res;
    }

    @EntryPoint()
    operation Test_Simulator_QIS() : Int
    {
        mutable res = 0;
        set res = InvokeAllVariants(X);
        if (res != 0) { return res; }

        set res = InvokeAllVariants(Y);
        if (res != 0) { return 10 + res; }

        set res = InvokeAllVariants(Z);
        if (res != 0) { return 20 + res; }

        set res = InvokeAllVariants(H);
        if (res != 0) { return 30 + res; }

        set res = InvokeAllVariants(S);
        if (res != 0) { return 40 + res; }

        set res = InvokeAllVariants(T);
        if (res != 0) { return 50 + res; }

        set res = InvokeAllVariants(R(PauliX, 0.42, _));
        if (res != 0) { return 60 + res; }

        use (targets, ctls) = (Qubit[2], Qubit[2])
        {
            let theta = 0.42;
            Exp([PauliX, PauliY], theta, targets);
            Adjoint Exp([PauliX, PauliY], theta, targets);
            if (M(targets[0]) != Zero) { set res = 1; }

            H(ctls[0]);
            H(ctls[1]);
            Controlled Exp(ctls, ([PauliX, PauliY], theta, targets));
            Adjoint Controlled Exp(ctls, ([PauliX, PauliY], theta, targets));
            H(ctls[0]);
            H(ctls[1]);
            if (M(targets[0]) != Zero) { set res = 2; }
            ResetAll(targets + ctls);
        }
        if (res != 0) { return 70 + res; }

        use qs = Qubit[3]
        {
            H(qs[0]);
            H(qs[2]);
            if (Measure([PauliX, PauliZ, PauliX], qs) != Zero) { set res = 80; }
            ResetAll(qs);
        }
        return res;
    }

    @EntryPoint()
    operation InvalidRelease() : Unit {
        use q = Qubit();
        let _ = M(q);
        X(q);
    }

    @EntryPoint()
    operation MeasureRelease() : Unit {
        use qs = Qubit[2];
        X(qs[0]);
        let _ = Measure([PauliX], [qs[1]]);
        let _ = M(qs[0]);
    }

    operation CZ (a : Qubit, b : Qubit) : Unit
    {
        body (...)
        {
            H(b);
            CNOT(a, b);
            H(b);
        }
        
        adjoint self;
    }

    @EntryPoint()
    operation Advantage44() : Int {
        let loops = 10;
        let gateCnt = (171+27*2) * loops;
        using (q = Qubit[29]) {
            for (loop in 0..(loops-1)) {
                H(q[0]);
                H(q[1]);
                H(q[2]);
                H(q[3]);
                H(q[4]);
                H(q[5]);
                H(q[6]);
                H(q[7]);
                H(q[8]);
                H(q[9]);
                H(q[10]);
                H(q[11]);
                H(q[12]);
                H(q[13]);
                H(q[14]);
                H(q[15]);
                CZ(q[2],q[3]);
                CZ(q[10],q[11]);
                CZ(q[4],q[5]);
                CZ(q[12],q[13]);
                H(q[0]);
                H(q[1]);
                H(q[2]);
                H(q[3]);
                H(q[4]);
                H(q[5]);
                H(q[6]);
                H(q[7]);
                H(q[8]);
                H(q[9]);
                H(q[10]);
                H(q[11]);
                H(q[12]);
                H(q[13]);
                H(q[14]);
                H(q[15]);
                CZ(q[0],q[1]);
                CZ(q[8],q[9]);
                CZ(q[6],q[7]);
                CZ(q[14],q[15]);
                H(q[0]);
                H(q[1]);
                H(q[2]);
                H(q[3]);
                H(q[4]);
                H(q[5]);
                H(q[6]);
                H(q[7]);
                H(q[8]);
                H(q[9]);
                H(q[10]);
                H(q[11]);
                H(q[12]);
                H(q[13]);
                H(q[14]);
                H(q[15]);
                CZ(q[5],q[9]);
                CZ(q[7],q[11]);
                H(q[0]);
                H(q[1]);
                H(q[2]);
                H(q[3]);
                H(q[4]);
                H(q[5]);
                H(q[6]);
                H(q[7]);
                H(q[8]);
                H(q[9]);
                H(q[10]);
                H(q[11]);
                H(q[12]);
                H(q[13]);
                H(q[14]);
                H(q[15]);
                CZ(q[4],q[8]);
                CZ(q[6],q[10]);
                H(q[0]);
                H(q[1]);
                H(q[2]);
                H(q[3]);
                H(q[4]);
                H(q[5]);
                H(q[6]);
                H(q[7]);
                H(q[8]);
                H(q[9]);
                H(q[10]);
                H(q[11]);
                H(q[12]);
                H(q[13]);
                H(q[14]);
                H(q[15]);
                CZ(q[3],q[4]);
                CZ(q[11],q[12]);
                CZ(q[5],q[6]);
                CZ(q[13],q[14]);
                H(q[0]);
                H(q[1]);
                H(q[2]);
                H(q[3]);
                H(q[4]);
                H(q[5]);
                H(q[6]);
                H(q[7]);
                H(q[8]);
                H(q[9]);
                H(q[10]);
                H(q[11]);
                H(q[12]);
                H(q[13]);
                H(q[14]);
                H(q[15]);
                CZ(q[1],q[2]);
                CZ(q[9],q[10]);
                CZ(q[7],q[8]);
                H(q[0]);
                H(q[1]);
                H(q[2]);
                H(q[3]);
                H(q[4]);
                H(q[5]);
                H(q[6]);
                H(q[7]);
                H(q[8]);
                H(q[9]);
                H(q[10]);
                H(q[11]);
                H(q[12]);
                H(q[13]);
                H(q[14]);
                H(q[15]);
                CZ(q[0],q[4]);
                CZ(q[2],q[6]);
                CZ(q[9],q[13]);
                CZ(q[11],q[15]);
                H(q[0]);
                H(q[1]);
                H(q[2]);
                H(q[3]);
                H(q[4]);
                H(q[5]);
                H(q[6]);
                H(q[7]);
                H(q[8]);
                H(q[9]);
                H(q[10]);
                H(q[11]);
                H(q[12]);
                H(q[13]);
                H(q[14]);
                H(q[15]);
                CZ(q[8],q[12]);
                CZ(q[10],q[14]);
                CZ(q[1],q[5]);
                CZ(q[3],q[7]);
                H(q[0]);
                H(q[1]);
                H(q[2]);
                H(q[3]);
                H(q[4]);
                H(q[5]);
                H(q[6]);
                H(q[7]);
                H(q[8]);
                H(q[9]);
                H(q[10]);
                H(q[11]);
                H(q[12]);
                H(q[13]);
                H(q[14]);
                H(q[15]);
                //for (q1 in q) { let _ = M(q1); }
            }
        //ResetAll(q);
        }
    return(gateCnt);
    }

    @EntryPoint()
    operation Advantage55() : Int {
        let loops = 10;
        let gateCnt = (269+44*2) * loops;
        using (q = Qubit[25]) {
            for (loop in 0..(loops-1)) {
                H(q[0]);
                H(q[1]);
                H(q[2]);
                H(q[3]);
                H(q[4]);
                H(q[5]);
                H(q[6]);
                H(q[7]);
                H(q[8]);
                H(q[9]);
                H(q[10]);
                H(q[11]);
                H(q[12]);
                H(q[13]);
                H(q[14]);
                H(q[15]);
                H(q[16]);
                H(q[17]);
                H(q[18]);
                H(q[19]);
                H(q[20]);
                H(q[21]);
                H(q[22]);
                H(q[23]);
                H(q[24]);
                CZ(q[2],q[3]);
                CZ(q[12],q[13]);
                CZ(q[22],q[23]);
                CZ(q[5],q[6]);
                CZ(q[9],q[10]);
                CZ(q[15],q[16]);
                CZ(q[19],q[20]);
                H(q[0]);
                H(q[1]);
                H(q[2]);
                H(q[3]);
                H(q[4]);
                H(q[5]);
                H(q[6]);
                H(q[7]);
                H(q[8]);
                H(q[9]);
                H(q[10]);
                H(q[11]);
                H(q[12]);
                H(q[13]);
                H(q[14]);
                H(q[15]);
                H(q[16]);
                H(q[17]);
                H(q[18]);
                H(q[19]);
                H(q[20]);
                H(q[21]);
                H(q[22]);
                H(q[23]);
                H(q[24]);
                CZ(q[0],q[1]);
                CZ(q[4],q[5]);
                CZ(q[10],q[11]);
                CZ(q[14],q[15]);
                CZ(q[20],q[21]);
                CZ(q[7],q[8]);
                CZ(q[17],q[18]);
                H(q[0]);
                H(q[1]);
                H(q[2]);
                H(q[3]);
                H(q[4]);
                H(q[5]);
                H(q[6]);
                H(q[7]);
                H(q[8]);
                H(q[9]);
                H(q[10]);
                H(q[11]);
                H(q[12]);
                H(q[13]);
                H(q[14]);
                H(q[15]);
                H(q[16]);
                H(q[17]);
                H(q[18]);
                H(q[19]);
                H(q[20]);
                H(q[21]);
                H(q[22]);
                H(q[23]);
                H(q[24]);
                CZ(q[15],q[20]);
                CZ(q[17],q[22]);
                CZ(q[19],q[24]);
                CZ(q[6],q[11]);
                CZ(q[8],q[13]);
                H(q[0]);
                H(q[1]);
                H(q[2]);
                H(q[3]);
                H(q[4]);
                H(q[5]);
                H(q[6]);
                H(q[7]);
                H(q[8]);
                H(q[9]);
                H(q[10]);
                H(q[11]);
                H(q[12]);
                H(q[13]);
                H(q[14]);
                H(q[15]);
                H(q[16]);
                H(q[17]);
                H(q[18]);
                H(q[19]);
                H(q[20]);
                H(q[21]);
                H(q[22]);
                H(q[23]);
                H(q[24]);
                CZ(q[5],q[10]);
                CZ(q[7],q[12]);
                CZ(q[9],q[14]);
                CZ(q[16],q[21]);
                CZ(q[18],q[23]);
                H(q[0]);
                H(q[1]);
                H(q[2]);
                H(q[3]);
                H(q[4]);
                H(q[5]);
                H(q[6]);
                H(q[7]);
                H(q[8]);
                H(q[9]);
                H(q[10]);
                H(q[11]);
                H(q[12]);
                H(q[13]);
                H(q[14]);
                H(q[15]);
                H(q[16]);
                H(q[17]);
                H(q[18]);
                H(q[19]);
                H(q[20]);
                H(q[21]);
                H(q[22]);
                H(q[23]);
                H(q[24]);
                CZ(q[3],q[4]);
                CZ(q[13],q[14]);
                CZ(q[23],q[24]);
                CZ(q[6],q[7]);
                CZ(q[16],q[17]);
                H(q[0]);
                H(q[1]);
                H(q[2]);
                H(q[3]);
                H(q[4]);
                H(q[5]);
                H(q[6]);
                H(q[7]);
                H(q[8]);
                H(q[9]);
                H(q[10]);
                H(q[11]);
                H(q[12]);
                H(q[13]);
                H(q[14]);
                H(q[15]);
                H(q[16]);
                H(q[17]);
                H(q[18]);
                H(q[19]);
                H(q[20]);
                H(q[21]);
                H(q[22]);
                H(q[23]);
                H(q[24]);
                CZ(q[1],q[2]);
                CZ(q[11],q[12]);
                CZ(q[21],q[22]);
                CZ(q[8],q[9]);
                CZ(q[18],q[19]);
                H(q[0]);
                H(q[1]);
                H(q[2]);
                H(q[3]);
                H(q[4]);
                H(q[5]);
                H(q[6]);
                H(q[7]);
                H(q[8]);
                H(q[9]);
                H(q[10]);
                H(q[11]);
                H(q[12]);
                H(q[13]);
                H(q[14]);
                H(q[15]);
                H(q[16]);
                H(q[17]);
                H(q[18]);
                H(q[19]);
                H(q[20]);
                H(q[21]);
                H(q[22]);
                H(q[23]);
                H(q[24]);
                CZ(q[0],q[5]);
                CZ(q[2],q[7]);
                CZ(q[4],q[9]);
                CZ(q[11],q[16]);
                CZ(q[13],q[18]);
                H(q[0]);
                H(q[1]);
                H(q[2]);
                H(q[3]);
                H(q[4]);
                H(q[5]);
                H(q[6]);
                H(q[7]);
                H(q[8]);
                H(q[9]);
                H(q[10]);
                H(q[11]);
                H(q[12]);
                H(q[13]);
                H(q[14]);
                H(q[15]);
                H(q[16]);
                H(q[17]);
                H(q[18]);
                H(q[19]);
                H(q[20]);
                H(q[21]);
                H(q[22]);
                H(q[23]);
                H(q[24]);
                CZ(q[10],q[15]);
                CZ(q[12],q[17]);
                CZ(q[14],q[19]);
                CZ(q[1],q[6]);
                CZ(q[3],q[8]);
                H(q[0]);
                H(q[1]);
                H(q[2]);
                H(q[3]);
                H(q[4]);
                H(q[5]);
                H(q[6]);
                H(q[7]);
                H(q[8]);
                H(q[9]);
                H(q[10]);
                H(q[11]);
                H(q[12]);
                H(q[13]);
                H(q[14]);
                H(q[15]);
                H(q[16]);
                H(q[17]);
                H(q[18]);
                H(q[19]);
                H(q[20]);
                H(q[21]);
                H(q[22]);
                H(q[23]);
                H(q[24]);
                //for (q1 in q) { let _ = M(q1); }
            }
        //ResetAll(q);
        }
    return(gateCnt);
    }

    @EntryPoint()
    operation Advantage56() : Int {
        let loops = 10;
        let gateCnt = (323+53*2) * loops;
        using (q = Qubit[30]) {
            for (loop in 0..(loops-1)) {
                H(q[0]);
                H(q[1]);
                H(q[2]);
                H(q[3]);
                H(q[4]);
                H(q[5]);
                H(q[6]);
                H(q[7]);
                H(q[8]);
                H(q[9]);
                H(q[10]);
                H(q[11]);
                H(q[12]);
                H(q[13]);
                H(q[14]);
                H(q[15]);
                H(q[16]);
                H(q[17]);
                H(q[18]);
                H(q[19]);
                H(q[20]);
                H(q[21]);
                H(q[22]);
                H(q[23]);
                H(q[24]);
                H(q[25]);
                H(q[26]);
                H(q[27]);
                H(q[28]);
                H(q[29]);
                CZ(q[2],q[3]);
                CZ(q[14],q[15]);
                CZ(q[26],q[27]);
                CZ(q[6],q[7]);
                CZ(q[10],q[11]);
                CZ(q[18],q[19]);
                CZ(q[22],q[23]);
                H(q[0]);
                H(q[1]);
                H(q[2]);
                H(q[3]);
                H(q[4]);
                H(q[5]);
                H(q[6]);
                H(q[7]);
                H(q[8]);
                H(q[9]);
                H(q[10]);
                H(q[11]);
                H(q[12]);
                H(q[13]);
                H(q[14]);
                H(q[15]);
                H(q[16]);
                H(q[17]);
                H(q[18]);
                H(q[19]);
                H(q[20]);
                H(q[21]);
                H(q[22]);
                H(q[23]);
                H(q[24]);
                H(q[25]);
                H(q[26]);
                H(q[27]);
                H(q[28]);
                H(q[29]);
                CZ(q[0],q[1]);
                CZ(q[4],q[5]);
                CZ(q[12],q[13]);
                CZ(q[16],q[17]);
                CZ(q[24],q[25]);
                CZ(q[28],q[29]);
                CZ(q[8],q[9]);
                CZ(q[20],q[21]);
                H(q[0]);
                H(q[1]);
                H(q[2]);
                H(q[3]);
                H(q[4]);
                H(q[5]);
                H(q[6]);
                H(q[7]);
                H(q[8]);
                H(q[9]);
                H(q[10]);
                H(q[11]);
                H(q[12]);
                H(q[13]);
                H(q[14]);
                H(q[15]);
                H(q[16]);
                H(q[17]);
                H(q[18]);
                H(q[19]);
                H(q[20]);
                H(q[21]);
                H(q[22]);
                H(q[23]);
                H(q[24]);
                H(q[25]);
                H(q[26]);
                H(q[27]);
                H(q[28]);
                H(q[29]);
                CZ(q[18],q[24]);
                CZ(q[20],q[26]);
                CZ(q[22],q[28]);
                CZ(q[7],q[13]);
                CZ(q[9],q[15]);
                CZ(q[11],q[17]);
                H(q[0]);
                H(q[1]);
                H(q[2]);
                H(q[3]);
                H(q[4]);
                H(q[5]);
                H(q[6]);
                H(q[7]);
                H(q[8]);
                H(q[9]);
                H(q[10]);
                H(q[11]);
                H(q[12]);
                H(q[13]);
                H(q[14]);
                H(q[15]);
                H(q[16]);
                H(q[17]);
                H(q[18]);
                H(q[19]);
                H(q[20]);
                H(q[21]);
                H(q[22]);
                H(q[23]);
                H(q[24]);
                H(q[25]);
                H(q[26]);
                H(q[27]);
                H(q[28]);
                H(q[29]);
                CZ(q[6],q[12]);
                CZ(q[8],q[14]);
                CZ(q[10],q[16]);
                CZ(q[19],q[25]);
                CZ(q[21],q[27]);
                CZ(q[23],q[29]);
                H(q[0]);
                H(q[1]);
                H(q[2]);
                H(q[3]);
                H(q[4]);
                H(q[5]);
                H(q[6]);
                H(q[7]);
                H(q[8]);
                H(q[9]);
                H(q[10]);
                H(q[11]);
                H(q[12]);
                H(q[13]);
                H(q[14]);
                H(q[15]);
                H(q[16]);
                H(q[17]);
                H(q[18]);
                H(q[19]);
                H(q[20]);
                H(q[21]);
                H(q[22]);
                H(q[23]);
                H(q[24]);
                H(q[25]);
                H(q[26]);
                H(q[27]);
                H(q[28]);
                H(q[29]);
                CZ(q[3],q[4]);
                CZ(q[15],q[16]);
                CZ(q[27],q[28]);
                CZ(q[7],q[8]);
                CZ(q[11],q[12]);
                CZ(q[19],q[20]);
                CZ(q[23],q[24]);
                H(q[0]);
                H(q[1]);
                H(q[2]);
                H(q[3]);
                H(q[4]);
                H(q[5]);
                H(q[6]);
                H(q[7]);
                H(q[8]);
                H(q[9]);
                H(q[10]);
                H(q[11]);
                H(q[12]);
                H(q[13]);
                H(q[14]);
                H(q[15]);
                H(q[16]);
                H(q[17]);
                H(q[18]);
                H(q[19]);
                H(q[20]);
                H(q[21]);
                H(q[22]);
                H(q[23]);
                H(q[24]);
                H(q[25]);
                H(q[26]);
                H(q[27]);
                H(q[28]);
                H(q[29]);
                CZ(q[1],q[2]);
                CZ(q[5],q[6]);
                CZ(q[13],q[14]);
                CZ(q[17],q[18]);
                CZ(q[25],q[26]);
                CZ(q[9],q[10]);
                CZ(q[21],q[22]);
                H(q[0]);
                H(q[1]);
                H(q[2]);
                H(q[3]);
                H(q[4]);
                H(q[5]);
                H(q[6]);
                H(q[7]);
                H(q[8]);
                H(q[9]);
                H(q[10]);
                H(q[11]);
                H(q[12]);
                H(q[13]);
                H(q[14]);
                H(q[15]);
                H(q[16]);
                H(q[17]);
                H(q[18]);
                H(q[19]);
                H(q[20]);
                H(q[21]);
                H(q[22]);
                H(q[23]);
                H(q[24]);
                H(q[25]);
                H(q[26]);
                H(q[27]);
                H(q[28]);
                H(q[29]);
                CZ(q[0],q[6]);
                CZ(q[2],q[8]);
                CZ(q[4],q[10]);
                CZ(q[13],q[19]);
                CZ(q[15],q[21]);
                CZ(q[17],q[23]);
                H(q[0]);
                H(q[1]);
                H(q[2]);
                H(q[3]);
                H(q[4]);
                H(q[5]);
                H(q[6]);
                H(q[7]);
                H(q[8]);
                H(q[9]);
                H(q[10]);
                H(q[11]);
                H(q[12]);
                H(q[13]);
                H(q[14]);
                H(q[15]);
                H(q[16]);
                H(q[17]);
                H(q[18]);
                H(q[19]);
                H(q[20]);
                H(q[21]);
                H(q[22]);
                H(q[23]);
                H(q[24]);
                H(q[25]);
                H(q[26]);
                H(q[27]);
                H(q[28]);
                H(q[29]);
                CZ(q[12],q[18]);
                CZ(q[14],q[20]);
                CZ(q[16],q[22]);
                CZ(q[1],q[7]);
                CZ(q[3],q[9]);
                CZ(q[5],q[11]);
                H(q[0]);
                H(q[1]);
                H(q[2]);
                H(q[3]);
                H(q[4]);
                H(q[5]);
                H(q[6]);
                H(q[7]);
                H(q[8]);
                H(q[9]);
                H(q[10]);
                H(q[11]);
                H(q[12]);
                H(q[13]);
                H(q[14]);
                H(q[15]);
                H(q[16]);
                H(q[17]);
                H(q[18]);
                H(q[19]);
                H(q[20]);
                H(q[21]);
                H(q[22]);
                H(q[23]);
                H(q[24]);
                H(q[25]);
                H(q[26]);
                H(q[27]);
                H(q[28]);
                H(q[29]);
                //for (q1 in q) { let _ = M(q1); }
            }
        //ResetAll(q);
        }
    return(gateCnt);
    }

    @EntryPoint()
    operation HGate() : Int {
        let loops = 3;
        let gateCnt = (1) * loops;
        using (q = Qubit[29]) {
            for (loop in 0..(loops-1)) {
                H(q[0]);
            }
        //ResetAll(q);
        }
    return(gateCnt);
    }

    @EntryPoint()
    operation CNOTGate() : Int {
        let loops = 3;
        let gateCnt = (1) * loops;
        using (q = Qubit[29]) {
            for (loop in 0..(loops-1)) {
                CNOT(q[0], q[1]);
            }
        //ResetAll(q);
        }
    return(gateCnt);
    }

    @EntryPoint()
    operation CCNOTGate() : Int {
        let loops = 3;
        let gateCnt = (1) * loops;
        using (q = Qubit[29]) {
            for (loop in 0..(loops-1)) {
                CCNOT(q[0], q[1], q[2]);
            }
        //ResetAll(q);
        }
    return(gateCnt);
    }
}
