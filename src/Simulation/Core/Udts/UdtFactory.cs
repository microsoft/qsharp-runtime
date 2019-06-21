// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Diagnostics;

namespace Microsoft.Quantum.Simulation.Core
{
    public class UDTFactory<B,U> : AbstractCallable, ICallable<B, U>
    {
        public UDTFactory(IOperationFactory m) : base(m)
        { }

        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        string ICallable.Name => ((ICallable)this).FullName;
        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        string ICallable.FullName => throw new NotImplementedException();
        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        OperationFunctor ICallable.Variant => OperationFunctor.Body;

        public object Value => null;
        public IEnumerable<Qubit> Qubits => null;

        public U Apply(B a) => Apply<U>(a);

        public QVoid Apply(object args)
        {
            Debug.Fail("Calling void Apply on an operation that doesn't return QVoid");
            return QVoid.Instance;
        }

        public O Apply<O>(object args) =>
            (O)Activator.CreateInstance(typeof(U), PartialMapper.CastTuple(typeof(B), args));

        public UDTPartial<P1, B, U> Partial<P1>(Func<P1, B> mapper) =>
            new UDTPartial<P1, B, U>(mapper);

        ICallable<P1, U> ICallable<B, U>.Partial<P1>(Func<P1, B> mapper) => this.Partial(mapper);

        public T Partial<T>(object partialInfo)
        {
            var tupleType = Operation<B, U>.FindPartialType(typeof(B), partialInfo);
            var partialType = typeof(UDTPartial<,,>).MakeGenericType(tupleType, typeof(B), typeof(U));
            return (T)Activator.CreateInstance(partialType, new object[] { this, partialInfo });
        }

        public ICallable Partial(object partialTuple) => this.Partial<ICallable>(partialTuple);

        public override void Init()
        { }
    }
}