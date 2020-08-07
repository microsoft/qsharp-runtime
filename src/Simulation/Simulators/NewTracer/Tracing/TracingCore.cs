using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.NewTracer.CallGraph;
using Microsoft.Quantum.Simulation.Simulators.NewTracer.MetricCollection;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer.Tracing
{
    public class TracingCore : IOperationTrackingTarget
    {
        public readonly CallGraphEdge RootCall;

        internal readonly IMetricCollector[] Collectors;
        protected readonly Stack<IStackRecord>[] StackRecords;

        protected CallGraphEdge CurrentCall;
        protected int CurrentCallGraphDepth;
        protected int NextFreeEdgeId;

        //TODO: implement call stack depth limit

        //variables sorted first by the order of 'Collectors', and then within by the ordering given by the listener
        protected readonly Dictionary<CallGraphEdge, VariableDistributionSummary[]> TracerData;
        internal readonly string[] Metrics;

        public TracingCore(IEnumerable<IMetricCollector> allCollectors)
        {
            if (allCollectors == null || allCollectors.Count() == 0)
            {
                throw new ArgumentException("No metric collectors provided.");
            }
            this.Collectors = allCollectors.ToArray();
            this.Metrics = Collectors.SelectMany(listener => listener.Metrics()).ToArray();
            if (this.Metrics.Distinct().Count() != this.Metrics.Length) //TODO: what is a better way for this check
            {
                throw new ArgumentException("Duplicate metrics being tracked.");
            }
            this.StackRecords = this.Collectors.Select(_ => new Stack<IStackRecord>()).ToArray();
            this.TracerData = new Dictionary<CallGraphEdge, VariableDistributionSummary[]>();
            this.CurrentCall = this.RootCall = CallGraphEdge.MakeRoot();
            this.CurrentCallGraphDepth = 0;
            this.NextFreeEdgeId = this.RootCall.Id + 1;
        }

        void IOperationTrackingTarget.OnOperationStart(ICallable op, IApplyData arguments)
        {
            this.CurrentCallGraphDepth++;
            OPSpecialization callee = OPSpecialization.FromCallable(op);

            // Add this call as a child of the current call, and then set current call to this new call.
            this.CurrentCall = this.CurrentCall.AddCallTo(callee, this.NextFreeEdgeId++);

            for (int i = 0; i < Collectors.Length; i++)
            {
                IMetricCollector listener = Collectors[i];
                IStackRecord savedRecord = listener.SaveRecordOnOperationStart(arguments);
                StackRecords[i].Push(savedRecord);
            }
        }

        void IOperationTrackingTarget.OnOperationEnd(ICallable op, IApplyData arguments)
        {
            if (!this.IsExecuting() || this.CurrentCallGraphDepth <= 0 || this.CurrentCall.ParentEdge == null
                || this.CurrentCall.Operation.FullName != op.FullName || this.CurrentCall.Operation.Variant != op.Variant)
            {
                throw new InvalidOperationException("An error has ocurred - invalid call graph state.");
            }
            VariableDistributionSummary[] record = this.GetOrCreateRecord(this.CurrentCall);
            int v = 0;
            for (int i = 0; i < Collectors.Length; i++)
            {
                IMetricCollector listener = Collectors[i];
                IStackRecord savedRecord = StackRecords[i].Pop();
                double[] invocationData = listener.OutputMetricsOnOperationEnd(savedRecord, arguments);
                for (int j = 0; j < invocationData.Length; j++)
                {
                    record[v + j].AddSample(invocationData[j]);
                }
                v += invocationData.Length;
            }
            this.CurrentCall = CurrentCall.ParentEdge;
            this.CurrentCallGraphDepth--;
        }

        protected VariableDistributionSummary[] GetOrCreateRecord(CallGraphEdge edge)
        {
            if (!TracerData.TryGetValue(edge, out VariableDistributionSummary[] distributions))
            {
                // Creating empty distribution summaries for each variable for this new call edge
                TracerData[edge] = distributions = new VariableDistributionSummary[this.Metrics.Length];
                for (int v = 0; v < this.Metrics.Length; v++)
                {
                    distributions[v] = new VariableDistributionSummary();
                }
            }
            return distributions;
        }

        bool ITracerTarget.SupportsTarget(ITracerTarget target)
        {
            return target is IMetricCollector;
        }

        internal bool TryGetRecord(CallGraphEdge edge, out VariableDistributionSummary[] record)
        {
            return this.TracerData.TryGetValue(edge, out record);
        }

        internal VariableDistributionSummary[] GetSampleRecord()
        {
            return this.TracerData.Values.FirstOrDefault()
                ?? throw new InvalidOperationException("Tracer has collected no data!");
        }

        public bool IsExecuting()
        {
            return CurrentCallGraphDepth > 0 || (this.CurrentCall != this.RootCall);
        }
    }
}
