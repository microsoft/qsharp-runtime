// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public class QSimMeasure : Intrinsic.Measure
        {
            [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "Measure")]
            private static extern uint Measure(uint id, uint n, Pauli[] b, uint[] ids);

            private QuantumSimulator Simulator { get; }


            public QSimMeasure(QuantumSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<(IQArray<Pauli>, IQArray<Qubit>), Result> __Body__ => (_args) =>
            {
                var (paulis, qubits) = _args;

                Simulator.CheckQubits(qubits);
                if (paulis.Length != qubits.Length)
                {
                    throw new InvalidOperationException($"Both input arrays for {this.GetType().Name} (paulis,qubits), must be of same size");
                }
                foreach (Qubit q in qubits)
                {
                    //setting qubit as measured to allow for release
                    q.IsMeasured = true;
                }
                return Measure(Simulator.Id, (uint)paulis.Length, paulis.ToArray(), qubits.GetIds()).ToResult();
            };
        }
    }
}
