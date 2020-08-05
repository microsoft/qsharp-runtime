using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using System;
using System.Collections.Generic;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer
{
    public class WrapperSimulator : SimulatorBase
    {
        public override string Name => "WrapperSimulator";

        public SimulatorBase UnderlyingSimulator { get; private set; }

        public new event Action<ICallable, IApplyData>? OnOperationStart;
        public new event Action<ICallable, IApplyData>? OnOperationEnd;
        public new event Action<System.Runtime.ExceptionServices.ExceptionDispatchInfo>? OnFail;
        public new event Action<long>? OnAllocateQubits;
        public new event Action<IQArray<Qubit>>? OnReleaseQubits;
        public new event Action<long>? OnBorrowQubits;
        public new event Action<IQArray<Qubit>>? OnReturnQubits;
        public new event Action<string>? OnLog;
        public new event Action<Exception, IEnumerable<StackFrame>>? OnException;

        public WrapperSimulator(SimulatorBase? underlyingSimulator = null)
        {
            if (underlyingSimulator != null)
            {
                RegisterSimulator(underlyingSimulator);
            }
        }

        protected void RegisterSimulator(SimulatorBase underlyingSimulator)
        {
            if (this.UnderlyingSimulator != null)
            {
                throw new InvalidOperationException("A simulator has already been provided!");
            }

            this.UnderlyingSimulator = underlyingSimulator ?? throw new ArgumentNullException(nameof(underlyingSimulator));

            underlyingSimulator.OnOperationStart += (ICallable a, IApplyData b) => this.OnOperationStart?.Invoke(a, b);
            underlyingSimulator.OnOperationEnd += (ICallable a, IApplyData b) => this.OnOperationEnd?.Invoke(a, b);
            //TODO: make below as above as this code does not work
            underlyingSimulator.OnFail += this.OnFail;
            underlyingSimulator.OnAllocateQubits += this.OnAllocateQubits;
            underlyingSimulator.OnReleaseQubits += this.OnReleaseQubits;
            underlyingSimulator.OnBorrowQubits += this.OnBorrowQubits;
            underlyingSimulator.OnReturnQubits += this.OnReturnQubits;
            underlyingSimulator.OnLog += this.OnLog;
            underlyingSimulator.OnException += this.OnException;
        }

        private void CheckRegistered()
        {
            if (this.UnderlyingSimulator == null)
            {
                throw new InvalidOperationException("A simulator has not been registered!");
            }
        }

        public override object GetInstance(Type t)
        {
            this.CheckRegistered();
            return this.UnderlyingSimulator.GetInstance(t);
        }

        public override AbstractCallable CreateInstance(Type t)
        {
            if (this.UnderlyingSimulator == null)
            {
                throw new InvalidOperationException("A simulator has not been registered!");
            }
            return this.UnderlyingSimulator.CreateInstance(t);
        }
    }
}
