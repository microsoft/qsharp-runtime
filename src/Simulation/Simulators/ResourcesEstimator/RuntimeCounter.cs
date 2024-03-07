#nullable enable

using System.Collections.Generic;
using System.Diagnostics;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime;

namespace Simulator
{
    public class RuntimeCounter : IQCTraceSimulatorListener, ICallGraphStatistics
    {
        public RuntimeCounter()
        {
            AddToCallStack(CallGraphEdge.CallGraphRootHashed, OperationFunctor.Body);
            stats = new StatisticsCollector<CallGraphEdge>(
                new [] { "Runtime" },
                StatisticsCollector<CallGraphEdge>.DefaultStatistics()
            );
        }

        public bool NeedsTracingDataInQubits => false;

        public object? NewTracingData(long qubitId) => null;

        public void OnAllocate(object[] qubitsTraceData) {}

        public void OnRelease(object[] qubitsTraceData) {}

        public void OnBorrow(object[] qubitsTraceData, long newQubitsAllocated) {}

        public void OnReturn(object[] qubitsTraceData, long qubitReleased) {}

        public void OnOperationStart(HashedString name, OperationFunctor variant, object[] qubitsTraceData)
        {
            AddToCallStack(name, variant);
            operationCallStack.Peek().Watch.Start();
        }

        public void OnOperationEnd(object[] returnedQubitsTraceData)
        {
            var record = operationCallStack.Pop();
            record.Watch.Stop();
            Debug.Assert(operationCallStack.Count != 0, "Operation call stack must never get empty");
            stats.AddSample(new CallGraphEdge(record.OperationName, operationCallStack.Peek().OperationName, record.FunctorSpecialization, operationCallStack.Peek().FunctorSpecialization), new [] { (double)record.Watch.ElapsedMilliseconds });
        }

        public void OnPrimitiveOperation(int id, object[] qubitsTraceData, double primitiveOperationDuration) {}

        public IStatisticCollectorResults<CallGraphEdge> Results { get => stats as IStatisticCollectorResults<CallGraphEdge>; }

        private record OperationCallRecord(HashedString OperationName, OperationFunctor FunctorSpecialization)
        {
            public Stopwatch Watch { get; } = new();
        }

        private readonly Stack<OperationCallRecord> operationCallStack = new Stack<OperationCallRecord>();
        private readonly StatisticsCollector<CallGraphEdge> stats;

        private void AddToCallStack(HashedString operationName, OperationFunctor functorSpecialization) =>
            operationCallStack.Push(new OperationCallRecord(operationName, functorSpecialization));
    }
}
