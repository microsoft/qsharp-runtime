// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#nullable enable

using System;
using System.Collections.Generic;
using System.Diagnostics;

namespace Microsoft.Quantum.Simulation.Core
{
    /// <summary>
    ///     Represents an operation that has an Adjoint.
    /// </summary>
    public interface IAdjointable<I> : ICallable<I, QVoid>, IAdjointable
    {
        new IAdjointable<I> Adjoint { get; }

        new IAdjointable<P> Partial<P>(Func<P, I> mapper);
    }

    /// <summary>
    ///     Base class for Operations that have an Adjoint. Both the Body and AdjointBody methods
    ///     need to be implemented.
    /// </summary>
    public abstract class Adjointable<I> : Operation<I, QVoid>, IAdjointable<I>
    {
        public Adjointable(IOperationFactory m) : base(m)
        {
        }
        
        IAdjointable IAdjointable.Adjoint => base.Adjoint;
        IAdjointable IAdjointable.Partial(object partialTuple) => base.Partial<IAdjointable>(partialTuple);


        IAdjointable<I> IAdjointable<I>.Adjoint => base.Adjoint;
        IAdjointable<P> IAdjointable<I>.Partial<P>(Func<P, I> mapper) => new OperationPartial<P, I, QVoid>(this, mapper);
    }

    /// <summary>
    ///     Class used to represents an operation that has been adjointed.
    /// </summary>
    [DebuggerTypeProxy(typeof(AdjointedOperation<,>.DebuggerProxy))]
    public class AdjointedOperation<I, O> : Unitary<I>, IApplyData, ICallable, IOperationWrapper
    {
        public AdjointedOperation(Operation<I, O> op) : base(op.__Factory__)
        {
            Debug.Assert(typeof(O) == typeof(QVoid));
            Debug.Assert(op is Operation<I, QVoid>);

            this.BaseOp = op as Operation<I, QVoid>;
        }

        public Operation<I, QVoid> BaseOp { get; }
        ICallable IOperationWrapper.BaseOperation => BaseOp;

        public override void __Init__() { }

        string ICallable.Name => ((ICallable)this.BaseOp).Name;
        string ICallable.FullName => ((ICallable)this.BaseOp).FullName;
        OperationFunctor ICallable.Variant => ((ICallable)this.BaseOp).AdjointVariant();
        
        public override Func<I, QVoid> __Body__ => this.BaseOp.__AdjointBody__;

        public override Func<I, QVoid> __AdjointBody__ => this.BaseOp.__Body__;

        public override Func<(IQArray<Qubit>, I), QVoid> __ControlledBody__ => this.BaseOp.__ControlledAdjointBody__;
                                                 
        public override Func<(IQArray<Qubit>, I), QVoid> __ControlledAdjointBody__ => this.BaseOp.__ControlledBody__;

        IEnumerable<Qubit> IApplyData.Qubits => ((IApplyData)this.BaseOp).Qubits;

        public override IApplyData __DataIn__(I data) => this.BaseOp.__DataIn__(data);

        public override IApplyData __DataOut__(QVoid data) => data;

        /// <inheritdoc/>
        public override RuntimeMetadata? GetRuntimeMetadata(IApplyData args)
        {
            var baseMetadata = this.BaseOp.GetRuntimeMetadata(args);
            if (baseMetadata == null) return null;
            baseMetadata.IsAdjoint = !baseMetadata.IsAdjoint;
            return baseMetadata;
        }

        public override string ToString() => $"(Adjoint {BaseOp?.ToString() ?? "<null>" })";
        public override string __qsharpType() => this.BaseOp?.__qsharpType();

        new internal class DebuggerProxy : Operation<I,QVoid>.DebuggerProxy
        {
            private AdjointedOperation<I, O> _op;

            public DebuggerProxy(AdjointedOperation<I, O> op) : base(op)
            {
                this._op = op;
            }

            public Operation<I, QVoid> Base => this._op.BaseOp;
        }
    }
}
