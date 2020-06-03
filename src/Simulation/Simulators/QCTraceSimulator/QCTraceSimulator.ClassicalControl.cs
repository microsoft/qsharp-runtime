// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.IO;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Implementation
{
    public partial class QCTraceSimulatorImpl
    {
        #region ApplyIfElse

        public class TracerApplyIfElse : Interface_ApplyIfElse
        {
            private QCTraceSimulatorImpl tracerCore { get; }

            public TracerApplyIfElse(QCTraceSimulatorImpl m) : base(m)
            {
                this.tracerCore = m;
            }

            public override Func<(Result, ICallable, ICallable), QVoid> Body => (q) =>
            {
                // ToDo
                return QVoid.Instance;
            };
        }

        public class TracerApplyIfElseA : Interface_ApplyIfElseA
        {
            private QCTraceSimulatorImpl tracerCore { get; }

            public TracerApplyIfElseA(QCTraceSimulatorImpl m) : base(m)
            {
                this.tracerCore = m;
            }

            public override Func<(Result, IAdjointable, IAdjointable), QVoid> Body => (q) =>
            {
                // ToDo
                return QVoid.Instance;
            };
        }

        public class TracerApplyIfElseC : Interface_ApplyIfElseC
        {
            private QCTraceSimulatorImpl tracerCore { get; }

            public TracerApplyIfElseC(QCTraceSimulatorImpl m) : base(m)
            {
                this.tracerCore = m;
            }

            public override Func<(IQArray<Qubit>, Result, IControllable, IControllable), QVoid> Body => (q) =>
            {
                // ToDo
                return QVoid.Instance;
            };
        }

        public class TracerApplyIfElseCA : Interface_ApplyIfElseCA
        {
            private QCTraceSimulatorImpl tracerCore { get; }

            public TracerApplyIfElseCA(QCTraceSimulatorImpl m) : base(m)
            {
                this.tracerCore = m;
            }

            public override Func<(IQArray<Qubit>, Result, IUnitary, IUnitary), QVoid> Body => (q) =>
            {
                // ToDo
                return QVoid.Instance;
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

            public override Func<(IQArray<Result>, IQArray<Result>, ICallable, ICallable), QVoid> Body => (q) =>
            {
                // ToDo
                return QVoid.Instance;
            };
        }

        public class TracerApplyConditionallyA : Interface_ApplyConditionallyA
        {
            private QCTraceSimulatorImpl tracerCore { get; }

            public TracerApplyConditionallyA(QCTraceSimulatorImpl m) : base(m)
            {
                this.tracerCore = m;
            }

            public override Func<(IQArray<Result>, IQArray<Result>, IAdjointable, IAdjointable), QVoid> Body => (q) =>
            {
                // ToDo
                return QVoid.Instance;
            };
        }

        public class TracerApplyConditionallyC : Interface_ApplyConditionallyC
        {
            private QCTraceSimulatorImpl tracerCore { get; }

            public TracerApplyConditionallyC(QCTraceSimulatorImpl m) : base(m)
            {
                this.tracerCore = m;
            }

            public override Func<(IQArray<Qubit>, IQArray<Result>, IQArray<Result>, IControllable, IControllable), QVoid> Body => (q) =>
            {
                // ToDo
                return QVoid.Instance;
            };
        }

        public class TracerApplyConditionallyCA : Interface_ApplyConditionallyCA
        {
            private QCTraceSimulatorImpl tracerCore { get; }

            public TracerApplyConditionallyCA(QCTraceSimulatorImpl m) : base(m)
            {
                this.tracerCore = m;
            }

            public override Func<(IQArray<Qubit>, IQArray<Result>, IQArray<Result>, IUnitary, IUnitary), QVoid> Body => (q) =>
            {
                // ToDo
                return QVoid.Instance;
            };
        }

        #endregion
    }
}
