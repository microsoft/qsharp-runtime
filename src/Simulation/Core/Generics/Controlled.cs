// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;

namespace Microsoft.Quantum.Simulation.Core
{
    /// <summary>
    ///     Represents an operation that has a Controlled operation and whose
    ///     input Type is not resolved until it gets Applied at runtime.
    /// </summary>
    public partial interface IControllable : ICallable
    {
        IControllable Controlled { get; }
        new IControllable Partial(object values);
    }



    /// <summary>
    ///     Represents the result of applying Controlled to an operation
    ///     input Type is not resolved until it gets Applied at runtime.
    /// </summary>
    [DebuggerTypeProxy(typeof(GenericControlled.DebuggerProxy))]
    public class GenericControlled : GenericCallable, IApplyData, IOperationWrapper
    {
        public GenericControlled(GenericCallable baseOp) : base(baseOp.Factory, null)
        {
            this.BaseOp = baseOp;
        }

        public GenericCallable BaseOp { get; }
        ICallable IOperationWrapper.BaseOperation => BaseOp;

        IEnumerable<Qubit> IApplyData.Qubits => ((IApplyData)this.BaseOp)?.Qubits;

        protected override ICallable CreateCallable(Type I, Type O)
        {
            var fields = I.GetFields().OrderBy(f => f.Name).ToArray();
            IgnorableAssert.Assert(fields.Length == 2, $"Controlled must always accept two args: an array of control qubits and the operation normal input tuple. Got {I.FullName}");
            IgnorableAssert.Assert(O == typeof(QVoid), $"Controlled can only be applied to Operations that return void. Received: {O.FullName}");

            var baseArgsType = fields[1].FieldType;
            var op = this.BaseOp.FindCallable(baseArgsType, O);
            var ctrlOp = typeof(ControlledOperation<,>).MakeGenericType(MatchOperationTypes(baseArgsType, O, op.GetType()));
            var result = (ICallable)Activator.CreateInstance(ctrlOp, op);

            return result;
        }

        public override string Name => this.BaseOp.Name;
        public override string FullName => this.BaseOp.FullName;
        public override OperationFunctor Variant => this.BaseOp.ControlledVariant();

        public static string AddControlQubitsToSignature(string baseOpSignature)
        {
            if (baseOpSignature == null)
            {
                return null;
            }

            var pos = baseOpSignature.IndexOf(" => ");
            var inParams = baseOpSignature.Substring(0, pos);
            var outParams = baseOpSignature.Substring(pos);

            return $"(Qubit[],{inParams}){outParams}";
        }

        public override string QSharpType() => AddControlQubitsToSignature(this.BaseOp.QSharpType());

        public override string ToString() => $"(Controlled {this.BaseOp})";

        new internal class DebuggerProxy
        {
            private GenericControlled _op;

            public DebuggerProxy(GenericControlled op)
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
