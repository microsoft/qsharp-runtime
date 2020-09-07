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
                case OperationFunctor.Adjoint: ((IAdjointable)op).Adjoint.Apply(QVoid.Instance); break;
                case OperationFunctor.Controlled: ((IControllable)op).Controlled.Apply((ctrls, QVoid.Instance)); break;
                case OperationFunctor.ControlledAdjoint: ((IUnitary)op).Controlled.Adjoint.Apply((ctrls, QVoid.Instance)); break;
            }
        }

        private void ExecuteConditionalStatementInternal(long statement, ICallable onEqualOp, ICallable onNonEqualOp, OperationFunctor type, IQArray<Qubit>? ctrls)
        {
            bool run = this.QuantumProcessor.RunThenClause(statement);
            while (run)
            {
                RunClause(onEqualOp, type, ctrls);
                run = this.QuantumProcessor.RepeatThenClause(statement);
            }

            run = this.QuantumProcessor.RunElseClause(statement);
            while (run)
            {
                RunClause(onNonEqualOp, type, ctrls);
                run = this.QuantumProcessor.RepeatElseClause(statement);
            }
        }

        private void ExecuteConditionalStatement(IQArray<Result> results1, IQArray<Result> results2, ICallable onEqual,  ICallable onNonEqual, OperationFunctor type, IQArray<Qubit>? ctrls)
        {
            long statement = this.QuantumProcessor.StartConditionalStatement(results1, results2);
            ExecuteConditionalStatementInternal(statement, onEqual, onNonEqual, type, ctrls);
            this.QuantumProcessor.EndConditionalStatement(statement);
        }

        private void ExecuteConditionalStatement(Result result1, Result result2, ICallable onEqualOp, ICallable onNonEqualOp, OperationFunctor type, IQArray<Qubit>? ctrls)
        {
            long statement = this.QuantumProcessor.StartConditionalStatement(result1, result2);
            ExecuteConditionalStatementInternal(statement, onEqualOp, onNonEqualOp, type, ctrls);
            this.QuantumProcessor.EndConditionalStatement(statement);
        }


        public class QuantumProcessorApplyIfElse : Extensions.ApplyIfElseIntrinsic
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorApplyIfElse(QuantumProcessorDispatcher m) : base(m) { this.Simulator = m; }

            public override Func<(Result, ICallable, ICallable), QVoid> __Body__ => (q) =>
            {
                (Result measurementResult, ICallable onZero, ICallable onOne) = q;
                Simulator.ExecuteConditionalStatement(measurementResult, Result.Zero, onZero, onOne, OperationFunctor.Body, null);
                return QVoid.Instance;
            };
        }

        public class QuantumProcessorApplyIfElseA : Extensions.ApplyIfElseIntrinsicA
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorApplyIfElseA(QuantumProcessorDispatcher m) : base(m) { this.Simulator = m; }

            public override Func<(Result, IAdjointable, IAdjointable), QVoid> __Body__ => (q) =>
            {
                (Result measurementResult, ICallable onZero, ICallable onOne) = q;
                Simulator.ExecuteConditionalStatement(measurementResult, Result.Zero, onZero, onOne, OperationFunctor.Body, null);
                return QVoid.Instance;
            };

            public override Func<(Result, IAdjointable, IAdjointable), QVoid> __AdjointBody__ => (q) =>
            {
                (Result measurementResult, ICallable onZero, ICallable onOne) = q;
                Simulator.ExecuteConditionalStatement(measurementResult, Result.Zero, onZero, onOne, OperationFunctor.Adjoint, null);
                return QVoid.Instance;
            };
        }

        public class QuantumProcessorApplyIfElseC : Extensions.ApplyIfElseIntrinsicC
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorApplyIfElseC(QuantumProcessorDispatcher m) : base(m) { this.Simulator = m; }

            public override Func<(Result, IControllable, IControllable), QVoid> __Body__ => (q) =>
            {
                (Result measurementResult, ICallable onZero, ICallable onOne) = q;
                Simulator.ExecuteConditionalStatement(measurementResult, Result.Zero, onZero, onOne, OperationFunctor.Body, null);
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (Result, IControllable, IControllable)), QVoid> __ControlledBody__ => (q) =>
            {
                (IQArray<Qubit> ctrls, (Result measurementResult, ICallable onZero, ICallable onOne)) = q;
                if ((ctrls == null) || (ctrls.Count == 0))
                {
                    Simulator.ExecuteConditionalStatement(measurementResult, Result.Zero, onZero, onOne, OperationFunctor.Body, null);
                }
                else
                {
                    Simulator.ExecuteConditionalStatement(measurementResult, Result.Zero, onZero, onOne, OperationFunctor.Controlled, ctrls);
                }
                return QVoid.Instance;
            };
        }

        public class QuantumProcessorApplyIfElseCA : Extensions.ApplyIfElseIntrinsicCA
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorApplyIfElseCA(QuantumProcessorDispatcher m) : base(m) { this.Simulator = m; }

            public override Func<(Result, IUnitary, IUnitary), QVoid> __Body__ => (q) =>
            {
                (Result measurementResult, ICallable onZero, ICallable onOne) = q;
                Simulator.ExecuteConditionalStatement(measurementResult, Result.Zero, onZero, onOne, OperationFunctor.Body, null);
                return QVoid.Instance;
            };

            public override Func<(Result, IUnitary, IUnitary), QVoid> __AdjointBody__ => (q) =>
            {
                (Result measurementResult, ICallable onZero, ICallable onOne) = q;
                Simulator.ExecuteConditionalStatement(measurementResult, Result.Zero, onZero, onOne, OperationFunctor.Adjoint, null);
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (Result, IUnitary, IUnitary)), QVoid> __ControlledBody__ => (q) =>
            {
                (IQArray<Qubit> ctrls, (Result measurementResult, ICallable onZero, ICallable onOne)) = q;

                if ((ctrls == null) || (ctrls.Count == 0))
                {
                    Simulator.ExecuteConditionalStatement(measurementResult, Result.Zero, onZero, onOne, OperationFunctor.Body, null);
                }
                else
                {
                    Simulator.ExecuteConditionalStatement(measurementResult, Result.Zero, onZero, onOne, OperationFunctor.Controlled, ctrls);
                }
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (Result, IUnitary, IUnitary)), QVoid> __ControlledAdjointBody__ => (q) =>
            {
                (IQArray<Qubit> ctrls, (Result measurementResult, ICallable onZero, ICallable onOne)) = q;

                if ((ctrls == null) || (ctrls.Count == 0))
                {
                    Simulator.ExecuteConditionalStatement(measurementResult, Result.Zero, onZero, onOne, OperationFunctor.Adjoint, null);
                }
                else
                {
                    Simulator.ExecuteConditionalStatement(measurementResult, Result.Zero, onZero, onOne, OperationFunctor.ControlledAdjoint, ctrls);
                }
                return QVoid.Instance;
            };
        }



        public class QuantumProcessorApplyConditionally : Extensions.ApplyConditionallyIntrinsic
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorApplyConditionally(QuantumProcessorDispatcher m) : base(m) { this.Simulator = m; }

            public override Func<(IQArray<Result>, IQArray<Result>, ICallable, ICallable), QVoid> __Body__ => (q) =>
            {
                (IQArray<Result> measurementResults, IQArray<Result> resultsValues, ICallable onEqualOp, ICallable onNonEqualOp) = q;
                Simulator.ExecuteConditionalStatement(measurementResults, resultsValues, onEqualOp, onNonEqualOp, OperationFunctor.Body, null);
                return QVoid.Instance;
            };
        }

        public class QuantumProcessorApplyConditionallyA : Extensions.ApplyConditionallyIntrinsicA
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorApplyConditionallyA(QuantumProcessorDispatcher m) : base(m) { this.Simulator = m; }

            public override Func<(IQArray<Result>, IQArray<Result>, IAdjointable, IAdjointable), QVoid> __Body__ => (q) =>
            {
                (IQArray<Result> measurementResults, IQArray<Result> resultsValues, ICallable onEqualOp, ICallable onNonEqualOp) = q;
                Simulator.ExecuteConditionalStatement(measurementResults, resultsValues, onEqualOp, onNonEqualOp, OperationFunctor.Body, null);
                return QVoid.Instance;
            };

            public override Func<(IQArray<Result>, IQArray<Result>, IAdjointable, IAdjointable), QVoid> __AdjointBody__ => (q) =>
            {
                (IQArray<Result> measurementResults, IQArray<Result> resultsValues, ICallable onEqualOp, ICallable onNonEqualOp) = q;
                Simulator.ExecuteConditionalStatement(measurementResults, resultsValues, onEqualOp, onNonEqualOp, OperationFunctor.Adjoint, null);
                return QVoid.Instance;
            };
        }

        public class QuantumProcessorApplyConditionallyC : Extensions.ApplyConditionallyIntrinsicC
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorApplyConditionallyC(QuantumProcessorDispatcher m) : base(m) { this.Simulator = m; }

            public override Func<(IQArray<Result>, IQArray<Result>, IControllable, IControllable), QVoid> __Body__ => (q) =>
            {
                (IQArray<Result> measurementResults, IQArray<Result> resultsValues, ICallable onEqualOp, ICallable onNonEqualOp) = q;
                Simulator.ExecuteConditionalStatement(measurementResults, resultsValues, onEqualOp, onNonEqualOp, OperationFunctor.Body, null);
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (IQArray<Result>, IQArray<Result>, IControllable, IControllable)), QVoid> __ControlledBody__ => (q) =>
            {
                (IQArray<Qubit> ctrls, (IQArray<Result> measurementResults, IQArray<Result> resultsValues, ICallable onEqualOp, ICallable onNonEqualOp)) = q;

                if ((ctrls == null) || (ctrls.Count == 0))
                {
                    Simulator.ExecuteConditionalStatement(measurementResults, resultsValues, onEqualOp, onNonEqualOp, OperationFunctor.Body, null);
                }
                else
                {
                    Simulator.ExecuteConditionalStatement(measurementResults, resultsValues, onEqualOp, onNonEqualOp, OperationFunctor.Controlled, ctrls);
                }
                return QVoid.Instance;
            };
        }

        public class QuantumProcessorApplyConditionallyCA : Extensions.ApplyConditionallyIntrinsicCA
        {
            private QuantumProcessorDispatcher Simulator { get; }

            public QuantumProcessorApplyConditionallyCA(QuantumProcessorDispatcher m) : base(m) { this.Simulator = m; }

            public override Func<(IQArray<Result>, IQArray<Result>, IUnitary, IUnitary), QVoid> __Body__ => (q) =>
            {
                (IQArray<Result> measurementResults, IQArray<Result> resultsValues, ICallable onEqualOp, ICallable onNonEqualOp) = q;
                Simulator.ExecuteConditionalStatement(measurementResults, resultsValues, onEqualOp, onNonEqualOp, OperationFunctor.Body, null);
                return QVoid.Instance;
            };

            public override Func<(IQArray<Result>, IQArray<Result>, IUnitary, IUnitary), QVoid> __AdjointBody__ => (q) =>
            {
                (IQArray<Result> measurementResults, IQArray<Result> resultsValues, ICallable onEqualOp, ICallable onNonEqualOp) = q;
                Simulator.ExecuteConditionalStatement(measurementResults, resultsValues, onEqualOp, onNonEqualOp, OperationFunctor.Adjoint, null);
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (IQArray<Result>, IQArray<Result>, IUnitary, IUnitary)), QVoid> __ControlledBody__ => (q) =>
            {
                (IQArray<Qubit> ctrls, (IQArray<Result> measurementResults, IQArray<Result> resultsValues, ICallable onEqualOp, ICallable onNonEqualOp)) = q;

                if ((ctrls == null) || (ctrls.Count == 0))
                {
                    Simulator.ExecuteConditionalStatement(measurementResults, resultsValues, onEqualOp, onNonEqualOp, OperationFunctor.Body, null);
                }
                else
                {
                    Simulator.ExecuteConditionalStatement(measurementResults, resultsValues, onEqualOp, onNonEqualOp, OperationFunctor.Controlled, ctrls);
                }
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (IQArray<Result>, IQArray<Result>, IUnitary, IUnitary)), QVoid> __ControlledAdjointBody__ => (q) =>
            {
                (IQArray<Qubit> ctrls, (IQArray<Result> measurementResults, IQArray<Result> resultsValues, ICallable onEqualOp, ICallable onNonEqualOp)) = q;

                if ((ctrls == null) || (ctrls.Count == 0))
                {
                    Simulator.ExecuteConditionalStatement(measurementResults, resultsValues, onEqualOp, onNonEqualOp, OperationFunctor.Adjoint, null);
                }
                else
                {
                    Simulator.ExecuteConditionalStatement(measurementResults, resultsValues, onEqualOp, onNonEqualOp, OperationFunctor.ControlledAdjoint, ctrls);
                }
                return QVoid.Instance;
            };
        }

    }
}
