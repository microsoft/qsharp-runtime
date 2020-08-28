// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators.Tests
{
    static partial class OperationsTestHelper
    {
        public static TraceImpl<T> GetTracer<T>(this SimulatorBase s)
        {
            return s.Get<GenericCallable>(typeof(Tests.Circuits.Generics.Trace<>)).FindCallable(typeof(T), typeof(QVoid)) as TraceImpl<T>;
        }


        public class TracerImpl : Tests.Circuits.ClosedType.Trace
        {
            public TracerImpl(IOperationFactory m) : base(m)
            {
                this.Log = new Log<string>();
            }

            public override Func<string, QVoid> Body => (tag) => this.Log.Record(OperationFunctor.Body, tag);
            public override Func<string, QVoid> AdjointBody => (tag) => this.Log.Record(OperationFunctor.Adjoint, tag);
            public override Func<(IQArray<Qubit>, string), QVoid> ControlledBody => (args) => this.Log.Record(OperationFunctor.Controlled, args.Item2);
            public override Func<(IQArray<Qubit>, string), QVoid> ControlledAdjointBody => (args) => this.Log.Record(OperationFunctor.ControlledAdjoint, args.Item2);

            public Log<string> Log { get; }
        }

        public class TraceImpl<T> : Tests.Circuits.Generics.Trace<T>
        {
            public TraceImpl(IOperationFactory m) : base(m)
            {
                this.Log = new Log<T>();
            }

            public override Func<T, QVoid> Body => (tag) => this.Log.Record(OperationFunctor.Body, tag);
            public override Func<T, QVoid> AdjointBody => (tag) => this.Log.Record(OperationFunctor.Adjoint, tag);
            public override Func<(IQArray<Qubit>, T), QVoid> ControlledBody => (args) => this.Log.Record(OperationFunctor.Controlled, args.Item2);
            public override Func<(IQArray<Qubit>, T), QVoid> ControlledAdjointBody => (args) => this.Log.Record(OperationFunctor.ControlledAdjoint, args.Item2);

            public int GetNumberOfCalls(OperationFunctor functor, T tag) => this.Log.GetNumberOfCalls(functor, tag);

            public Log<T> Log { get; }
        }

    }
}