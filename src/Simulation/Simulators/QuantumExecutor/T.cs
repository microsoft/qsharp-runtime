using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumExecutor
{
    public partial class QuantumExecutorSimulator
    {
        public class QuantumExecutorSimT : Quantum.Intrinsic.T
        {
            private QuantumExecutorSimulator Simulator { get; }


            public QuantumExecutorSimT(QuantumExecutorSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<Qubit, QVoid> Body => (q1) =>
            {

                Simulator.QuantumExecutor.T(q1);
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, Qubit), QVoid> ControlledBody => (_args) =>
            {

                (IQArray<Qubit> ctrls, Qubit q1) = _args;

                Simulator.QuantumExecutor.ControlledT(ctrls, q1);

                return QVoid.Instance;
            };

            public override Func<Qubit, QVoid> AdjointBody => (q1) =>
            {

                Simulator.QuantumExecutor.TAdj(q1);
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, Qubit), QVoid> ControlledAdjointBody => (_args) =>
            {

                (IQArray<Qubit> ctrls, Qubit q1) = _args;
                Simulator.QuantumExecutor.ControlledTAdj(ctrls, q1);
                return QVoid.Instance;
            };
        }
    }
}
