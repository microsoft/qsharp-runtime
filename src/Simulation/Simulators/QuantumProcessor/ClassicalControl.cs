// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumProcessor
{
    public partial class QuantumProcessorDispatcher
    {
        public class QuantumProcessorApplyIfElse : Extensions.ApplyIfElseIntrinsic
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorApplyIfElse(QuantumProcessorDispatcher m) : base(m) { this.Simulator = m; }

            public override Func<(Result, ICallable, ICallable), QVoid> Body => (q) =>
            {
                var (measurementResult, onZero, onOne) = q;
                Simulator.QuantumProcessor.ClassicallyControlled(measurementResult, 
                                                                () => onZero.Apply(QVoid.Instance),
                                                                () => onOne.Apply(QVoid.Instance));
                return QVoid.Instance;
            };
        }

        public class QuantumProcessorApplyIfElseA : Extensions.ApplyIfElseIntrinsicA
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorApplyIfElseA(QuantumProcessorDispatcher m) : base(m) { this.Simulator = m; }

            public override Func<(Result, IAdjointable, IAdjointable), QVoid> Body => (q) =>
            {
                var (measurementResult, onZero, onOne) = q;
                Simulator.QuantumProcessor.ClassicallyControlled(measurementResult, 
                                                                () => onZero.Apply(QVoid.Instance),
                                                                () => onOne.Apply(QVoid.Instance));
                return QVoid.Instance;
            };

            public override Func<(Result, IAdjointable, IAdjointable), QVoid> AdjointBody => (q) =>
            {
                var (measurementResult, onZero, onOne) = q;
                Simulator.QuantumProcessor.ClassicallyControlled(measurementResult,
                                                                () => onZero.Adjoint.Apply(QVoid.Instance),
                                                                () => onOne.Adjoint.Apply(QVoid.Instance));
                return QVoid.Instance;
            };
        }

        public class QuantumProcessorApplyIfElseC : Extensions.ApplyIfElseIntrinsicC
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorApplyIfElseC(QuantumProcessorDispatcher m) : base(m) { this.Simulator = m; }

            public override Func<(Result, IControllable, IControllable), QVoid> Body => (q) =>
            {
                var (measurementResult, onZero, onOne) = q;
                Simulator.QuantumProcessor.ClassicallyControlled(measurementResult, 
                                                                () => onZero.Apply(QVoid.Instance),
                                                                () => onOne.Apply(QVoid.Instance));
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (Result, IControllable, IControllable)), QVoid> ControlledBody => (q) =>
            {
                var (ctrls, (measurementResult, onZero, onOne)) = q;
                Simulator.QuantumProcessor.ClassicallyControlled(measurementResult, 
                                                                () => onZero.Controlled.Apply(ctrls), 
                                                                () => onOne.Controlled.Apply(ctrls));
                return QVoid.Instance;
            };
        }

        public class QuantumProcessorApplyIfElseCA : Extensions.ApplyIfElseIntrinsicCA
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorApplyIfElseCA(QuantumProcessorDispatcher m) : base(m) { this.Simulator = m; }

            public override Func<(Result, IUnitary, IUnitary), QVoid> Body => (q) =>
            {
                var (measurementResult, onZero, onOne) = q;
                Simulator.QuantumProcessor.ClassicallyControlled(measurementResult, 
                                                                () => onZero.Apply(QVoid.Instance),
                                                                () => onOne.Apply(QVoid.Instance));
                return QVoid.Instance;
            };

            public override Func<(Result, IUnitary, IUnitary), QVoid> AdjointBody => (q) =>
            {
                var (measurementResult, onZero, onOne) = q;
                Simulator.QuantumProcessor.ClassicallyControlled(measurementResult,
                                                                () => onZero.Adjoint.Apply(QVoid.Instance),
                                                                () => onOne.Adjoint.Apply(QVoid.Instance));
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (Result, IUnitary, IUnitary)), QVoid> ControlledBody => (q) =>
            {
                var (ctrls, (measurementResult, onZero, onOne)) = q;
                Simulator.QuantumProcessor.ClassicallyControlled(measurementResult, 
                                                                () => onZero.Controlled.Apply(ctrls),
                                                                () => onOne.Controlled.Apply(ctrls));
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (Result, IUnitary, IUnitary)), QVoid> ControlledAdjointBody => (q) =>
            {
                var (ctrls, (measurementResult, onZero, onOne)) = q;
                Simulator.QuantumProcessor.ClassicallyControlled(measurementResult,
                                                                () => onZero.Controlled.Adjoint.Apply(ctrls),
                                                                () => onOne.Controlled.Adjoint.Apply(ctrls));
                return QVoid.Instance;
            };
        }



        public class QuantumProcessorApplyConditionally : Extensions.ApplyConditionallyIntrinsic
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorApplyConditionally(QuantumProcessorDispatcher m) : base(m) { this.Simulator = m; }

            public override Func<(IQArray<Result>, IQArray<Result>, ICallable, ICallable), QVoid> Body => (q) =>
            {
                var (measurementResults, resultsValues, onEqualOp, onNonEqualOp) = q;
                Simulator.QuantumProcessor.ClassicallyControlled(measurementResults, resultsValues, 
                                                                () => onEqualOp.Apply(QVoid.Instance),
                                                                () => onNonEqualOp.Apply(QVoid.Instance));
                return QVoid.Instance;
            };
        }

        public class QuantumProcessorApplyConditionallyA : Extensions.ApplyConditionallyIntrinsicA
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorApplyConditionallyA(QuantumProcessorDispatcher m) : base(m) { this.Simulator = m; }

            public override Func<(IQArray<Result>, IQArray<Result>, IAdjointable, IAdjointable), QVoid> Body => (q) =>
            {
                var (measurementResults, resultsValues, onEqualOp, onNonEqualOp) = q;
                Simulator.QuantumProcessor.ClassicallyControlled(measurementResults, resultsValues,
                                                                () => onEqualOp.Apply(QVoid.Instance),
                                                                () => onNonEqualOp.Apply(QVoid.Instance));
                return QVoid.Instance;
            };

            public override Func<(IQArray<Result>, IQArray<Result>, IAdjointable, IAdjointable), QVoid> AdjointBody => (q) =>
            {
                var (measurementResults, resultsValues, onEqualOp, onNonEqualOp) = q;
                Simulator.QuantumProcessor.ClassicallyControlled(measurementResults, resultsValues,
                                                                () => onEqualOp.Adjoint.Apply(QVoid.Instance),
                                                                () => onNonEqualOp.Adjoint.Apply(QVoid.Instance));
                return QVoid.Instance;
            };
        }

        public class QuantumProcessorApplyConditionallyC : Extensions.ApplyConditionallyIntrinsicC
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorApplyConditionallyC(QuantumProcessorDispatcher m) : base(m) { this.Simulator = m; }

            public override Func<(IQArray<Result>, IQArray<Result>, IControllable, IControllable), QVoid> Body => (q) =>
            {
                var (measurementResults, resultsValues, onEqualOp, onNonEqualOp) = q;
                Simulator.QuantumProcessor.ClassicallyControlled(measurementResults, resultsValues,
                                                                () => onEqualOp.Apply(QVoid.Instance),
                                                                () => onNonEqualOp.Apply(QVoid.Instance));
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (IQArray<Result>, IQArray<Result>, IControllable, IControllable)), QVoid> ControlledBody => (q) =>
            {
                var (ctrls, (measurementResults, resultsValues, onEqualOp, onNonEqualOp)) = q;
                Simulator.QuantumProcessor.ClassicallyControlled(measurementResults, resultsValues,
                                                            () => onEqualOp.Controlled.Apply(ctrls),
                                                            () => onNonEqualOp.Controlled.Apply(ctrls));
                return QVoid.Instance;
            };
        }

        public class QuantumProcessorApplyConditionallyCA : Extensions.ApplyConditionallyIntrinsicCA
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorApplyConditionallyCA(QuantumProcessorDispatcher m) : base(m) { this.Simulator = m; }

            public override Func<(IQArray<Result>, IQArray<Result>, IUnitary, IUnitary), QVoid> Body => (q) =>
            {
                var (measurementResults, resultsValues, onEqualOp, onNonEqualOp) = q;
                Simulator.QuantumProcessor.ClassicallyControlled(measurementResults, resultsValues,
                                                                () => onEqualOp.Apply(QVoid.Instance),
                                                                () => onNonEqualOp.Apply(QVoid.Instance));
                return QVoid.Instance;
            };

            public override Func<(IQArray<Result>, IQArray<Result>, IUnitary, IUnitary), QVoid> AdjointBody => (q) =>
            {
                var (measurementResults, resultsValues, onEqualOp, onNonEqualOp) = q;
                Simulator.QuantumProcessor.ClassicallyControlled(measurementResults, resultsValues,
                                                                () => onEqualOp.Adjoint.Apply(QVoid.Instance),
                                                                () => onNonEqualOp.Adjoint.Apply(QVoid.Instance));
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (IQArray<Result>, IQArray<Result>, IUnitary, IUnitary)), QVoid> ControlledBody => (q) =>
            {
                var (ctrls, (measurementResults, resultsValues, onEqualOp, onNonEqualOp)) = q;
                Simulator.QuantumProcessor.ClassicallyControlled(measurementResults, resultsValues, 
                                                                () => onEqualOp.Controlled.Apply(ctrls),
                                                                () => onNonEqualOp.Controlled.Apply(ctrls));
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (IQArray<Result>, IQArray<Result>, IUnitary, IUnitary)), QVoid> ControlledAdjointBody => (q) =>
            {
                var (ctrls, (measurementResults, resultsValues, onEqualOp, onNonEqualOp)) = q;
                Simulator.QuantumProcessor.ClassicallyControlled(measurementResults, resultsValues,
                                                                () => onEqualOp.Controlled.Adjoint.Apply(ctrls),
                                                                () => onNonEqualOp.Controlled.Adjoint.Apply(ctrls));
                return QVoid.Instance;
            };
        }

    }
}
