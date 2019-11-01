// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
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











        public class SimApplyConditionally : Extensions.ApplyConditionallyIntrinsic
        {
            private QuantumExecutorSimulator Simulator { get; }

            public SimApplyConditionally(QuantumExecutorSimulator m) : base(m) { this.Simulator = m; }

            public override Func<(IQArray<Result>, IQArray<Result>, ICallable, ICallable), QVoid> Body => (q) =>
            {
                var (measurementResults, resultsValues, onEqualOp, onNonEqualOp) = q;
                Simulator.QuantumExecutor.ClassicallyControlled(measurementResults, resultsValues, 
                                                                () => onEqualOp.Apply(QVoid.Instance),
                                                                () => onNonEqualOp.Apply(QVoid.Instance));
                return QVoid.Instance;
            };
        }

        public class SimApplyConditionallyA : Extensions.ApplyConditionallyIntrinsicA
        {
            private QuantumExecutorSimulator Simulator { get; }

            public SimApplyConditionallyA(QuantumExecutorSimulator m) : base(m) { this.Simulator = m; }

            public override Func<(IQArray<Result>, IQArray<Result>, IAdjointable, IAdjointable), QVoid> Body => (q) =>
            {
                var (measurementResults, resultsValues, onEqualOp, onNonEqualOp) = q;
                Simulator.QuantumExecutor.ClassicallyControlled(measurementResults, resultsValues,
                                                                () => onEqualOp.Apply(QVoid.Instance),
                                                                () => onNonEqualOp.Apply(QVoid.Instance));
                return QVoid.Instance;
            };

            public override Func<(IQArray<Result>, IQArray<Result>, IAdjointable, IAdjointable), QVoid> AdjointBody => (q) =>
            {
                var (measurementResults, resultsValues, onEqualOp, onNonEqualOp) = q;
                Simulator.QuantumExecutor.ClassicallyControlled(measurementResults, resultsValues,
                                                                () => onEqualOp.Adjoint.Apply(QVoid.Instance),
                                                                () => onNonEqualOp.Adjoint.Apply(QVoid.Instance));
                return QVoid.Instance;
            };
        }

        public class SimApplyConditionallyC : Extensions.ApplyConditionallyIntrinsicC
        {
            private QuantumExecutorSimulator Simulator { get; }

            public SimApplyConditionallyC(QuantumExecutorSimulator m) : base(m) { this.Simulator = m; }

            public override Func<(IQArray<Result>, IQArray<Result>, IControllable, IControllable), QVoid> Body => (q) =>
            {
                var (measurementResults, resultsValues, onEqualOp, onNonEqualOp) = q;
                Simulator.QuantumExecutor.ClassicallyControlled(measurementResults, resultsValues,
                                                                () => onEqualOp.Apply(QVoid.Instance),
                                                                () => onNonEqualOp.Apply(QVoid.Instance));
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (IQArray<Result>, IQArray<Result>, IControllable, IControllable)), QVoid> ControlledBody => //(q) =>
                (q) =>
                {
                    var (ctrls, (measurementResults, resultsValues, onEqualOp, onNonEqualOp)) = q;
                    Simulator.QuantumExecutor.ClassicallyControlled(measurementResults, resultsValues,
                                                                () => onEqualOp.Controlled.Apply(ctrls),
                                                                () => onNonEqualOp.Controlled.Apply(ctrls));
                    return QVoid.Instance;
                };
        }

        public class SimApplyConditionallyCA : Extensions.ApplyConditionallyIntrinsicCA
        {
            private QuantumExecutorSimulator Simulator { get; }

            public SimApplyConditionallyCA(QuantumExecutorSimulator m) : base(m) { this.Simulator = m; }

            public override Func<(IQArray<Result>, IQArray<Result>, IUnitary, IUnitary), QVoid> Body => (q) =>
            {
                var (measurementResults, resultsValues, onEqualOp, onNonEqualOp) = q;
                Simulator.QuantumExecutor.ClassicallyControlled(measurementResults, resultsValues,
                                                                () => onEqualOp.Apply(QVoid.Instance),
                                                                () => onNonEqualOp.Apply(QVoid.Instance));
                return QVoid.Instance;
            };

            public override Func<(IQArray<Result>, IQArray<Result>, IUnitary, IUnitary), QVoid> AdjointBody => (q) =>
            {
                var (measurementResults, resultsValues, onEqualOp, onNonEqualOp) = q;
                Simulator.QuantumExecutor.ClassicallyControlled(measurementResults, resultsValues,
                                                                () => onEqualOp.Adjoint.Apply(QVoid.Instance),
                                                                () => onNonEqualOp.Adjoint.Apply(QVoid.Instance));
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (IQArray<Result>, IQArray<Result>, IUnitary, IUnitary)), QVoid> ControlledBody => (q) =>
            {
                var (ctrls, (measurementResults, resultsValues, onEqualOp, onNonEqualOp)) = q;
                Simulator.QuantumExecutor.ClassicallyControlled(measurementResults, resultsValues, 
                                                                () => onEqualOp.Controlled.Apply(ctrls),
                                                                () => onNonEqualOp.Controlled.Apply(ctrls));
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (IQArray<Result>, IQArray<Result>, IUnitary, IUnitary)), QVoid> ControlledAdjointBody => //(q) =>
                (q) =>
                {
                    var (ctrls, (measurementResults, resultsValues, onEqualOp, onNonEqualOp)) = q;
                    Simulator.QuantumExecutor.ClassicallyControlled(measurementResults, resultsValues,
                                                                    () => onEqualOp.Controlled.Adjoint.Apply(ctrls),
                                                                    () => onNonEqualOp.Controlled.Adjoint.Apply(ctrls));
                    return QVoid.Instance;
                };
        }

    }
}
