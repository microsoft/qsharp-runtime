﻿// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Diagnostics;
using System.Linq;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;
using static System.Math;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public class QSimAssertProb : Quantum.Intrinsic.AssertProb
        {
            [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "JointEnsembleProbability")]
            private static extern double JointEnsembleProbability(uint id, uint n, Pauli[] b, uint[] q);

            private QuantumSimulator Simulator { get; }


            public QSimAssertProb(QuantumSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<(IQArray<Pauli>, IQArray<Qubit>, Result, double, string, double), QVoid> Body => (_args) =>
            {
                var (paulis, qubits, result, expectedPr, msg, tol) = _args;

                Simulator.CheckAndPreserveQubits(qubits);

                if (paulis.Length != qubits.Length)
                {
                    IgnorableAssert.Assert((paulis.Length != qubits.Length), "Arrays length mismatch");
                    throw new InvalidOperationException($"Both input arrays for {this.GetType().Name} (paulis,qubits), must be of same size.");
                }

                // Capture original expectedPr for clarity in failure logging later.
                var originalExpectedPr = expectedPr;

                if (result == Result.Zero)
                {
                    expectedPr = 1 - expectedPr;
                }

                var ensemblePr = JointEnsembleProbability(Simulator.Id, (uint)paulis.Length, paulis.ToArray(), qubits.GetIds());

                if (Abs(ensemblePr - expectedPr) > tol)
                {
                    string extendedMsg;
                    if (result == Result.Zero)
                    {
                        // To account for the modification of expectedPr to (1 - expectedPr) when (result == Result.Zero), 
                        // we must also update the ensemblePr to (1 - ensemblePr) when reporting the failure.
                        extendedMsg = $"{msg}\n\tExpected:\t{originalExpectedPr}\n\tActual:\t{(1 - ensemblePr)}";
                    }
                    else
                    {
                        extendedMsg = $"{msg}\n\tExpected:\t{originalExpectedPr}\n\tActual:\t{ensemblePr}";
                    }
                    
                    IgnorableAssert.Assert(false, extendedMsg);
                    throw new ExecutionFailException(extendedMsg);
                }

                return QVoid.Instance;
            };

            public override Func<(IQArray<Pauli>, IQArray<Qubit>, Result, double, string, double), QVoid> AdjointBody => (_args) => { return QVoid.Instance; };

            public override Func<(IQArray<Qubit>, (IQArray<Pauli>, IQArray<Qubit>, Result, double, string, double)), QVoid> ControlledBody => (_args) => { return QVoid.Instance; };

            public override Func<(IQArray<Qubit>, (IQArray<Pauli>, IQArray<Qubit>, Result, double, string, double)), QVoid> ControlledAdjointBody => (_args) => { return QVoid.Instance; };
        }
    }
}
