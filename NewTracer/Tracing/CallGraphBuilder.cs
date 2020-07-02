using Microsoft.Quantum.Simulation.Core;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using NewTracer.Utils;
using Microsoft.Quantum.Simulation.Common;
using NewTracer.MetricCollection;
using NewTracer.Data;

namespace NewTracer.CallGraph
{
    /// <summary>
    /// An <see cref="IQuantumProcessor"/> that builds a call graph as the simulator executes.
    /// Can be provided with <see cref="ICallGraphBuilderListener"/>'s that will receive
    /// notifications when a <see cref="CallGraphEdge"/> is entered or exited.
    /// </summary>
    public class CallGraphBuilder : EmptyProcessor, IQuantumProcessor
    {
        private readonly IMetricCollector[] Listeners;
        private readonly Stack<IStackRecord>[] StackRecords;

        private readonly CallGraphEdge RootCall;

        private CallGraphEdge CurrentCall;
        private int CurrentCallGraphDepth;
        private int NextFreeEdgeId;

        //variables sorted first by the order of 'Listeners', and then within by the ordering given by the listener
        private readonly string[] Metrics;
        private readonly Dictionary<CallGraphEdge, VariableDistributionSummary[]> TracerData;

        internal CallGraphBuilder(IEnumerable<IMetricCollector> listeners)
        {
            //TODO: check for uniqueness of metric names in listeners
            this.Listeners = listeners?.ToArray() ?? throw new ArgumentNullException(nameof(listeners));
            this.Metrics = Listeners.SelectMany(listener => listener.Metrics()).ToArray();
            this.StackRecords = Listeners.Select(_ => new Stack<IStackRecord>()).ToArray();
            this.TracerData = new Dictionary<CallGraphEdge, VariableDistributionSummary[]>();
            this.CurrentCall = this.RootCall = CallGraphEdge.MakeRoot();
            this.CurrentCallGraphDepth = 0;
            this.NextFreeEdgeId = this.RootCall.Id + 1;
        }

        public override void OnOperationStart(ICallable op, IApplyData arguments)
        {
            this.CurrentCallGraphDepth++;
            OPSpecialization callee = OPSpecialization.FromCallable(op);

            // Add this call as a child of the current call, and then set current call to this new call.
            this.CurrentCall = this.CurrentCall.AddCallTo(callee, this.NextFreeEdgeId++);

            for (int i = 0; i < Listeners.Length; i++)
            {
                IMetricCollector listener = Listeners[i];
                IStackRecord savedRecord = listener.SaveRecordOnOperationStart(arguments);
                StackRecords[i].Push(savedRecord);
            }
        }

        public override void OnOperationEnd(ICallable op, IApplyData arguments)
        {
            if (!this.IsExecuting()
                || this.CurrentCallGraphDepth <= 0
                || this.CurrentCall.ParentEdge == null
                || this.CurrentCall.Operation.FullName != op.FullName
                || this.CurrentCall.Operation.Variant != op.Variant
            )
            { throw new InvalidOperationException("Invalid call graph state or call graph collection stopped by user."); }

            VariableDistributionSummary[] edgeVariableSummaries = this.LookupVariableSummaries(this.CurrentCall);
            int v = 0;
            for (int i = 0; i < Listeners.Length; i++)
            {
                IMetricCollector listener = Listeners[i];
                IStackRecord savedRecord = StackRecords[i].Pop();
                double[] invocationData = listener.OutputMetricsOnOperationEnd(savedRecord, arguments);
                for (int j = 0; j < invocationData.Length; j++)
                {
                    edgeVariableSummaries[v + j].AddSample(invocationData[j]);
                }
                v += invocationData.Length;
            }
            this.CurrentCall = CurrentCall.ParentEdge;
            this.CurrentCallGraphDepth--;
        }

        public bool IsExecuting()
        {
            return CurrentCallGraphDepth > 0 || (this.CurrentCall != this.RootCall);
        }

        private VariableDistributionSummary[] LookupVariableSummaries(CallGraphEdge edge)
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

        internal VariableDistributionSummary[] GetEdgeMetrics(CallGraphEdge callEdge)
        {
            if (this.IsExecuting())
            { throw new InvalidOperationException(); }

            return this.TracerData[callEdge];
        }

        public TracerResults GetResults()
        {
            if (this.IsExecuting())
            { throw new InvalidOperationException("Tracer is still executing!"); }

            return new TracerResults(this.RootCall, this.TracerData, this.Metrics);
        }
    }
}
