// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using static System.Math;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class CommonNativeSimulator
    {
        protected abstract double JointEnsembleProbability(uint n, Pauli[] b, uint[] q);

        public class QSimAssert : Microsoft.Quantum.Diagnostics.AssertMeasurement // TODO(rokuzmin): QSimAssert is never used?
        {
            private CommonNativeSimulator Simulator { get; }

            public QSimAssert(CommonNativeSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<(IQArray<Pauli>, IQArray<Qubit>, Result, string), QVoid> __Body__ => (_args) =>
            {
                var (paulis, qubits, result, msg) = _args;

                this.Simulator.CheckAndPreserveQubits(qubits);

                if (paulis.Length != qubits.Length)
                {
                    throw new InvalidOperationException($"Both input arrays for {this.GetType().Name} (paulis,qubits), must be of same size.");
                }

                var tolerance = 1.0e-10;
                var expectedPr = result == Result.Zero ? 0.0 : 1.0;

                var ensemblePr = this.Simulator.JointEnsembleProbability((uint)paulis.Length, paulis.ToArray(), qubits.GetIds());
                
                if (Abs(ensemblePr - expectedPr) > tolerance)
                {
                    var extendedMsg = $"{msg}\n\tExpected:\t{expectedPr}\n\tActual:\t{ensemblePr}";
                    IgnorableAssert.Assert(false, extendedMsg);
                    throw new ExecutionFailException(extendedMsg);
                }

                return QVoid.Instance;
            };

            public override Func<(IQArray<Pauli>, IQArray<Qubit>, Result, string), QVoid> __AdjointBody__ => (_args) => { return QVoid.Instance; };

            public override Func<(IQArray<Qubit>, (IQArray<Pauli>, IQArray<Qubit>, Result, string)), QVoid> __ControlledBody__ => (_args) => { return QVoid.Instance; };

            public override Func<(IQArray<Qubit>, (IQArray<Pauli>, IQArray<Qubit>, Result, string)), QVoid> __ControlledAdjointBody__ => (_args) => { return QVoid.Instance; };
        }
    }
}
