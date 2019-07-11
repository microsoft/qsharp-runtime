// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;

#line hidden
namespace Microsoft.Quantum.Simulation.Core
{
    /// <summary>
    ///     The base class for all Functions.
    /// </summary>
    /// <typeparam name="I">Type of input parameters.</typeparam>
    /// <typeparam name="O">Type of return values.</typeparam>
    [DebuggerTypeProxy(typeof(Function<,>.DebuggerProxy))]  
    public abstract class Function<I, O> : AbstractCallable, ICallable<I, O>
    {
        public Function(IOperationFactory m) : base(m)
        {
        }

        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        string ICallable.Name => ((ICallable)this).FullName;
        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        string ICallable.FullName => throw new NotImplementedException();
        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        OperationFunctor ICallable.Variant => OperationFunctor.Body;

        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        public abstract Func<I, O> Body { get; }

        public virtual IApplyData __dataIn(I data) => new QTuple<I>(data);

        public virtual IApplyData __dataOut(O data) => new QTuple<O>(data);

        public O Apply(I a)
        {
            var __result__ = this.Body(a);
            return __result__; 
        }

        public T Partial<T>(object partialInfo)
        {
            var tupleType = Operation<I, O>.FindPartialType(typeof(I), partialInfo);
            var partialType = typeof(FunctionPartial<,,>).MakeGenericType(tupleType, typeof(I), typeof(O));

            return (T)Activator.CreateInstance(partialType, new object[] { this, partialInfo });
        }

        public FunctionPartial<P, I, O> Partial<P>(Func<P, I> mapper)
        {
            return new FunctionPartial<P, I, O>(this, mapper);
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


        public override string ToString() => ((ICallable)this).Name;
        public virtual string __qsharpType() => this.GetType().QSharpType();

        internal class DebuggerProxy
        {
            private Function<I, O> op;

            public DebuggerProxy(Function<I,O> op)
            {
                this.op = op;
            }

            public string Name => ((ICallable)this.op).Name;

            public string FullName => ((ICallable)this.op).FullName;

            public virtual string Signature => this.op.__qsharpType();
        }
    }
}
