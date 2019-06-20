using System;
using System.Collections.Generic;
using System.Diagnostics;

namespace Microsoft.Quantum.Simulation.Core
{
    /// <summary>
    /// An instance of a partially applied user-defined type.
    /// Calling the Apply method of this instance will return a new instance of the originally
    /// applied type.
    /// </summary>
    /// <typeparam name="P">The Type of the argument needed to fully-create the original UDT instance.</typeparam>
    /// <typeparam name="B">The original base type of the UDT.</typeparam>
    /// <typeparam name="U">The original UDT type.</typeparam>
    [DebuggerTypeProxy(typeof(UDTPartial<,,>.DebuggerProxy))]
    public class UDTPartial<P, B, U> : ICallable<P, U> 
    {
        public UDTPartial(Func<P, B> mapper) 
        {
            Mapper = mapper;
        }

        public Func<P, B> Mapper { get; }

        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        string ICallable.Name => ((ICallable)this).FullName;
        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        string ICallable.FullName => throw new NotImplementedException();
        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        OperationFunctor ICallable.Variant => OperationFunctor.Body;

        public object Value => null; 
        public IEnumerable<Qubit> Qubits => null;

        public U Apply(P a) => 
            (U)Activator.CreateInstance(typeof(U), this.Mapper(a));

        public QVoid Apply(object args)
        {
            Debug.Fail("Calling void Apply on an operation that doesn't return QVoid");
            return QVoid.Instance;
        }

        public O Apply<O>(object args)
        {
            object result = this.Apply((P)args); 
            return (O)result;
        }

        public UDTPartial<P1, B, U> Partial<P1>(Func<P1, P> mapper) =>
            new UDTPartial<P1, B, U>(args => this.Mapper(mapper(args)));

        ICallable<P1, U> ICallable<P, U>.Partial<P1>(Func<P1, P> mapper) => this.Partial<P1>(mapper);

        public ICallable Partial(object partialTuple) 
        {
            var tupleType = Operation<P, U>.FindPartialType(typeof(P), partialTuple);
            var partialType = typeof(UDTPartial<,,>).MakeGenericType(tupleType, typeof(B), typeof(U));
            return (ICallable)Activator.CreateInstance(partialType, new object[] { this, partialTuple });
        }

        internal class DebuggerProxy
        {
            private readonly UDTPartial<P, B, U> u;
        
            DebuggerProxy(UDTPartial<P,B,U> udt)
            {
                this.u = udt;
            }
        
            public string Base => typeof(U).Name;
        }
    }   
}
