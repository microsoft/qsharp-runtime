// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Diagnostics;

namespace Microsoft.Quantum.Simulation.Core
{
    /// <summary>
    ///     This class saves the operation resulting from doing a Partial Application
    ///     on a q# function.
    /// </summary>
    [DebuggerTypeProxy(typeof(FunctionPartial<,,>.DebuggerProxy))]
    public class FunctionPartial<P, I, O> : Function<P, O>, ICallable<P, O>
    {

        public FunctionPartial(Function<I, O> op, Func<P, I> mapper) : base(op.Factory)
        {
            Debug.Assert(op != null);
            Debug.Assert(mapper != null);

            this.BaseOp = op;
            this.Mapper = mapper;
        }

        public FunctionPartial(Function<I, O> op, object partialTuple) : base(op.Factory)
        {
            Debug.Assert(op != null);
            Debug.Assert(partialTuple != null);

            this.BaseOp = op;
            this.Mapper = PartialMapper.Create<P, I>(partialTuple);
        }

        public override void Init() { }

        public ICallable<I, O> BaseOp { get; }

        public Func<P, I> Mapper { get; }

        string ICallable.Name => ((ICallable)this.BaseOp).Name;
        string ICallable.FullName => ((ICallable)this.BaseOp).FullName;

        OperationFunctor ICallable.Variant => ((ICallable)this.BaseOp).Variant;

        public override Func<P, O> Body => (a) =>
        {
            var args = this.Mapper(a);
            return this.BaseOp.Apply(args);
        };
        
        O ICallable<P, O>.Apply(P args)
        {
            return base.Apply(args);
        }

        ICallable<P1, O> ICallable<P, O>.Partial<P1>(Func<P1, P> mapper)
        {
            return base.Partial(mapper);
        }

        public override string ToString() => $"{this.BaseOp}{{_}}";
        public override string __qsharpType()
        {
            var baseSignature = this.GetType().QSharpType();
            var variants = this.BaseOp.GetType().OperationVariants(this.BaseOp);
            return $"{baseSignature}{variants}";
        }

        new internal class DebuggerProxy : Function<P,O>.DebuggerProxy
        {
            private FunctionPartial<P, I, O> _op;

            public DebuggerProxy(FunctionPartial<P, I, O> op) : base(op)
            {
                this._op = op;
            }

            public ICallable<I, O> Base => _op.BaseOp;
        }
    }
}