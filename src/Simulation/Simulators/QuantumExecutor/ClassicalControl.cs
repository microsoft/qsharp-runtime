using System;
using System.Diagnostics;
using System.Linq;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumExecutor
{
    public partial class QuantumExecutorSimulator
    {
        public class SimApplyIfElse : Extensions.ApplyIfElseIntrinsic
        {
            private QuantumExecutorSimulator Simulator { get; }

            public SimApplyIfElse(QuantumExecutorSimulator m) : base(m) { this.Simulator = m; }

            public override Func<(Result, ICallable, ICallable), QVoid> Body => (q) =>
            {
                var (measurementResult, onZero, onOne) = q;
                Simulator.QuantumExecutor.ClassicallyControlled(measurementResult, () => onZero.Apply(QVoid.Instance),
                                                            () => onOne.Apply(QVoid.Instance));
                return QVoid.Instance;
            };
        }

        public class SimApplyIfElseA : Extensions.ApplyIfElseIntrinsicA
        {
            private QuantumExecutorSimulator Simulator { get; }

            public SimApplyIfElseA(QuantumExecutorSimulator m) : base(m) { this.Simulator = m; }

            public override Func<(Result, IAdjointable, IAdjointable), QVoid> Body => (q) =>
            {
                var (measurementResult, onZero, onOne) = q;
                Simulator.QuantumExecutor.ClassicallyControlled(measurementResult, () => onZero.Apply(QVoid.Instance),
                                                            () => onOne.Apply(QVoid.Instance));
                return QVoid.Instance;
            };

            public override Func<(Result, IAdjointable, IAdjointable), QVoid> AdjointBody => (q) =>
            {
                var (measurementResult, onZero, onOne) = q;
                Simulator.QuantumExecutor.ClassicallyControlled(measurementResult,
                                                            () => onZero.Adjoint.Apply(QVoid.Instance),
                                                            () => onOne.Adjoint.Apply(QVoid.Instance));
                return QVoid.Instance;
            };
        }

        public class SimApplyIfElseC : Extensions.ApplyIfElseIntrinsicC
        {
            private QuantumExecutorSimulator Simulator { get; }

            public SimApplyIfElseC(QuantumExecutorSimulator m) : base(m) { this.Simulator = m; }

            public override Func<(Result, IControllable, IControllable), QVoid> Body => (q) =>
            {
                var (measurementResult, onZero, onOne) = q;
                Simulator.QuantumExecutor.ClassicallyControlled(measurementResult, () => onZero.Apply(QVoid.Instance),
                                                            () => onOne.Apply(QVoid.Instance));
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (Result, IControllable, IControllable)), QVoid> ControlledBody =>
                (q) =>
                {
                    var (ctrls, (measurementResult, onZero, onOne)) = q;
                    Simulator.QuantumExecutor.ClassicallyControlled(
                  measurementResult, () => onZero.Controlled.Apply(ctrls), () => onOne.Controlled.Apply(ctrls));
                    return QVoid.Instance;
                };
        }

        public class SimApplyIfElseCA : Extensions.ApplyIfElseIntrinsicCA
        {
            private QuantumExecutorSimulator Simulator { get; }

            public SimApplyIfElseCA(QuantumExecutorSimulator m) : base(m) { this.Simulator = m; }

            public override Func<(Result, IUnitary, IUnitary), QVoid> Body => (q) =>
            {
                var (measurementResult, onZero, onOne) = q;
                Simulator.QuantumExecutor.ClassicallyControlled(measurementResult, () => onZero.Apply(QVoid.Instance),
                                                            () => onOne.Apply(QVoid.Instance));
                return QVoid.Instance;
            };

            public override Func<(Result, IUnitary, IUnitary), QVoid> AdjointBody => (q) =>
            {
                var (measurementResult, onZero, onOne) = q;
                Simulator.QuantumExecutor.ClassicallyControlled(measurementResult,
                                                            () => onZero.Adjoint.Apply(QVoid.Instance),
                                                            () => onOne.Adjoint.Apply(QVoid.Instance));
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (Result, IUnitary, IUnitary)), QVoid> ControlledBody => (q) =>
            {
                var (ctrls, (measurementResult, onZero, onOne)) = q;
                Simulator.QuantumExecutor.ClassicallyControlled(measurementResult, () => onZero.Controlled.Apply(ctrls),
                                                            () => onOne.Controlled.Apply(ctrls));
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (Result, IUnitary, IUnitary)), QVoid> ControlledAdjointBody =>
                (q) =>
                {
                    var (ctrls, (measurementResult, onZero, onOne)) = q;
                    Simulator.QuantumExecutor.ClassicallyControlled(measurementResult,
                                                          () => onZero.Controlled.Adjoint.Apply(ctrls),
                                                          () => onOne.Controlled.Adjoint.Apply(ctrls));
                    return QVoid.Instance;
                };
        }
    }
}
