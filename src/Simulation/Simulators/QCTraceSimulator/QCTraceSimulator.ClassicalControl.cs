// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.IO;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Implementation
{
    public partial class QCTraceSimulatorImpl
    {
        #region Static Methods

        /// <summary>
        /// Runs the given functor of the given operation with the given control qubits.
        /// </summary>
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

        /// <summary>
        /// This is a wrapper for an if-statement that will run either onZero if the
        /// given measurement result is Zero, or onOne otherwise.
        /// </summary>
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

        /// <summary>
        /// This is a wrapper for an if-statement that will run either onEqualOp if the
        /// given measurement result are pairwise-equal to the given comparison results,
        /// or onNonEqualOp otherwise. Pairwise-equality between the qubit arrays is
        /// determined by the AreEqual static method.
        /// </summary>
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

        /// <summary>
        /// Determines if the given measurement results are pairwise-equal with the given comparison results.
        /// Pairwise-equality is where each element of the first array is equal to its corresponding element
        /// in the second array. For example:
        /// measurementResults[0] == comparisonResults[0] AND measurementResults[1] == comparisonResults[1] AND ...
        /// All pairwise comparisons must result in equality for the two arrays to be pairwise-equal.
        ///
        /// If either array is null or their lengths are unequal, this defaults to returning 'true'. This
        /// is done to be consistent with the logic found in QuantumProcessorBase.cs under the
        /// StartConditionalStatement method.
        /// </summary>
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

        /// <summary>
        /// If a controlled functor is being used with no controls, this will change it
        /// to the appropriate non-controlled functor. Otherwise, the given functor is returned.
        /// </summary>
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

        public class TracerApplyIfElse : Interface_ApplyIfElse
        {
            private QCTraceSimulatorImpl tracerCore { get; }

            public TracerApplyIfElse(QCTraceSimulatorImpl m) : base(m)
            {
                this.tracerCore = m;
            }

            public override Func<(Result, ICallable, ICallable), QVoid> __Body__ => (q) =>
            {
                (Result measurementResult, ICallable onZero, ICallable onOne) = q;
                return ExecuteConditionalStatement(measurementResult, onZero, onOne, OperationFunctor.Body, null);
            };
        }

        public class TracerApplyIfElseA : Interface_ApplyIfElseA
        {
            private QCTraceSimulatorImpl tracerCore { get; }

            public TracerApplyIfElseA(QCTraceSimulatorImpl m) : base(m)
            {
                this.tracerCore = m;
            }

            public override Func<(Result, IAdjointable, IAdjointable), QVoid> __Body__ => (q) =>
            {
                (Result measurementResult, ICallable onZero, ICallable onOne) = q;
                return ExecuteConditionalStatement(measurementResult, onZero, onOne, OperationFunctor.Body, null);
            };

            public override Func<(Result, IAdjointable, IAdjointable), QVoid> __AdjointBody__ => (q) =>
            {
                (Result measurementResult, ICallable onZero, ICallable onOne) = q;
                return ExecuteConditionalStatement(measurementResult, onZero, onOne, OperationFunctor.Adjoint, null);
            };
        }

        public class TracerApplyIfElseC : Interface_ApplyIfElseC
        {
            private QCTraceSimulatorImpl tracerCore { get; }

            public TracerApplyIfElseC(QCTraceSimulatorImpl m) : base(m)
            {
                this.tracerCore = m;
            }

            public override Func<(Result, IControllable, IControllable), QVoid> __Body__ => (q) =>
            {
                (Result measurementResult, ICallable onZero, ICallable onOne) = q;
                return ExecuteConditionalStatement(measurementResult, onZero, onOne, OperationFunctor.Body, null);
            };

            public override Func<(IQArray<Qubit>, (Result, IControllable, IControllable)), QVoid> __ControlledBody__ => (q) =>
            {
                (IQArray<Qubit> ctrls, (Result measurementResult, ICallable onZero, ICallable onOne)) = q;
                OperationFunctor type = AdjustForNoControls(OperationFunctor.Controlled, ctrls);
                return ExecuteConditionalStatement(measurementResult, onZero, onOne, type, ctrls);
            };
        }

        public class TracerApplyIfElseCA : Interface_ApplyIfElseCA
        {
            private QCTraceSimulatorImpl tracerCore { get; }

            public TracerApplyIfElseCA(QCTraceSimulatorImpl m) : base(m)
            {
                this.tracerCore = m;
            }

            public override Func<(Result, IUnitary, IUnitary), QVoid> __Body__ => (q) =>
            {
                (Result measurementResult, ICallable onZero, ICallable onOne) = q;
                return ExecuteConditionalStatement(measurementResult, onZero, onOne, OperationFunctor.Body, null);
            };

            public override Func<(Result, IUnitary, IUnitary), QVoid> __AdjointBody__ => (q) =>
            {
                (Result measurementResult, ICallable onZero, ICallable onOne) = q;
                return ExecuteConditionalStatement(measurementResult, onZero, onOne, OperationFunctor.Adjoint, null);
            };

            public override Func<(IQArray<Qubit>, (Result, IUnitary, IUnitary)), QVoid> __ControlledBody__ => (q) =>
            {
                (IQArray<Qubit> ctrls, (Result measurementResult, ICallable onZero, ICallable onOne)) = q;
                OperationFunctor type = AdjustForNoControls(OperationFunctor.Controlled, ctrls);
                return ExecuteConditionalStatement(measurementResult, onZero, onOne, type, ctrls);
            };

            public override Func<(IQArray<Qubit>, (Result, IUnitary, IUnitary)), QVoid> __ControlledAdjointBody__ => (q) =>
            {
                (IQArray<Qubit> ctrls, (Result measurementResult, ICallable onZero, ICallable onOne)) = q;
                OperationFunctor type = AdjustForNoControls(OperationFunctor.ControlledAdjoint, ctrls);
                return ExecuteConditionalStatement(measurementResult, onZero, onOne, type, ctrls);
            };
        }

        #endregion

        #region ApplyConditionally

        public class TracerApplyConditionally : Interface_ApplyConditionally
        {
            private QCTraceSimulatorImpl tracerCore { get; }

            public TracerApplyConditionally(QCTraceSimulatorImpl m) : base(m)
            {
                this.tracerCore = m;
            }

            public override Func<(IQArray<Result>, IQArray<Result>, ICallable, ICallable), QVoid> __Body__ => (q) =>
            {
                (IQArray<Result> measurementResults, IQArray<Result> comparisonResults, ICallable onEqualOp, ICallable onNonEqualOp) = q;
                return ExecuteConditionalStatement(measurementResults, comparisonResults, onEqualOp, onNonEqualOp, OperationFunctor.Body, null);
            };
        }

        public class TracerApplyConditionallyA : Interface_ApplyConditionallyA
        {
            private QCTraceSimulatorImpl tracerCore { get; }

            public TracerApplyConditionallyA(QCTraceSimulatorImpl m) : base(m)
            {
                this.tracerCore = m;
            }

            public override Func<(IQArray<Result>, IQArray<Result>, IAdjointable, IAdjointable), QVoid> __Body__ => (q) =>
            {
                (IQArray<Result> measurementResults, IQArray<Result> comparisonResults, ICallable onEqualOp, ICallable onNonEqualOp) = q;
                return ExecuteConditionalStatement(measurementResults, comparisonResults, onEqualOp, onNonEqualOp, OperationFunctor.Body, null);
            };

            public override Func<(IQArray<Result>, IQArray<Result>, IAdjointable, IAdjointable), QVoid> __AdjointBody__ => (q) =>
            {
                (IQArray<Result> measurementResults, IQArray<Result> comparisonResults, ICallable onEqualOp, ICallable onNonEqualOp) = q;
                return ExecuteConditionalStatement(measurementResults, comparisonResults, onEqualOp, onNonEqualOp, OperationFunctor.Adjoint, null);
            };
        }

        public class TracerApplyConditionallyC : Interface_ApplyConditionallyC
        {
            private QCTraceSimulatorImpl tracerCore { get; }

            public TracerApplyConditionallyC(QCTraceSimulatorImpl m) : base(m)
            {
                this.tracerCore = m;
            }

            public override Func<(IQArray<Result>, IQArray<Result>, IControllable, IControllable), QVoid> __Body__ => (q) =>
            {
                (IQArray<Result> measurementResults, IQArray<Result> comparisonResults, ICallable onEqualOp, ICallable onNonEqualOp) = q;
                return ExecuteConditionalStatement(measurementResults, comparisonResults, onEqualOp, onNonEqualOp, OperationFunctor.Body, null);
            };

            public override Func<(IQArray<Qubit>, (IQArray<Result>, IQArray<Result>, IControllable, IControllable)), QVoid> __ControlledBody__ => (q) =>
            {
                (IQArray<Qubit> ctrls, (IQArray<Result> measurementResults, IQArray<Result> comparisonResults, ICallable onEqualOp, ICallable onNonEqualOp)) = q;
                OperationFunctor type = AdjustForNoControls(OperationFunctor.Controlled, ctrls);
                return ExecuteConditionalStatement(measurementResults, comparisonResults, onEqualOp, onNonEqualOp, type, ctrls);
            };
        }

        public class TracerApplyConditionallyCA : Interface_ApplyConditionallyCA
        {
            private QCTraceSimulatorImpl tracerCore { get; }

            public TracerApplyConditionallyCA(QCTraceSimulatorImpl m) : base(m)
            {
                this.tracerCore = m;
            }

            public override Func<(IQArray<Result>, IQArray<Result>, IUnitary, IUnitary), QVoid> __Body__ => (q) =>
            {
                (IQArray<Result> measurementResults, IQArray<Result> comparisonResults, ICallable onEqualOp, ICallable onNonEqualOp) = q;
                return ExecuteConditionalStatement(measurementResults, comparisonResults, onEqualOp, onNonEqualOp, OperationFunctor.Body, null);
            };

            public override Func<(IQArray<Result>, IQArray<Result>, IUnitary, IUnitary), QVoid> __AdjointBody__ => (q) =>
            {
                (IQArray<Result> measurementResults, IQArray<Result> comparisonResults, ICallable onEqualOp, ICallable onNonEqualOp) = q;
                return ExecuteConditionalStatement(measurementResults, comparisonResults, onEqualOp, onNonEqualOp, OperationFunctor.Adjoint, null);
            };

            public override Func<(IQArray<Qubit>, (IQArray<Result>, IQArray<Result>, IUnitary, IUnitary)), QVoid> __ControlledBody__ => (q) =>
            {
                (IQArray<Qubit> ctrls, (IQArray<Result> measurementResults, IQArray<Result> comparisonResults, ICallable onEqualOp, ICallable onNonEqualOp)) = q;
                OperationFunctor type = AdjustForNoControls(OperationFunctor.Controlled, ctrls);
                return ExecuteConditionalStatement(measurementResults, comparisonResults, onEqualOp, onNonEqualOp, type, ctrls);
            };

            public override Func<(IQArray<Qubit>, (IQArray<Result>, IQArray<Result>, IUnitary, IUnitary)), QVoid> __ControlledAdjointBody__ => (q) =>
            {
                (IQArray<Qubit> ctrls, (IQArray<Result> measurementResults, IQArray<Result> comparisonResults, ICallable onEqualOp, ICallable onNonEqualOp)) = q;
                OperationFunctor type = AdjustForNoControls(OperationFunctor.ControlledAdjoint, ctrls);
                return ExecuteConditionalStatement(measurementResults, comparisonResults, onEqualOp, onNonEqualOp, type, ctrls);
            };
        }

        #endregion
    }
}
