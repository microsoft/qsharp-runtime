// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        #region Static Methods

        private static void RunClause(ICallable op, OperationFunctor type, IQArray<Qubit>? ctrls)
        {
            switch (type)
            {
                case OperationFunctor.Body: op.Apply(QVoid.Instance); break;
                case OperationFunctor.Adjoint: ((IAdjointable)op).Adjoint.Apply(QVoid.Instance); break;
                case OperationFunctor.Controlled: ((IControllable)op).Controlled.Apply(ctrls); break;
                case OperationFunctor.ControlledAdjoint: ((IUnitary)op).Controlled.Adjoint.Apply(ctrls); break;
            }
        }

        private static QVoid ExecuteConditionalStatement(Result measurementResult, ICallable onZero, ICallable onOne, OperationFunctor type, IQArray<Qubit>? ctrls)
        {
            if (measurementResult == Result.Zero)
            {
                RunClause(onZero, type, ctrls);
            }
            else
            {
                RunClause(onOne, type, ctrls);
            }
            return QVoid.Instance;
        }

        private static QVoid ExecuteConditionalStatement(IQArray<Result> measurementResults, IQArray<Result> comparisonResults, ICallable onEqualOp, ICallable onNonEqualOp, OperationFunctor type, IQArray<Qubit>? ctrls)
        {
            if (AreEqual(measurementResults, comparisonResults))
            {
                RunClause(onEqualOp, type, ctrls);
            }
            else
            {
                RunClause(onNonEqualOp, type, ctrls);
            }
            return QVoid.Instance;
        }

        private static bool AreEqual(IQArray<Result> measurementResults, IQArray<Result> comparisonResults)
        {
            if (measurementResults == null || comparisonResults == null || measurementResults.Count != comparisonResults.Count)
            {
                // Defaulting to true is based on the QuantumProcessorBase.cs behavior, under StartConditionalStatement.
                return true;
            }

            for (int i = 0; i < measurementResults.Count; i++)
            {
                if (measurementResults[i] != comparisonResults[i])
                {
                    return false;
                }
            }

            return true;
        }

        private static OperationFunctor AdjustForNoControls(OperationFunctor type, IQArray<Qubit>? ctrls)
        {
            if (ctrls == null || ctrls.Count == 0)
            {
                type = type switch
                {
                    OperationFunctor.Controlled => OperationFunctor.Body,
                    OperationFunctor.ControlledAdjoint => OperationFunctor.Adjoint,
                    _ => type,
                };
            }

            return type;
        }

        #endregion

        #region ApplyIfElse

        public class QSimApplyIfElse : Quantum.Simulation.QuantumProcessor.Extensions.ApplyIfElseIntrinsic
        {
            private QuantumSimulator Simulator { get; }

            public QSimApplyIfElse(QuantumSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<(Result, ICallable, ICallable), QVoid> Body => (q) =>
            {
                (Result measurementResult, ICallable onZero, ICallable onOne) = q;
                return ExecuteConditionalStatement(measurementResult, onZero, onOne, OperationFunctor.Body, null);
            };
        }

        public class QSimApplyIfElseA : Quantum.Simulation.QuantumProcessor.Extensions.ApplyIfElseIntrinsicA
        {
            private QuantumSimulator Simulator { get; }

            public QSimApplyIfElseA(QuantumSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<(Result, IAdjointable, IAdjointable), QVoid> Body => (q) =>
            {
                (Result measurementResult, ICallable onZero, ICallable onOne) = q;
                return ExecuteConditionalStatement(measurementResult, onZero, onOne, OperationFunctor.Body, null);
            };

            public override Func<(Result, IAdjointable, IAdjointable), QVoid> AdjointBody => (q) =>
            {
                (Result measurementResult, ICallable onZero, ICallable onOne) = q;
                return ExecuteConditionalStatement(measurementResult, onZero, onOne, OperationFunctor.Adjoint, null);
            };
        }

        public class QSimApplyIfElseC : Quantum.Simulation.QuantumProcessor.Extensions.ApplyIfElseIntrinsicC
        {
            private QuantumSimulator Simulator { get; }

            public QSimApplyIfElseC(QuantumSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<(Result, IControllable, IControllable), QVoid> Body => (q) =>
            {
                (Result measurementResult, ICallable onZero, ICallable onOne) = q;
                return ExecuteConditionalStatement(measurementResult, onZero, onOne, OperationFunctor.Body, null);
            };

            public override Func<(IQArray<Qubit>, (Result, IControllable, IControllable)), QVoid> ControlledBody => (q) =>
            {
                (IQArray<Qubit> ctrls, (Result measurementResult, ICallable onZero, ICallable onOne)) = q;
                OperationFunctor type = AdjustForNoControls(OperationFunctor.Controlled, ctrls);
                return ExecuteConditionalStatement(measurementResult, onZero, onOne, type, ctrls);
            };
        }

        public class QSimApplyIfElseCA : Quantum.Simulation.QuantumProcessor.Extensions.ApplyIfElseIntrinsicCA
        {
            private QuantumSimulator Simulator { get; }

            public QSimApplyIfElseCA(QuantumSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<(Result, IUnitary, IUnitary), QVoid> Body => (q) =>
            {
                (Result measurementResult, ICallable onZero, ICallable onOne) = q;
                return ExecuteConditionalStatement(measurementResult, onZero, onOne, OperationFunctor.Body, null);
            };

            public override Func<(Result, IUnitary, IUnitary), QVoid> AdjointBody => (q) =>
            {
                (Result measurementResult, ICallable onZero, ICallable onOne) = q;
                return ExecuteConditionalStatement(measurementResult, onZero, onOne, OperationFunctor.Adjoint, null);
            };

            public override Func<(IQArray<Qubit>, (Result, IUnitary, IUnitary)), QVoid> ControlledBody => (q) =>
            {
                (IQArray<Qubit> ctrls, (Result measurementResult, ICallable onZero, ICallable onOne)) = q;
                OperationFunctor type = AdjustForNoControls(OperationFunctor.Controlled, ctrls);
                return ExecuteConditionalStatement(measurementResult, onZero, onOne, type, ctrls);
            };

            public override Func<(IQArray<Qubit>, (Result, IUnitary, IUnitary)), QVoid> ControlledAdjointBody => (q) =>
            {
                (IQArray<Qubit> ctrls, (Result measurementResult, ICallable onZero, ICallable onOne)) = q;
                OperationFunctor type = AdjustForNoControls(OperationFunctor.ControlledAdjoint, ctrls);
                return ExecuteConditionalStatement(measurementResult, onZero, onOne, type, ctrls);
            };
        }

        #endregion

        #region ApplyConditionally

        public class QSimApplyConditionally : Quantum.Simulation.QuantumProcessor.Extensions.ApplyConditionallyIntrinsic
        {
            private QuantumSimulator Simulator { get; }

            public QSimApplyConditionally(QuantumSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<(IQArray<Result>, IQArray<Result>, ICallable, ICallable), QVoid> Body => (q) =>
            {
                (IQArray<Result> measurementResults, IQArray<Result> comparisonResults, ICallable onEqualOp, ICallable onNonEqualOp) = q;
                return ExecuteConditionalStatement(measurementResults, comparisonResults, onEqualOp, onNonEqualOp, OperationFunctor.Body, null);
            };
        }

        public class QSimApplyConditionallyA : Quantum.Simulation.QuantumProcessor.Extensions.ApplyConditionallyIntrinsicA
        {
            private QuantumSimulator Simulator { get; }

            public QSimApplyConditionallyA(QuantumSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<(IQArray<Result>, IQArray<Result>, IAdjointable, IAdjointable), QVoid> Body => (q) =>
            {
                (IQArray<Result> measurementResults, IQArray<Result> comparisonResults, ICallable onEqualOp, ICallable onNonEqualOp) = q;
                return ExecuteConditionalStatement(measurementResults, comparisonResults, onEqualOp, onNonEqualOp, OperationFunctor.Body, null);
            };

            public override Func<(IQArray<Result>, IQArray<Result>, IAdjointable, IAdjointable), QVoid> AdjointBody => (q) =>
            {
                (IQArray<Result> measurementResults, IQArray<Result> comparisonResults, ICallable onEqualOp, ICallable onNonEqualOp) = q;
                return ExecuteConditionalStatement(measurementResults, comparisonResults, onEqualOp, onNonEqualOp, OperationFunctor.Adjoint, null);
            };
        }

        public class QSimApplyConditionallyC : Quantum.Simulation.QuantumProcessor.Extensions.ApplyConditionallyIntrinsicC
        {
            private QuantumSimulator Simulator { get; }

            public QSimApplyConditionallyC(QuantumSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<(IQArray<Result>, IQArray<Result>, IControllable, IControllable), QVoid> Body => (q) =>
            {
                (IQArray<Result> measurementResults, IQArray<Result> comparisonResults, ICallable onEqualOp, ICallable onNonEqualOp) = q;
                return ExecuteConditionalStatement(measurementResults, comparisonResults, onEqualOp, onNonEqualOp, OperationFunctor.Body, null);
            };

            public override Func<(IQArray<Qubit>, (IQArray<Result>, IQArray<Result>, IControllable, IControllable)), QVoid> ControlledBody => (q) =>
            {
                (IQArray<Qubit> ctrls, (IQArray<Result> measurementResults, IQArray<Result> comparisonResults, ICallable onEqualOp, ICallable onNonEqualOp)) = q;
                OperationFunctor type = AdjustForNoControls(OperationFunctor.Controlled, ctrls);
                return ExecuteConditionalStatement(measurementResults, comparisonResults, onEqualOp, onNonEqualOp, type, ctrls);
            };
        }

        public class QSimApplyConditionallyCA : Quantum.Simulation.QuantumProcessor.Extensions.ApplyConditionallyIntrinsicCA
        {
            private QuantumSimulator Simulator { get; }

            public QSimApplyConditionallyCA(QuantumSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<(IQArray<Result>, IQArray<Result>, IUnitary, IUnitary), QVoid> Body => (q) =>
            {
                (IQArray<Result> measurementResults, IQArray<Result> comparisonResults, ICallable onEqualOp, ICallable onNonEqualOp) = q;
                return ExecuteConditionalStatement(measurementResults, comparisonResults, onEqualOp, onNonEqualOp, OperationFunctor.Body, null);
            };

            public override Func<(IQArray<Result>, IQArray<Result>, IUnitary, IUnitary), QVoid> AdjointBody => (q) =>
            {
                (IQArray<Result> measurementResults, IQArray<Result> comparisonResults, ICallable onEqualOp, ICallable onNonEqualOp) = q;
                return ExecuteConditionalStatement(measurementResults, comparisonResults, onEqualOp, onNonEqualOp, OperationFunctor.Adjoint, null);
            };

            public override Func<(IQArray<Qubit>, (IQArray<Result>, IQArray<Result>, IUnitary, IUnitary)), QVoid> ControlledBody => (q) =>
            {
                (IQArray<Qubit> ctrls, (IQArray<Result> measurementResults, IQArray<Result> comparisonResults, ICallable onEqualOp, ICallable onNonEqualOp)) = q;
                OperationFunctor type = AdjustForNoControls(OperationFunctor.Controlled, ctrls);
                return ExecuteConditionalStatement(measurementResults, comparisonResults, onEqualOp, onNonEqualOp, type, ctrls);
            };

            public override Func<(IQArray<Qubit>, (IQArray<Result>, IQArray<Result>, IUnitary, IUnitary)), QVoid> ControlledAdjointBody => (q) =>
            {
                (IQArray<Qubit> ctrls, (IQArray<Result> measurementResults, IQArray<Result> comparisonResults, ICallable onEqualOp, ICallable onNonEqualOp)) = q;
                OperationFunctor type = AdjustForNoControls(OperationFunctor.ControlledAdjoint, ctrls);
                return ExecuteConditionalStatement(measurementResults, comparisonResults, onEqualOp, onNonEqualOp, type, ctrls);
            };
        }

        #endregion
    }
}
