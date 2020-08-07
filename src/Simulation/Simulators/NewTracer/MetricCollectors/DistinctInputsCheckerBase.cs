using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.NewTracer.MetricCollection;
using System.Collections.Generic;
using System.Linq;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer.MetricCollectors
{
    //TODO: should this be abstract? could be used without decomposition if intrinsics show up as operations
    public abstract class DistinctInputsCheckerBase : IMetricCollector, IOperationTrackingTarget
    {
        public class NonDistinctInputsEventCount : IStackRecord
        {
            public double NonDistinctCount { get; set; }
        }

        protected NonDistinctInputsEventCount CurrentState;
        protected readonly bool ThrowOnNonDistinctQubits;

        public DistinctInputsCheckerBase(bool throwOnNonDistinctQubits)
        {
            this.ThrowOnNonDistinctQubits = throwOnNonDistinctQubits;
            this.CurrentState = new NonDistinctInputsEventCount();
        }

        string IMetricCollector.CollectorName()
        {
            return "DistinctInputsChecker";
        }

        IList<string> IMetricCollector.Metrics()
        {
            return new string[]
            {
                "NonDistinctCount"
            };
        }

        public void DistinctQubitUseCheck(params Qubit[] qubits)
        {
            this.DistinctQubitUseCheck(qubits);
        }

        public void DistinctQubitUseCheck(IEnumerable<Qubit>? qubits)
        {
            if (qubits == null) { return; }

            int numQubits = qubits.Count();
            int numUniqueQubits = qubits.Select(qubit => qubit.Id).Distinct().Count();
            int numNonDistinct = numQubits - numUniqueQubits;

            this.CurrentState.NonDistinctCount += numNonDistinct;
            if (numNonDistinct > 0 && this.ThrowOnNonDistinctQubits)
            {
                throw new DistinctInputsCheckerException();
            }
        }

        double[] IMetricCollector.OutputMetricsOnOperationEnd(IStackRecord startState, IApplyData returned)
        {
            NonDistinctInputsEventCount prevState = (NonDistinctInputsEventCount)startState;
            return new double[]
            {
                    CurrentState.NonDistinctCount - prevState.NonDistinctCount
            };
        }

        IStackRecord IMetricCollector.SaveRecordOnOperationStart(IApplyData arguments)
        {
            return new NonDistinctInputsEventCount
            {
                NonDistinctCount = CurrentState.NonDistinctCount
            };
        }

        void IOperationTrackingTarget.OnOperationStart(ICallable operation, IApplyData arguments)
        {
            this.DistinctQubitUseCheck(arguments.GetQubits());
        }

        void IOperationTrackingTarget.OnOperationEnd(ICallable operation, IApplyData arguments)
        {
            this.DistinctQubitUseCheck(arguments.GetQubits());
        }

        bool ITracerTarget.SupportsTarget(ITracerTarget target) => false;
    }
}
