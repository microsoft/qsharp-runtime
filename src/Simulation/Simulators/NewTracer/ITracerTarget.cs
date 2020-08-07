using Microsoft.Quantum.Simulation.Core;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer
{
    public interface ITracerTarget
    {
        //bool TryRegisterTarget(ITracerTarget target);

        bool SupportsTarget(ITracerTarget target);
    }

    public interface IOperationTrackingTarget : ITracerTarget
    {
        void OnOperationStart(ICallable operation, IApplyData arguments);

        void OnOperationEnd(ICallable operation, IApplyData arguments);
    }

    public interface IQubitTrackingTarget : ITracerTarget
    {
        void OnAllocateQubits(IQArray<Qubit> qubits);

        void OnReleaseQubits(IQArray<Qubit> qubits);

        void OnBorrowQubits(IQArray<Qubit> qubits, long allocatedForBorrowingCount);

        void OnReturnQubits(IQArray<Qubit> qubits, long releasedOnReturnCount);
    }

    public interface IMeasurementManagementTarget : ITracerTarget
    {
        Result Measure(IQArray<Pauli> bases, IQArray<Qubit> qubits);

        Result M(Qubit qubit);

        //TODO: force measure?

        void Assert(IQArray<Pauli> bases, IQArray<Qubit> qubits, Result result, string msg);

        void AssertProb(IQArray<Pauli> bases, IQArray<Qubit> qubits, double probabilityOfZero, string msg, double tol);
    }

    //TODO: delete ?
    /*
    //below is a concept prototype
    public abstract class PassthroughTarget<TIn> : ITracerTarget
    {
        public abstract TIn Get();

        protected IList<ITracerTarget> RegisteredTargets;

        public PassthroughTarget()
        {
            this.RegisteredTargets = new List<ITracerTarget>();
        }

        public abstract bool SupportsTarget(ITracerTarget target);

        public void RegisterTarget(ITracerTarget target)
        {
            if (!SupportsTarget(target)) { throw new ArgumentException(); }
            foreach (ITracerTarget t in RegisteredTargets)
            {
                if (t != null && t.SupportsTarget(target))
                {
                    t.RegisterTarget(target);
                    return;
                }
            }
            RegisteredTargets.Add(target);
        }

        public IEnumerable<TTarget> Targets<TTarget>() where TTarget : ITracerTarget
        {
            return RegisteredTargets.Where(target => target is TTarget).Cast<TTarget>(); //caching behavior
        }
    }
    */
}
