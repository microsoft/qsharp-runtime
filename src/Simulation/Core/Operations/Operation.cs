// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#nullable enable

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;

#line hidden
namespace Microsoft.Quantum.Simulation.Core
{
    // Something in Q# that can be called but does not return a value.
    public partial interface ICallable<in I, out O> : ICallable
    {
        O Apply(I args);

        ICallable<P, O> Partial<P>(Func<P, I> mapper);
    }

    /// <summary>
    /// An operation that wraps another operation, for example
    /// <see cref="AdjointedOperation{I, O}"/>, <see cref="ControlledOperation{I, O}"/>,
    /// <see cref="OperationPartial{P, I, O}"/>,
    /// </summary>
    public interface IOperationWrapper
    {
        ICallable BaseOperation { get; }
    }

    /// <summary>
    ///     The base class for all ClosedType quantum operations.
    /// </summary>
    /// <typeparam name="I">Type of input parameters.</typeparam>
    /// <typeparam name="O">Type of return values.</typeparam>
    [DebuggerTypeProxy(typeof(Operation<,>.DebuggerProxy))]
    public abstract class Operation<I, O> : AbstractCallable, ICallable<I, O>
    {
        private Lazy<AdjointedOperation<I, O>> _adjoint;
        private Lazy<ControlledOperation<I, O>> _controlled;


        public Operation(IOperationFactory m) : base(m)
        {
            _adjoint = new Lazy<AdjointedOperation<I, O>>(() => new AdjointedOperation<I, O>(this));
            _controlled = new Lazy<ControlledOperation<I, O>>(() => new ControlledOperation<I, O>(this));
        }

        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        string ICallable.Name => ((ICallable)this).FullName;
        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        string ICallable.FullName => throw new NotImplementedException();
        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        OperationFunctor ICallable.Variant => OperationFunctor.Body;


        public virtual IApplyData __DataIn__(I data) => new QTuple<I>(data);

        public virtual IApplyData __DataOut__(O data) => new QTuple<O>(data);

        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        public abstract Func<I, O> __Body__ { get; }

        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        public virtual Func<I, QVoid> __AdjointBody__ => throw new NotImplementedException();

        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        public virtual Func<(IQArray<Qubit>, I), QVoid> __ControlledBody__ => throw new NotImplementedException();

        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        public virtual Func<(IQArray<Qubit>, I), QVoid> __ControlledAdjointBody__ => throw new NotImplementedException();

        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        public AdjointedOperation<I, O> Adjoint => _adjoint.Value;

        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        public ControlledOperation<I, O> Controlled => _controlled.Value;

        /// <inheritdoc/>
        public override RuntimeMetadata? GetRuntimeMetadata(IApplyData args) =>
            new RuntimeMetadata()
            {
                Label = ((ICallable)this).Name,
                FormattedNonQubitArgs = args.GetNonQubitArgumentsAsString() ?? "",
                Targets = args.GetQubits()?.Distinct() ?? new List<Qubit>(),
            };

        public O Apply(I a)
        {
            var __result__ = default(O);

            try
            {
                this.__Factory__?.StartOperation(this, __DataIn__(a));
                __result__ = this.__Body__(a);
            }
            catch (Exception e)
            {
                this.__Factory__?.Fail(System.Runtime.ExceptionServices.ExceptionDispatchInfo.Capture(e));
                throw;
            }
            finally
            {
                this.__Factory__?.EndOperation(this, __DataOut__(__result__));
            }

            return __result__;
        }

        public T Partial<T>(object partialInfo)
        {
            var tupleType = FindPartialType(typeof(I), partialInfo);
            var partialType = typeof(OperationPartial<,,>).MakeGenericType(tupleType, typeof(I), typeof(O));

            return (T)Activator.CreateInstance(partialType, new object[] { this, partialInfo });
        }

        public OperationPartial<P, I, O> Partial<P>(Func<P, I> mapper)
        {
            return new OperationPartial<P, I, O>(this, mapper);
        }

        O ICallable<I, O>.Apply(I args) => this.Apply(args);

        ICallable<P, O> ICallable<I, O>.Partial<P>(Func<P, I> mapper) => this.Partial<P>(mapper);

        public virtual GenO Apply<GenO>(object args)
        {
            Debug.Assert(args != null, "Calling Apply with null args. Can't verify type of args");
            Debug.Assert(typeof(GenO).IsAssignableFrom(typeof(O)), $"Apply received a wrong type of Input. Expected {typeof(GenO)}, but got {typeof(O)}");

            O result = this.Apply((I)PartialMapper.CastTuple(typeof(I), args));
            return (GenO)(object)result;
        }

        QVoid ICallable.Apply(object args)
        {
            Debug.Assert(typeof(O) == typeof(QVoid), "Calling void Apply on an operation that doesn't return QVoid");
            this.Apply((I)PartialMapper.CastTuple(typeof(I), args));

            return QVoid.Instance;
        }

        ICallable ICallable.Partial(object partialTuple) => this.Partial<ICallable>(partialTuple);


        /// <summary>
        ///     Finds the expected Tuple type from the given partial values and given input type.
        /// </summary>
        public static Type FindPartialType(Type original, object partial)
        {
            if (partial == null || partial == QVoid.Instance)
            {
                return null;
            }

            // Instead of a partial type, we receive a partial mapper:
            if (partial.GetType().Name == typeof(Func<,>).Name)
            {
                return partial.GetType().GenericTypeArguments[0];
            }

            if (partial.GetType() == typeof(MissingParameter))
            {
                return original.Normalize();
            }

            if (original.IsTuple())
            {
                var fields = original.GetFields().OrderBy(f => f.Name).ToArray();
                var partialFields = partial.GetType().GetFields().OrderBy(f => f.Name).ToArray();

                List<Type> result = new List<Type>();

                for (var i = 0; i < fields.Length; i++)
                {
                    var v = FindPartialType(fields[i].FieldType, partialFields[i].GetValue(partial));
                    if (v != typeof(QVoid))
                    {
                        result.Add(v);
                    }
                }

                if (result.Count == 0)
                {
                    return typeof(QVoid);
                }
                if (result.Count == 1)
                {
                    return result[0];
                }
                if (result.Count > 8)
                {
                    throw new InvalidOperationException("Can't support Partial Tuples with more than 8 items.");
                }
                else
                {
                    return PartialMapper.TupleTypes[result.Count].MakeGenericType(result.ToArray());
                }
            }
            else
            {
                return typeof(QVoid);
            }
        }

        public override string ToString() => ((ICallable)this).Name;
        public virtual string __qsharpType() => this.GetType().QSharpType();

        internal class DebuggerProxy
        {
            private Operation<I, O> op;

            public DebuggerProxy(Operation<I, O> op)
            {
                this.op = op;
            }

            public string Name => ((ICallable)this.op).Name;

            public string FullName => ((ICallable)this.op).FullName;

            public OperationFunctor Variant => ((ICallable)this.op).Variant;

            public virtual string Signature => this.op.__qsharpType();

        }
    }
}
