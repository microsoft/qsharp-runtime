using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using System;
using System.Collections.Generic;
using System.Runtime.ExceptionServices;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer
{
    public class WrapperSimulator : SimulatorBase
    {
        public override string Name => "WrapperSimulator";

        public SimulatorBase? UnderlyingSimulator { get; private set; }

        public new event Action<ICallable, IApplyData>? OnOperationStart;
        public new event Action<ICallable, IApplyData>? OnOperationEnd;
        public new event Action<ExceptionDispatchInfo>? OnFail;
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

            underlyingSimulator.OnOperationStart += (ICallable op, IApplyData arg) => this.OnOperationStart?.Invoke(op, arg);
            underlyingSimulator.OnOperationEnd += (ICallable op, IApplyData arg) => this.OnOperationEnd?.Invoke(op,arg);
            underlyingSimulator.OnFail += (ExceptionDispatchInfo i) => this.OnFail?.Invoke(i);
            underlyingSimulator.OnAllocateQubits += (long num) => this.OnAllocateQubits?.Invoke(num);
            underlyingSimulator.OnReleaseQubits += (IQArray<Qubit> qubits) => this.OnReleaseQubits?.Invoke(qubits);
            underlyingSimulator.OnBorrowQubits += (long num) => this.OnBorrowQubits?.Invoke(num);
            underlyingSimulator.OnReturnQubits += (IQArray<Qubit> qubits) => this.OnReturnQubits?.Invoke(qubits);
            underlyingSimulator.OnLog += (string m) => this.OnLog?.Invoke(m);
            underlyingSimulator.OnException += (Exception e, IEnumerable<StackFrame> stack) => this.OnException?.Invoke(e, stack);
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
            this.CheckRegistered();
            return this.UnderlyingSimulator.CreateInstance(t);
        }
    }
}
