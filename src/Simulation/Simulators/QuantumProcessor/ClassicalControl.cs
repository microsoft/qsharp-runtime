// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumProcessor
{
    public partial class QuantumProcessorDispatcher
    {
        private enum FunctorType
        {
            Body,
            Adjoint,
            Controlled,
            AdjointControlled,
        }

        private static void RunClause(ICallable op, FunctorType type, IQArray<Qubit> ctrls)
        {
            switch (type)
            {
                case FunctorType.Body: op.Apply(QVoid.Instance); break;
                case FunctorType.Adjoint: ((IAdjointable)(op)).Adjoint.Apply(QVoid.Instance); break;
                case FunctorType.Controlled: ((IControllable)(op)).Controlled.Apply(ctrls); break;
                case FunctorType.AdjointControlled: ((IUnitary)(op)).Controlled.Adjoint.Apply(ctrls); break;
            }
        }

        private static QVoid ExecuteConditionalStatementInternal(QuantumProcessorDispatcher Simulator,
                                                    int statement,
                                                    ICallable onEqualOp,
                                                    ICallable onNonEqualOp,
                                                    FunctorType type,
                                                    IQArray<Qubit> ctrls)
        {
            bool run;

            run = Simulator.QuantumProcessor.RunThenClause(statement);
            while (run)
            {
                RunClause(onEqualOp, type, ctrls);
                run = Simulator.QuantumProcessor.RepeatThenClause(statement);
            }

            run = Simulator.QuantumProcessor.RunElseClause(statement);
            while (run)
            {
                RunClause(onNonEqualOp, type, ctrls);
                run = Simulator.QuantumProcessor.RepeatElseClause(statement);
            }

            Simulator.QuantumProcessor.EndConditionalStatement(statement);

            return QVoid.Instance;
        }

        private static QVoid ExecuteConditionalStatement(QuantumProcessorDispatcher Simulator,
                                            IQArray<Result> measurementResults,
                                            IQArray<Result> resultsValues,
                                            ICallable onEqualOp,
                                            ICallable onNonEqualOp,
                                            FunctorType type,
                                            IQArray<Qubit> ctrls)
        {
            int statement = Simulator.QuantumProcessor.StartConditionalStatement(measurementResults, resultsValues);
            return ExecuteConditionalStatementInternal(Simulator,
                                                        statement,
                                                        onEqualOp,
                                                        onNonEqualOp,
                                                        type,
                                                        ctrls);
        }

        private static QVoid ExecuteConditionalStatement(QuantumProcessorDispatcher Simulator,
                                            Result measurementResult,
                                            Result resultValue,
                                            ICallable onEqualOp,
                                            ICallable onNonEqualOp,
                                            FunctorType type,
                                            IQArray<Qubit> ctrls)
        {
            int statement = Simulator.QuantumProcessor.StartConditionalStatement(measurementResult, resultValue);
            return ExecuteConditionalStatementInternal(Simulator,
                                                        statement,
                                                        onEqualOp,
                                                        onNonEqualOp,
                                                        type,
                                                        ctrls);
        }


        public class QuantumProcessorApplyIfElse : Extensions.ApplyIfElseIntrinsic
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorApplyIfElse(QuantumProcessorDispatcher m) : base(m) { this.Simulator = m; }

            public override Func<(Result, ICallable, ICallable), QVoid> Body => (q) =>
            {
                var (measurementResult, onZero, onOne) = q;
                return ExecuteConditionalStatement(Simulator, measurementResult, Result.Zero, onZero, onOne, FunctorType.Body, null);
            };
        }

        public class QuantumProcessorApplyIfElseA : Extensions.ApplyIfElseIntrinsicA
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorApplyIfElseA(QuantumProcessorDispatcher m) : base(m) { this.Simulator = m; }

            public override Func<(Result, IAdjointable, IAdjointable), QVoid> Body => (q) =>
            {
                var (measurementResult, onZero, onOne) = q;
                return ExecuteConditionalStatement(Simulator, measurementResult, Result.Zero, onZero, onOne, FunctorType.Body, null);
            };

            public override Func<(Result, IAdjointable, IAdjointable), QVoid> AdjointBody => (q) =>
            {
                var (measurementResult, onZero, onOne) = q;
                return ExecuteConditionalStatement(Simulator, measurementResult, Result.Zero, onZero, onOne, FunctorType.Adjoint, null);
            };
        }

        public class QuantumProcessorApplyIfElseC : Extensions.ApplyIfElseIntrinsicC
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorApplyIfElseC(QuantumProcessorDispatcher m) : base(m) { this.Simulator = m; }

            public override Func<(Result, IControllable, IControllable), QVoid> Body => (q) =>
            {
                var (measurementResult, onZero, onOne) = q;
                return ExecuteConditionalStatement(Simulator, measurementResult, Result.Zero, onZero, onOne, FunctorType.Body, null);
            };

            public override Func<(IQArray<Qubit>, (Result, IControllable, IControllable)), QVoid> ControlledBody => (q) =>
            {
                var (ctrls, (measurementResult, onZero, onOne)) = q;
                return ExecuteConditionalStatement(Simulator, measurementResult, Result.Zero, onZero, onOne, FunctorType.Controlled, ctrls);
            };
        }

        public class QuantumProcessorApplyIfElseCA : Extensions.ApplyIfElseIntrinsicCA
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorApplyIfElseCA(QuantumProcessorDispatcher m) : base(m) { this.Simulator = m; }

            public override Func<(Result, IUnitary, IUnitary), QVoid> Body => (q) =>
            {
                var (measurementResult, onZero, onOne) = q;
                return ExecuteConditionalStatement(Simulator, measurementResult, Result.Zero, onZero, onOne, FunctorType.Body, null);
            };

            public override Func<(Result, IUnitary, IUnitary), QVoid> AdjointBody => (q) =>
            {
                var (measurementResult, onZero, onOne) = q;
                return ExecuteConditionalStatement(Simulator, measurementResult, Result.Zero, onZero, onOne, FunctorType.Adjoint, null);
            };

            public override Func<(IQArray<Qubit>, (Result, IUnitary, IUnitary)), QVoid> ControlledBody => (q) =>
            {
                var (ctrls, (measurementResult, onZero, onOne)) = q;
                return ExecuteConditionalStatement(Simulator, measurementResult, Result.Zero, onZero, onOne, FunctorType.Controlled, ctrls);
            };

            public override Func<(IQArray<Qubit>, (Result, IUnitary, IUnitary)), QVoid> ControlledAdjointBody => (q) =>
            {
                var (ctrls, (measurementResult, onZero, onOne)) = q;
                return ExecuteConditionalStatement(Simulator, measurementResult, Result.Zero, onZero, onOne, FunctorType.AdjointControlled, ctrls);
            };
        }



        public class QuantumProcessorApplyConditionally : Extensions.ApplyConditionallyIntrinsic
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorApplyConditionally(QuantumProcessorDispatcher m) : base(m) { this.Simulator = m; }

            public override Func<(IQArray<Result>, IQArray<Result>, ICallable, ICallable), QVoid> Body => (q) =>
            {
                var (measurementResults, resultsValues, onEqualOp, onNonEqualOp) = q;
                return ExecuteConditionalStatement(Simulator, measurementResults, resultsValues, onEqualOp, onNonEqualOp, FunctorType.Body, null);
            };
        }

        public class QuantumProcessorApplyConditionallyA : Extensions.ApplyConditionallyIntrinsicA
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorApplyConditionallyA(QuantumProcessorDispatcher m) : base(m) { this.Simulator = m; }

            public override Func<(IQArray<Result>, IQArray<Result>, IAdjointable, IAdjointable), QVoid> Body => (q) =>
            {
                var (measurementResults, resultsValues, onEqualOp, onNonEqualOp) = q;
                return ExecuteConditionalStatement(Simulator, measurementResults, resultsValues, onEqualOp, onNonEqualOp, FunctorType.Body, null);
            };

            public override Func<(IQArray<Result>, IQArray<Result>, IAdjointable, IAdjointable), QVoid> AdjointBody => (q) =>
            {
                var (measurementResults, resultsValues, onEqualOp, onNonEqualOp) = q;
                return ExecuteConditionalStatement(Simulator, measurementResults, resultsValues, onEqualOp, onNonEqualOp, FunctorType.Adjoint, null);
            };
        }

        public class QuantumProcessorApplyConditionallyC : Extensions.ApplyConditionallyIntrinsicC
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorApplyConditionallyC(QuantumProcessorDispatcher m) : base(m) { this.Simulator = m; }

            public override Func<(IQArray<Result>, IQArray<Result>, IControllable, IControllable), QVoid> Body => (q) =>
            {
                var (measurementResults, resultsValues, onEqualOp, onNonEqualOp) = q;
                return ExecuteConditionalStatement(Simulator, measurementResults, resultsValues, onEqualOp, onNonEqualOp, FunctorType.Body, null);
            };

            public override Func<(IQArray<Qubit>, (IQArray<Result>, IQArray<Result>, IControllable, IControllable)), QVoid> ControlledBody => (q) =>
            {
                var (ctrls, (measurementResults, resultsValues, onEqualOp, onNonEqualOp)) = q;
                return ExecuteConditionalStatement(Simulator, measurementResults, resultsValues, onEqualOp, onNonEqualOp, FunctorType.Controlled, ctrls);
            };
        }

        public class QuantumProcessorApplyConditionallyCA : Extensions.ApplyConditionallyIntrinsicCA
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorApplyConditionallyCA(QuantumProcessorDispatcher m) : base(m) { this.Simulator = m; }

            public override Func<(IQArray<Result>, IQArray<Result>, IUnitary, IUnitary), QVoid> Body => (q) =>
            {
                var (measurementResults, resultsValues, onEqualOp, onNonEqualOp) = q;
                return ExecuteConditionalStatement(Simulator, measurementResults, resultsValues, onEqualOp, onNonEqualOp, FunctorType.Body, null);
            };

            public override Func<(IQArray<Result>, IQArray<Result>, IUnitary, IUnitary), QVoid> AdjointBody => (q) =>
            {
                var (measurementResults, resultsValues, onEqualOp, onNonEqualOp) = q;
                return ExecuteConditionalStatement(Simulator, measurementResults, resultsValues, onEqualOp, onNonEqualOp, FunctorType.Adjoint, null);
            };

            public override Func<(IQArray<Qubit>, (IQArray<Result>, IQArray<Result>, IUnitary, IUnitary)), QVoid> ControlledBody => (q) =>
            {
                var (ctrls, (measurementResults, resultsValues, onEqualOp, onNonEqualOp)) = q;
                return ExecuteConditionalStatement(Simulator, measurementResults, resultsValues, onEqualOp, onNonEqualOp, FunctorType.Controlled, ctrls);
            };

            public override Func<(IQArray<Qubit>, (IQArray<Result>, IQArray<Result>, IUnitary, IUnitary)), QVoid> ControlledAdjointBody => (q) =>
            {
                var (ctrls, (measurementResults, resultsValues, onEqualOp, onNonEqualOp)) = q;
                return ExecuteConditionalStatement(Simulator, measurementResults, resultsValues, onEqualOp, onNonEqualOp, FunctorType.AdjointControlled, ctrls);
            };
        }

    }
}
