// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Overrides the basic AND gate for faster execution 

using Microsoft.Quantum.Simulation.Core;
using System;
using System.Linq;
using Microsoft.Quantum.Canon;

namespace Microsoft.Quantum.SparseSimulation
{
    /*
    public class ApplyAndWrapper : ApplyAnd
    {
        private SparseSimulator simulator;
        public ApplyAndWrapper(IOperationFactory m) : base(m)
        {
            simulator = m as SparseSimulator;
        }

        public override Func<(Qubit, Qubit, Qubit), QVoid> __Body__ => simulator == null ? base.__Body__ : (args) =>
        {
            simulator.ApplyAnd(new QArray<Qubit>(args.Item1, args.Item2), args.Item3);
            return QVoid.Instance;
        };

        public override Func<(Qubit, Qubit, Qubit), QVoid> __AdjointBody__ => simulator == null ? base.__AdjointBody__ : (args) =>
        {
            simulator.AdjointApplyAnd(new QArray<Qubit>(args.Item1, args.Item2), args.Item3);
            return QVoid.Instance;
        };

        public override Func<(IQArray<Qubit>, (Qubit, Qubit, Qubit)), QVoid> __ControlledBody__ => simulator == null ? base.__ControlledBody__ : (args) =>
        {
            simulator.ApplyAnd(new QArray<Qubit>(args.Item1.Concat(new QArray<Qubit>(args.Item2.Item1, args.Item2.Item2))), args.Item2.Item3);
            return QVoid.Instance;
        };

        public override Func<(IQArray<Qubit>, (Qubit, Qubit, Qubit)), QVoid> __ControlledAdjointBody__ => simulator == null ? base.__ControlledAdjointBody__ : (args) =>
        {
            simulator.AdjointApplyAnd(new QArray<Qubit>(args.Item1.Concat(new QArray<Qubit>(args.Item2.Item1, args.Item2.Item2))), args.Item2.Item3);
            return QVoid.Instance;
        };
    }

    public partial class SparseSimulator
    {
        // Wrappers for the relevant functions of SparseSimulatorProcessor
        // Since And/AdjointAnd are inherently multi-controlled, there is only a multi-controlled
        // emulator
        public void ApplyAnd(IQArray<Qubit> controls, Qubit target)
        {
            ((SparseSimulatorProcessor)this.QuantumProcessor).MCApplyAnd(controls, target); ;
        }
        public void AdjointApplyAnd(IQArray<Qubit> controls, Qubit target)
        {
            ((SparseSimulatorProcessor)this.QuantumProcessor).MCAdjointApplyAnd(controls, target);
        }
    }
    */
}