// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumProcessor
{
    public partial class QuantumProcessorDispatcher
    {

        private static void RunClause(ICallable op, OperationFunctor type, IQArray<Qubit>? ctrls)
        {
            switch (type)
            {
                case OperationFunctor.Body: op.Apply(QVoid.Instance); break;
                case OperationFunctor.Adjoint: ((IAdjointable)(op)).Adjoint.Apply(QVoid.Instance); break;
                case OperationFunctor.Controlled: ((IControllable)(op)).Controlled.Apply((ctrls, QVoid.Instance)); break;
                case OperationFunctor.ControlledAdjoint: ((IUnitary)(op)).Controlled.Adjoint.Apply((ctrls, QVoid.Instance)); break;
            }
        }

        private static QVoid ExecuteConditionalStatementInternal(QuantumProcessorDispatcher Simulator,
                                                    long statement,
                                                    ICallable onEqualOp,
                                                    ICallable onNonEqualOp,
                                                    OperationFunctor type,
                                                    IQArray<Qubit>? ctrls)
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
                                            OperationFunctor type,
                                            IQArray<Qubit>? ctrls)
        {
            long statement = Simulator.QuantumProcessor.StartConditionalStatement(measurementResults, resultsValues);
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
                                            OperationFunctor type,
                                            IQArray<Qubit>? ctrls)
        {
            long statement = Simulator.QuantumProcessor.StartConditionalStatement(measurementResult, resultValue);
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

            public override Func<(Result, ICallable, ICallable), QVoid> __Body__ => (q) =>
            {
                (Result measurementResult, ICallable onZero, ICallable onOne) = q;
                return ExecuteConditionalStatement(Simulator, measurementResult, Result.Zero, onZero, onOne, OperationFunctor.Body, null);
            };
        }

        public class QuantumProcessorApplyIfElseA : Extensions.ApplyIfElseIntrinsicA
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorApplyIfElseA(QuantumProcessorDispatcher m) : base(m) { this.Simulator = m; }

            public override Func<(Result, IAdjointable, IAdjointable), QVoid> __Body__ => (q) =>
            {
                (Result measurementResult, ICallable onZero, ICallable onOne) = q;
                return ExecuteConditionalStatement(Simulator, measurementResult, Result.Zero, onZero, onOne, OperationFunctor.Body, null);
            };

            public override Func<(Result, IAdjointable, IAdjointable), QVoid> __AdjointBody__ => (q) =>
            {
                (Result measurementResult, ICallable onZero, ICallable onOne) = q;
                return ExecuteConditionalStatement(Simulator, measurementResult, Result.Zero, onZero, onOne, OperationFunctor.Adjoint, null);
            };
        }

        public class QuantumProcessorApplyIfElseC : Extensions.ApplyIfElseIntrinsicC
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorApplyIfElseC(QuantumProcessorDispatcher m) : base(m) { this.Simulator = m; }

            public override Func<(Result, IControllable, IControllable), QVoid> __Body__ => (q) =>
            {
                (Result measurementResult, ICallable onZero, ICallable onOne) = q;
                return ExecuteConditionalStatement(Simulator, measurementResult, Result.Zero, onZero, onOne, OperationFunctor.Body, null);
            };

            public override Func<(IQArray<Qubit>, (Result, IControllable, IControllable)), QVoid> __ControlledBody__ => (q) =>
            {
                (IQArray<Qubit> ctrls, (Result measurementResult, ICallable onZero, ICallable onOne)) = q;
                if ((ctrls == null) || (ctrls.Count == 0))
                {
                    return ExecuteConditionalStatement(Simulator, measurementResult, Result.Zero, onZero, onOne, OperationFunctor.Body, null);
                }
                else
                {
                    return ExecuteConditionalStatement(Simulator, measurementResult, Result.Zero, onZero, onOne, OperationFunctor.Controlled, ctrls);
                }
            };
        }

        public class QuantumProcessorApplyIfElseCA : Extensions.ApplyIfElseIntrinsicCA
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorApplyIfElseCA(QuantumProcessorDispatcher m) : base(m) { this.Simulator = m; }

            public override Func<(Result, IUnitary, IUnitary), QVoid> __Body__ => (q) =>
            {
                (Result measurementResult, ICallable onZero, ICallable onOne) = q;
                return ExecuteConditionalStatement(Simulator, measurementResult, Result.Zero, onZero, onOne, OperationFunctor.Body, null);
            };

            public override Func<(Result, IUnitary, IUnitary), QVoid> __AdjointBody__ => (q) =>
            {
                (Result measurementResult, ICallable onZero, ICallable onOne) = q;
                return ExecuteConditionalStatement(Simulator, measurementResult, Result.Zero, onZero, onOne, OperationFunctor.Adjoint, null);
            };

            public override Func<(IQArray<Qubit>, (Result, IUnitary, IUnitary)), QVoid> __ControlledBody__ => (q) =>
            {
                (IQArray<Qubit> ctrls, (Result measurementResult, ICallable onZero, ICallable onOne)) = q;

                if ((ctrls == null) || (ctrls.Count == 0))
                {
                    return ExecuteConditionalStatement(Simulator, measurementResult, Result.Zero, onZero, onOne, OperationFunctor.Body, null);
                }
                else
                {
                    return ExecuteConditionalStatement(Simulator, measurementResult, Result.Zero, onZero, onOne, OperationFunctor.Controlled, ctrls);
                }
            };

            public override Func<(IQArray<Qubit>, (Result, IUnitary, IUnitary)), QVoid> __ControlledAdjointBody__ => (q) =>
            {
                (IQArray<Qubit> ctrls, (Result measurementResult, ICallable onZero, ICallable onOne)) = q;

                if ((ctrls == null) || (ctrls.Count == 0))
                {
                    return ExecuteConditionalStatement(Simulator, measurementResult, Result.Zero, onZero, onOne, OperationFunctor.Adjoint, null);
                }
                else
                {
                    return ExecuteConditionalStatement(Simulator, measurementResult, Result.Zero, onZero, onOne, OperationFunctor.ControlledAdjoint, ctrls);
                }
            };
        }



        public class QuantumProcessorApplyConditionally : Extensions.ApplyConditionallyIntrinsic
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorApplyConditionally(QuantumProcessorDispatcher m) : base(m) { this.Simulator = m; }

            public override Func<(IQArray<Result>, IQArray<Result>, ICallable, ICallable), QVoid> __Body__ => (q) =>
            {
                (IQArray<Result> measurementResults, IQArray<Result> resultsValues, ICallable onEqualOp, ICallable onNonEqualOp) = q;
                return ExecuteConditionalStatement(Simulator, measurementResults, resultsValues, onEqualOp, onNonEqualOp, OperationFunctor.Body, null);
            };
        }

        public class QuantumProcessorApplyConditionallyA : Extensions.ApplyConditionallyIntrinsicA
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorApplyConditionallyA(QuantumProcessorDispatcher m) : base(m) { this.Simulator = m; }

            public override Func<(IQArray<Result>, IQArray<Result>, IAdjointable, IAdjointable), QVoid> __Body__ => (q) =>
            {
                (IQArray<Result> measurementResults, IQArray<Result> resultsValues, ICallable onEqualOp, ICallable onNonEqualOp) = q;
                return ExecuteConditionalStatement(Simulator, measurementResults, resultsValues, onEqualOp, onNonEqualOp, OperationFunctor.Body, null);
            };

            public override Func<(IQArray<Result>, IQArray<Result>, IAdjointable, IAdjointable), QVoid> __AdjointBody__ => (q) =>
            {
                (IQArray<Result> measurementResults, IQArray<Result> resultsValues, ICallable onEqualOp, ICallable onNonEqualOp) = q;
                return ExecuteConditionalStatement(Simulator, measurementResults, resultsValues, onEqualOp, onNonEqualOp, OperationFunctor.Adjoint, null);
            };
        }

        public class QuantumProcessorApplyConditionallyC : Extensions.ApplyConditionallyIntrinsicC
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorApplyConditionallyC(QuantumProcessorDispatcher m) : base(m) { this.Simulator = m; }

            public override Func<(IQArray<Result>, IQArray<Result>, IControllable, IControllable), QVoid> __Body__ => (q) =>
            {
                (IQArray<Result> measurementResults, IQArray<Result> resultsValues, ICallable onEqualOp, ICallable onNonEqualOp) = q;
                return ExecuteConditionalStatement(Simulator, measurementResults, resultsValues, onEqualOp, onNonEqualOp, OperationFunctor.Body, null);
            };

            public override Func<(IQArray<Qubit>, (IQArray<Result>, IQArray<Result>, IControllable, IControllable)), QVoid> __ControlledBody__ => (q) =>
            {
                (IQArray<Qubit> ctrls, (IQArray<Result> measurementResults, IQArray<Result> resultsValues, ICallable onEqualOp, ICallable onNonEqualOp)) = q;

                if ((ctrls == null) || (ctrls.Count == 0))
                {
                    return ExecuteConditionalStatement(Simulator, measurementResults, resultsValues, onEqualOp, onNonEqualOp, OperationFunctor.Body, null);
                }
                else
                {
                    return ExecuteConditionalStatement(Simulator, measurementResults, resultsValues, onEqualOp, onNonEqualOp, OperationFunctor.Controlled, ctrls);
                }
            };
        }

        public class QuantumProcessorApplyConditionallyCA : Extensions.ApplyConditionallyIntrinsicCA
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorApplyConditionallyCA(QuantumProcessorDispatcher m) : base(m) { this.Simulator = m; }

            public override Func<(IQArray<Result>, IQArray<Result>, IUnitary, IUnitary), QVoid> __Body__ => (q) =>
            {
                (IQArray<Result> measurementResults, IQArray<Result> resultsValues, ICallable onEqualOp, ICallable onNonEqualOp) = q;
                return ExecuteConditionalStatement(Simulator, measurementResults, resultsValues, onEqualOp, onNonEqualOp, OperationFunctor.Body, null);
            };

            public override Func<(IQArray<Result>, IQArray<Result>, IUnitary, IUnitary), QVoid> __AdjointBody__ => (q) =>
            {
                (IQArray<Result> measurementResults, IQArray<Result> resultsValues, ICallable onEqualOp, ICallable onNonEqualOp) = q;
                return ExecuteConditionalStatement(Simulator, measurementResults, resultsValues, onEqualOp, onNonEqualOp, OperationFunctor.Adjoint, null);
            };

            public override Func<(IQArray<Qubit>, (IQArray<Result>, IQArray<Result>, IUnitary, IUnitary)), QVoid> __ControlledBody__ => (q) =>
            {
                (IQArray<Qubit> ctrls, (IQArray<Result> measurementResults, IQArray<Result> resultsValues, ICallable onEqualOp, ICallable onNonEqualOp)) = q;

                if ((ctrls == null) || (ctrls.Count == 0))
                {
                    return ExecuteConditionalStatement(Simulator, measurementResults, resultsValues, onEqualOp, onNonEqualOp, OperationFunctor.Body, null);
                }
                else
                {
                    return ExecuteConditionalStatement(Simulator, measurementResults, resultsValues, onEqualOp, onNonEqualOp, OperationFunctor.Controlled, ctrls);
                }
            };

            public override Func<(IQArray<Qubit>, (IQArray<Result>, IQArray<Result>, IUnitary, IUnitary)), QVoid> __ControlledAdjointBody__ => (q) =>
            {
                (IQArray<Qubit> ctrls, (IQArray<Result> measurementResults, IQArray<Result> resultsValues, ICallable onEqualOp, ICallable onNonEqualOp)) = q;

                if ((ctrls == null) || (ctrls.Count == 0))
                {
                    return ExecuteConditionalStatement(Simulator, measurementResults, resultsValues, onEqualOp, onNonEqualOp, OperationFunctor.Adjoint, null);
                }
                else
                {
                    return ExecuteConditionalStatement(Simulator, measurementResults, resultsValues, onEqualOp, onNonEqualOp, OperationFunctor.ControlledAdjoint, ctrls);
                }
            };
        }

    }
}
