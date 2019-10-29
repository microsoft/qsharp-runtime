using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumExecutor
{
    public partial class QuantumExecutorSimulator
    {
        public class QuantumExecutorSimSWAP : Quantum.Intrinsic.SWAP
        {
            private QuantumExecutorSimulator Simulator { get; }


            public QuantumExecutorSimSWAP(QuantumExecutorSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<(Qubit,Qubit), QVoid> Body => (q1) =>
            {

                Simulator.QuantumExecutor.SWAP(q1.Item1, q1.Item2);
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (Qubit, Qubit)), QVoid> ControlledBody => (args) =>
            {

                var (ctrls, q1) = args;
                Simulator.QuantumExecutor.ControlledSWAP(ctrls, q1.Item1, q1.Item2);
                return QVoid.Instance;
            };
        }
    }
}
