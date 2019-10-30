// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Diagnostics;

namespace Microsoft.Quantum.Simulation.Core
{
    /// <summary>
    ///     Represents an operation that has an Adjoint and whose
    ///     input Type is not resolved until it gets Applied at runtime.
    /// </summary>
    public interface IAdjointable : ICallable
    {
        IAdjointable Adjoint { get; }

        new IAdjointable Partial(object values);
    }

    /// <summary>
    ///     Represents the result of applying Adjoint to an operation
    ///     input Type is not resolved until it gets Applied at runtime.
    /// </summary>
    [DebuggerTypeProxy(typeof(GenericAdjoint.DebuggerProxy))]
    public class GenericAdjoint : GenericCallable, IApplyData, IOperationWrapper
    {
        public GenericAdjoint(GenericCallable baseOp) : base(baseOp.Factory, null)
        {
            this.BaseOp = baseOp;
        }

        public GenericCallable BaseOp { get; }
        ICallable IOperationWrapper.BaseOperation => BaseOp;

        IEnumerable<Qubit> IApplyData.Qubits => ((IApplyData)this.BaseOp)?.Qubits;


        protected override ICallable CreateCallable(Type I, Type O)
        {
            Debug.Assert(O == typeof(QVoid), "Adjoint can only be applied to Operations that return void");

            var op = this.BaseOp.FindCallable(I, O);
            var adjOp = typeof(AdjointedOperation<,>).MakeGenericType(MatchOperationTypes(I, O, op.GetType()));
            var result = (ICallable)Activator.CreateInstance(adjOp, op);

            return result;
        }

        public override string Name => this.BaseOp.Name;
        public override string FullName => this.BaseOp.FullName;
        public override OperationFunctor Variant => this.BaseOp.AdjointVariant();

        public override string QSharpType() => this.BaseOp.QSharpType();

        public override string ToString() => $"(Adjoint {this.BaseOp})";

        new internal class DebuggerProxy
        {
            private GenericAdjoint _op;

            public DebuggerProxy(GenericAdjoint op)
            {
                this._op = op;
            }

            public string Name => _op.Name;
            public string FullName => _op.FullName;
            public OperationFunctor Variant => _op.Variant;

            public GenericCallable Base => this._op.BaseOp;
        }
    }
}
