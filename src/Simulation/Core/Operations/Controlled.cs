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
    /// Represents an operation that has a Controlled operation
    /// </summary>
    public interface IControllable<I> : ICallable<I, QVoid>, IControllable
    {
        new IControllable<(IQArray<Qubit>, I)> Controlled { get; }
        new IControllable<P> Partial<P>(Func<P, I> mapper);
    }

    /// <summary>
    ///     Base class for operations that have a ControlledOperation. Both the Body and ControlledBody methods
    ///     need to be implemented.
    /// </summary>
    public abstract class Controllable<I> : Operation<I, QVoid>, IControllable<I>
    {
        public Controllable(IOperationFactory m) : base(m) { }

        IControllable IControllable.Controlled => base.Controlled;
        IControllable IControllable.Partial(object partialTuple) => base.Partial<IControllable>(partialTuple);


        IControllable<(IQArray<Qubit>, I)> IControllable<I>.Controlled => base.Controlled;
        IControllable<P> IControllable<I>.Partial<P>(Func<P, I> mapper) => new OperationPartial<P, I, QVoid>(this, mapper);
    }


    /// <summary>
    ///     This class is used to represents an operation that has been controlled.
    /// </summary>
    [DebuggerTypeProxy(typeof(ControlledOperation<,>.DebuggerProxy))]
    public class ControlledOperation<I, O> : Unitary<(IQArray<Qubit>, I)>, IApplyData, ICallable, IOperationWrapper
    {
        public class In : IApplyData
        {
            private IQArray<Qubit> Ctrls { get; }

            private IApplyData BaseData { get; }

            public In((IQArray<Qubit>, IApplyData) data)
            {
                this.Ctrls = data.Item1;
                this.BaseData = data.Item2;
            }

            public object Value => (this.Ctrls, (I)this.BaseData.Value);

            IEnumerable<Qubit> IApplyData.Qubits => Qubit.Concat(Ctrls, BaseData?.Qubits);
        }

        public ControlledOperation(Operation<I, O> op) : base(op.Factory)
        {
            Debug.Assert(typeof(O) == typeof(QVoid));
            Debug.Assert(op is Operation<I, QVoid>);

            this.BaseOp = op as Operation<I, QVoid>;
        }

        public Operation<I, QVoid> BaseOp { get; }
        ICallable IOperationWrapper.BaseOperation => BaseOp;

        public override void Init() { }

        string ICallable.Name => ((ICallable)this.BaseOp).Name;
        string ICallable.FullName => ((ICallable)this.BaseOp).FullName;
        OperationFunctor ICallable.Variant => ((ICallable)this.BaseOp).ControlledVariant();

        public override Func<(IQArray<Qubit>, I), QVoid> Body => this.BaseOp.ControlledBody;

        public override Func<(IQArray<Qubit>, I), QVoid> AdjointBody => this.BaseOp.ControlledAdjointBody;

        public override Func<(IQArray<Qubit>, (IQArray<Qubit>, I)), QVoid> ControlledBody
        {
            get
            {
                return (__in) =>
                {
                    var (ctrl1, (ctrl2, args)) = __in;
                    var ctrls = QArray<Qubit>.Add(ctrl1, ctrl2);
                    return this.BaseOp.ControlledBody.Invoke((ctrls, args));
                };
            }
        }

        public override Func<(IQArray<Qubit>, (IQArray<Qubit>, I)), QVoid> ControlledAdjointBody
        {
            get
            {
                return (__in) =>
                {
                    var (ctrl1, (ctrl2, args)) = __in;
                    var ctrls = QArray<Qubit>.Add(ctrl1, ctrl2);
                    return this.BaseOp.ControlledAdjointBody.Invoke((ctrls, args));
                };
            }
        }

        IEnumerable<Qubit> IApplyData.Qubits => ((IApplyData)this.BaseOp).Qubits;

        public override IApplyData __dataIn((IQArray<Qubit>, I) data) => new In((data.Item1, this.BaseOp.__dataIn(data.Item2)));

        public override IApplyData __dataOut(QVoid data) => data;

        /// <inheritdoc/>
        public override RuntimeMetadata? GetRuntimeMetadata(IApplyData args)
        {
            Debug.Assert(args.Value is ValueTuple<IQArray<Qubit>, I>, $"Failed to retrieve runtime metadata for {this.ToString()}.");

            if (args.Value is ValueTuple<IQArray<Qubit>, I> ctrlArgs)
            {
                var (controls, baseArgs) = ctrlArgs;
                var baseMetadata = this.BaseOp.GetRuntimeMetadata(this.BaseOp.__dataIn(baseArgs));
                if (baseMetadata == null) return null;
                baseMetadata.IsControlled = true;
                baseMetadata.Controls = controls.Concat(baseMetadata.Controls);
                return baseMetadata;
            }

            return null;
        }


        public override string ToString() => $"(Controlled {BaseOp?.ToString() ?? "<null>" })";
        public override string __qsharpType() => GenericControlled.AddControlQubitsToSignature(this.BaseOp?.__qsharpType());

        new internal class DebuggerProxy : Operation<(IQArray<Qubit>, I), QVoid>.DebuggerProxy
        {
            private ControlledOperation<I, O> _op;

            public DebuggerProxy(ControlledOperation<I, O> op) : base(op)
            {
                this._op = op;
            }

            public Operation<I, QVoid> Base => this._op.BaseOp;
        }
    }
}
