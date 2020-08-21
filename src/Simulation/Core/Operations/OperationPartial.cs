// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#nullable enable

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;

namespace Microsoft.Quantum.Simulation.Core
{
    /// <summary>
    ///     This class saves the operation resulting from doing a Partial Application
    ///     on a closed type operation.
    ///     
    ///     This class is typically initialized passing a partialTuple from which
    ///     we create a Mapper that maps the partial arguments to the original type.
    ///     Optionally it can receive a Mapper to do the same.
    /// </summary>
    [DebuggerTypeProxy(typeof(OperationPartial<,,>.DebuggerProxy))]
    public class OperationPartial<P, I, O> : Operation<P, O>, IUnitary<P>, IOperationWrapper
    {
        private Lazy<Qubit[]> __qubits = null;

        public class In : IApplyData
        {
            private Lazy<IApplyData> __data = null;

            public In(Operation<I, O> op, Func<P, I> mapper, P data)
            {
                this.__data = new Lazy<IApplyData>(() => op?.__dataIn(mapper(data)));
            }

            public object Value => __data.Value.Value;

            public IEnumerable<Qubit> Qubits => __data.Value.Qubits;
        }


        public OperationPartial(Operation<I, O> op, Func<P, I> mapper) : base(op.Factory)
        {
            Debug.Assert(op != null);
            Debug.Assert(mapper != null);

            this.BaseOp = op;
            this.Mapper = mapper;
            this.__qubits = new Lazy<Qubit[]>(() => op?.__dataIn(mapper(default(P)))?.Qubits?.ToArray());
        }

        public OperationPartial(Operation<I, O> op, object partialTuple) : base(op.Factory)
        {
            Debug.Assert(op != null);
            Debug.Assert(partialTuple != null);

            this.BaseOp = op;
            this.Mapper = PartialMapper.Create<P, I>(partialTuple);
            this.__qubits = new Lazy<Qubit[]>(() => op?.__dataIn(this.Mapper(default(P)))?.Qubits?.ToArray());
        }

        public override void Init() { }

        public Operation<I, O> BaseOp { get; }
        ICallable IOperationWrapper.BaseOperation => BaseOp;

        public Func<P, I> Mapper { get; }

        string ICallable.Name => ((ICallable)this.BaseOp).Name;
        string ICallable.FullName => ((ICallable)this.BaseOp).FullName;

        OperationFunctor ICallable.Variant => ((ICallable)this.BaseOp).Variant;

        public override IApplyData __dataIn(P data) => new In(this.BaseOp, this.Mapper, data);

        public override IApplyData __dataOut(O data) => this.BaseOp.__dataOut(data);

        public override Func<P, O> Body => (a) =>
        {
            var args = this.Mapper(a);
            return this.BaseOp.Body.Invoke(args);
        };

        public override Func<P, QVoid> AdjointBody => (a) =>
        {
            Debug.Assert(typeof(O) == typeof(QVoid));
            var op = this.BaseOp;

            var args = this.Mapper(a);
            return op.AdjointBody.Invoke(args);
        };

        public override Func<(IQArray<Qubit>, P), QVoid> ControlledBody => (a) =>
        {
            Debug.Assert(typeof(O) == typeof(QVoid));
            var op = this.BaseOp;
            var (ctrl, ps) = a;
            return op.ControlledBody.Invoke((ctrl, this.Mapper(ps)));
        };

        public override Func<(IQArray<Qubit>, P), QVoid> ControlledAdjointBody => (a) =>
        {
            Debug.Assert(typeof(O) == typeof(QVoid));
            var op = this.BaseOp;
            var (ctrl, ps) = a;
            return op.ControlledAdjointBody.Invoke((ctrl, this.Mapper(ps)));
        };

        IEnumerable<Qubit> IApplyData.Qubits => __qubits.Value;

        QVoid ICallable<P, QVoid>.Apply(P args)
        {
            base.Apply(args);
            return QVoid.Instance;
        }
        ICallable<P1, QVoid> ICallable<P, QVoid>.Partial<P1>(Func<P1, P> mapper)
        {
            return base.Partial(mapper);
        }

        IAdjointable IAdjointable.Adjoint => base.Adjoint;
        IAdjointable IAdjointable.Partial(object partialTuple) => base.Partial<IAdjointable>(partialTuple);


        IControllable IControllable.Controlled => base.Controlled;
        IControllable IControllable.Partial(object partialTuple) => base.Partial<IControllable>(partialTuple);


        IUnitary IUnitary.Adjoint => base.Adjoint;
        IUnitary IUnitary.Controlled => base.Controlled;
        IUnitary IUnitary.Partial(object partialTuple) => base.Partial<IUnitary>(partialTuple);


        IAdjointable<P> IAdjointable<P>.Adjoint => base.Adjoint;
        IAdjointable<P1> IAdjointable<P>.Partial<P1>(Func<P1, P> mapper) => new OperationPartial<P1, P, O>(this, mapper);


        IControllable<(IQArray<Qubit>, P)> IControllable<P>.Controlled => base.Controlled;
        IControllable<P1> IControllable<P>.Partial<P1>(Func<P1, P> mapper) => new OperationPartial<P1, P, O>(this, mapper);


        IUnitary<P> IUnitary<P>.Adjoint => base.Adjoint;
        IUnitary<(IQArray<Qubit>, P)> IUnitary<P>.Controlled => base.Controlled;

        IUnitary<P1> IUnitary<P>.Partial<P1>(Func<P1, P> mapper) => new OperationPartial<P1, P, O>(this, mapper);

        /// <inheritdoc/>
        public override RuntimeMetadata? GetRuntimeMetadata(IApplyData args) =>
            this.BaseOp.GetRuntimeMetadata(args);

        public override string ToString() => $"{this.BaseOp}{{_}}";
        public override string __qsharpType()
        {
            var baseSignature = this.GetType().QSharpType();
            var variants = this.BaseOp.GetType().OperationVariants(this.BaseOp);
            return $"{baseSignature}{variants}";
        }

        new internal class DebuggerProxy : Operation<P, O>.DebuggerProxy
        {
            private OperationPartial<P, I, O> _op;

            public DebuggerProxy(OperationPartial<P, I, O> op) : base(op)
            {
                this._op = op;
            }

            public Operation<I, O> Base => _op.BaseOp;
        }
    }
}