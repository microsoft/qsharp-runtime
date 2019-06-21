using System;

namespace Microsoft.Quantum.Simulation.Core
{
    /// <summary>
    /// Represents an operation that has both, a Controlled and Adjoint 
    /// version.
    /// </summary>
    public interface IUnitary<I> : IAdjointable<I>, IControllable<I>, IUnitary
    {
        new IUnitary<I> Adjoint { get; }

        new IUnitary<(IQArray<Qubit>, I)> Controlled { get; }

        new IUnitary<P> Partial<P>(Func<P, I> mapper);
    }

    /// <summary>
    /// Base class for Unitary operations.
    /// </summary>
    public abstract class Unitary<I> : Operation<I, QVoid>, IUnitary<I>
    {
        public Unitary(IOperationFactory m) : base(m) { }

        IAdjointable IAdjointable.Adjoint => base.Adjoint;
        IAdjointable IAdjointable.Partial(object partialTuple) => base.Partial<IAdjointable>(partialTuple);


        IControllable IControllable.Controlled => base.Controlled;
        IControllable IControllable.Partial(object partialTuple) => base.Partial<IControllable>(partialTuple);


        IUnitary IUnitary.Adjoint => base.Adjoint;
        IUnitary IUnitary.Controlled => base.Controlled;
        IUnitary IUnitary.Partial(object partialTuple) => base.Partial<IUnitary>(partialTuple);


        IAdjointable<I> IAdjointable<I>.Adjoint => base.Adjoint;
        IAdjointable<P> IAdjointable<I>.Partial<P>(Func<P, I> mapper) => base.Partial(mapper);


        IControllable<(IQArray<Qubit>, I)> IControllable<I>.Controlled => base.Controlled;
        IControllable<P> IControllable<I>.Partial<P>(Func<P, I> mapper) => base.Partial(mapper);


        IUnitary<I> IUnitary<I>.Adjoint => base.Adjoint;
        IUnitary<(IQArray<Qubit>, I)> IUnitary<I>.Controlled => base.Controlled;
        IUnitary<P> IUnitary<I>.Partial<P>(Func<P, I> mapper) => base.Partial(mapper);
    }
}
