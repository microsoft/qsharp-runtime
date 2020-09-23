using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.QuantumProcessor;
using Microsoft.Quantum.Simulation.Simulators.NewTracer.CallGraph;
using Microsoft.Quantum.Simulation.Simulators.NewTracer.MetricCollection;
using Microsoft.Quantum.Simulation.Simulators.NewTracer.NewDecomposition;
using Microsoft.Quantum.Simulation.Simulators.NewTracer.OldDecomposition;
using Microsoft.Quantum.Simulation.Simulators.NewTracer.Tracing;
using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer
{
    public partial class TracerSimulator : WrapperSimulator, IOperationTrackingTarget
    {
        public override string Name => "TracerSimulator";

        protected readonly List<ITracerTarget> Targets; //should not be added to after construction

        protected readonly TracingCore Tracer;
        protected Dictionary<AggregateInvocation, VariableDistributionSummary[]>? CachedAggregateMetrics;

        public TracerSimulator(SimulatorBase underlyingSimulator) : base(underlyingSimulator)
        {
            throw new NotImplementedException();
        }

        public TracerSimulator(NewTracerConfiguration? config = null)
            : this(
                Utils.BuildTargetsFromConfig(config),
                useNewDecomposition: true,
                optimizeDepth: (config != null ? config.OptimizeDepth : false))
        {
        }

        public TracerSimulator(QCTraceSimConfiguration config)
            : this(Utils.BuildTargetsFromConfig(config), useNewDecomposition: false, optimizeDepth: false)
        {
        }

        //In this scenario, it is the user's responsibilty to inform their metric collectors of gate operations.
        //The given engine is responsible for handling measurements and has its own qubit manager.
        public TracerSimulator(SimulatorBase engine, IEnumerable<IMetricCollector> suppliedCollectors)
        {

        }

        //Metric collectors constructued according to configuration, and if engine does not support measuring,
        //tracer will handle measurements by treating asserts as annotations. Engine may or may not have a 
        //qubit manager. Decomposition will be provided as necessary as specified in configuration.
        public TracerSimulator(SimulatorBase engine, TracerConfiguration config)
        {
        }

        public IEnumerable<TTarget> GetTargets<TTarget>() where TTarget : ITracerTarget
        {
            return this.Targets.Extract<ITracerTarget, TTarget>();
        }

        public TTarget GetTarget<TTarget>() where TTarget : ITracerTarget
        {
            IEnumerable<TTarget> matchingTargets = this.GetTargets<TTarget>();
            if (matchingTargets.Count() != 1) { throw new Exception($"There are {matchingTargets.Count()} matching targets when 1 is expected."); }
            return matchingTargets.First();
        }

        public TracerSimulator(IEnumerable<ITracerTarget> suppliedTargets, bool useNewDecomposition = true, bool optimizeDepth = false)
        {
            if (suppliedTargets == null) { throw new ArgumentNullException(nameof(suppliedTargets)); }

            this.Targets = suppliedTargets.ToList();

            if (Targets.Count == 0) { throw new ArgumentException("No targets provided!"); }

            Targets.Add(this);
            IEnumerable<IMetricCollector> metricCollectors = Targets.Extract<ITracerTarget, IMetricCollector>();
            this.Tracer = new TracingCore(metricCollectors);
            Targets.Add(this.Tracer);

            IEnumerable<IQubitTraceSubscriber> qubitTraceTargets = Targets
                .Extract<ITracerTarget, IQubitTraceSubscriber>();
            IQubitManager qubitManager = new TraceableQubitManager(qubitTraceTargets, optimizeDepth);

            if (useNewDecomposition)
            {
                NewDecomposer decomposer = new NewDecomposer(this, Targets);
                Targets.Add(decomposer);
                this.RegisterSimulator(new QuantumProcessorDispatcher(decomposer, qubitManager));
            }
            else
            {
                OldTracerInternalSim engine = new OldTracerInternalSim(this, qubitManager, Targets);
                Targets.Add(engine);
                this.RegisterSimulator(engine);
            }
            IEnumerable<IOperationTrackingTarget> operationTrackers = Targets.Extract<ITracerTarget, IOperationTrackingTarget>();
            this.RegisterOperationTrackers(operationTrackers);
        }

        private void RegisterOperationTrackers(IEnumerable<IOperationTrackingTarget> operationTrackers)
        {
            foreach (IOperationTrackingTarget target in operationTrackers)
            {
                this.OnOperationStart += target.OnOperationStart;
            }
            foreach (IOperationTrackingTarget target in operationTrackers.Reverse())
            {
                this.OnOperationEnd += target.OnOperationEnd;
            }
        }

        void IOperationTrackingTarget.OnOperationStart(ICallable operation, IApplyData arguments)
        {
            this.ClearAggregates(); //aggregates no longer valid
        }

        void IOperationTrackingTarget.OnOperationEnd(ICallable operation, IApplyData arguments)
        {
            this.ClearAggregates();
        }

        bool ITracerTarget.SupportsTarget(ITracerTarget target)
        {
            throw new NotImplementedException();
        }

        #region Metric querying

        protected void ClearAggregates()
        {
            this.CachedAggregateMetrics = null;
        }

        protected void CheckCanQueryAndBuildAggregates()
        {
            if (Tracer.IsExecuting())
            {
                throw new QueryingTracerResultsDuringExecutionException();
            }
            if (this.CachedAggregateMetrics == null)
            {
                //TODO: make this logic concurrency-safe
                this.CachedAggregateMetrics = GenerateAggregates();
            }
        }

        protected VariableDistributionSummary[] GetAggregateEdgeMetrics(OPSpecialization caller, OPSpecialization callee)
        {
            this.CheckCanQueryAndBuildAggregates();
            AggregateInvocation invocation = new AggregateInvocation(callee, caller);
            if (!this.CachedAggregateMetrics.TryGetValue(invocation, out VariableDistributionSummary[] metrics))
            {
                throw new InvalidTracerResultsQuery();
            }
            return metrics;
        }

        protected VariableDistributionSummary GetAggregateEdgeSummary(OPSpecialization caller, OPSpecialization callee, string metric)
        {
            int metricId = this.GetMetricId(metric);
            return this.GetAggregateEdgeMetrics(caller, callee)[metricId];
        }

        protected OPSpecialization GetOperation<TOperation>(OperationFunctor functor)
        {
            return new OPSpecialization(GetOperationName<TOperation>(), functor);
        }

        protected int GetMetricId(string metric)
        {
            for (int m = 0; m < Tracer.Metrics.Length; m++)
            {
                if (Tracer.Metrics[m].Equals(metric, StringComparison.InvariantCultureIgnoreCase))
                {
                    return m;
                }
            }
            throw new ArgumentException($"Given metric {metric} was not tracked by the tracer.");
        }

        protected string GetOperationName<TOperation>()
        {
            return typeof(TOperation).FullName; //TODO: investigate
            //return this.GetInstance(typeof(TOperation)).GetType().FullName;
        }

        protected double GetAggregateEdgeMetricStatistic(OPSpecialization callee, OPSpecialization caller, string metric, string statistic)
        {
            VariableDistributionSummary distribution = this.GetAggregateEdgeSummary(caller, callee, metric);
            return distribution[statistic];
        }

        protected double GetAggregateEdgeMetric(OPSpecialization callee, OPSpecialization caller, string metric)
        {
            VariableDistributionSummary distribution = this.GetAggregateEdgeSummary(caller, callee, metric);
            if (distribution.Min != distribution.Max)
            {
                throw new Exception($"Given metric value is a distribution. Look up individual statistics instead.");
            }
            return distribution.Min;
        }


        //TODO: should these two methods be moved to a helper class?
        protected Dictionary<AggregateInvocation, VariableDistributionSummary[]> GenerateAggregates()
        {
            Dictionary<AggregateInvocation, VariableDistributionSummary[]> aggregates = new Dictionary<AggregateInvocation, VariableDistributionSummary[]>();
            foreach (CallGraphEdge rootInvocation in Tracer.RootCall.GetChildren())
            {
                PopulateAggregates(rootInvocation, aggregates);
            }
            return aggregates;
        }

        //Recursively populates aggregated metrics
        protected void PopulateAggregates(CallGraphEdge edge,
            Dictionary<AggregateInvocation, VariableDistributionSummary[]> aggregates)
        {
            void mergeInvocationMetrics(AggregateInvocation inv, VariableDistributionSummary[] metrics)
            {
                if (aggregates.TryGetValue(inv, out VariableDistributionSummary[] aggregatedMetrics))
                {
                    Debug.Assert(aggregatedMetrics.Length == metrics.Length);
                    for (int i = 0; i < metrics.Length; i++)
                    {
                        aggregatedMetrics[i].MergeSummary(metrics[i]);
                    }
                }
                else
                {
                    aggregates[inv] = metrics.Select((VariableDistributionSummary summary) => summary.Clone()).ToArray();
                }
            }
            if (!this.Tracer.TryGetRecord(edge, out VariableDistributionSummary[] edgeData))
            { throw new InvalidOperationException(); }

            OPSpecialization callee = edge.Operation;
            OPSpecialization caller = edge.ParentEdge.Operation;
            if (caller.IsRoot)
            {
                AggregateInvocation globalAggregate = new AggregateInvocation(OPSpecialization.ALL, OPSpecialization.ROOT);
                mergeInvocationMetrics(globalAggregate, edgeData);
            }
            AggregateInvocation invocation = new AggregateInvocation(callee, caller);
            mergeInvocationMetrics(invocation, edgeData);
            AggregateInvocation operationAggregatesIn = new AggregateInvocation(callee, OPSpecialization.ALL);
            mergeInvocationMetrics(operationAggregatesIn, edgeData);

            foreach (CallGraphEdge childEdge in edge.GetChildren())
            {
                PopulateAggregates(childEdge, aggregates);
            }
        }

        public double GetMetric(string metric)
        {
            return GetAggregateEdgeMetric(OPSpecialization.ALL, OPSpecialization.ROOT, metric);
        }

        public double GetMetricStatistic(string metric, string statistic)
        {
            return GetAggregateEdgeMetricStatistic(OPSpecialization.ALL, OPSpecialization.ROOT, metric, statistic);
        }

        public double GetOperationMetric<TOperation>(string metric, OperationFunctor functor = OperationFunctor.Body)
        {
            return GetAggregateEdgeMetric(GetOperation<TOperation>(functor), OPSpecialization.ALL, metric);
        }

        public double GetOperationMetricStatistic<TOperation>(
            string metric,
            string statistic,
            OperationFunctor functor = OperationFunctor.Body)
        {
            return GetAggregateEdgeMetricStatistic(GetOperation<TOperation>(functor), OPSpecialization.ALL, metric, statistic);
        }

        public double GetAggregateEdgeMetric<TOperation, TCaller>(string metric,
            OperationFunctor functor = OperationFunctor.Body,
            OperationFunctor callerFunctor = OperationFunctor.Body)
        {
            return GetAggregateEdgeMetric(GetOperation<TOperation>(functor), GetOperation<TCaller>(callerFunctor), metric);
        }

        public double GetAggregateEdgeMetricStatistic<TOperation, TCaller>(
            string metric,
            string statistic,
            OperationFunctor functor = OperationFunctor.Body,
            OperationFunctor callerFunctor = OperationFunctor.Body)
        {
            return GetAggregateEdgeMetricStatistic(GetOperation<TOperation>(functor), GetOperation<TCaller>(callerFunctor), metric, statistic);
        }

        public IList<string> GetMetricNames()
        {
            return Tracer.Metrics.ToArray();
        }

        public IList<string> GetMetricStatisticNames(string metric)
        {
            int metricId = this.GetMetricId(metric);
            VariableDistributionSummary sampleSummary = this.Tracer.GetSampleRecord()[metricId];
            return sampleSummary.AsDictionary().Keys.ToArray();
        }

        #endregion

        #region CSV file outputting
        //mostly copied from QCTraceSimulator.StatisticsCollector
        //TODO: review and update
        const string csvSeparator = "\t";
        const string variableNameStatisticNameSeparator = ":";
        readonly string newline = System.Environment.NewLine;
        const string countColumnName = "Count";

        public IList<string> SummaryHeaders(IEnumerable<string> metrics)
        {
            VariableDistributionSummary[] sampleRecord = this.Tracer.GetSampleRecord();
            Debug.Assert(sampleRecord.Length > 0);
            //TODO: this is hacky
            string[] statistics = sampleRecord[0].AsDictionary().Keys
                .Where((string statistic) => !statistic.Equals(countColumnName))
                .ToArray();

            List<string> results = new List<string> { countColumnName };
            IEnumerable<string> nonCountMetricStatistics = metrics.SelectMany(
                (string metric) => statistics.Select(
                    (string statistic) => $"{metric}{variableNameStatisticNameSeparator}{statistic}"));

            results.AddRange(nonCountMetricStatistics);
            return results;
        }

        private IList<double> SummaryLine(IEnumerable<VariableDistributionSummary> record)
        {
            double count = record.First().Count;
            Debug.Assert(record.All(record => record.Count == count));
            List<double> results = new List<double> { count };
            //TODO: this is hacky
            IEnumerable<double> nonCountStats = record.SelectMany((VariableDistributionSummary summary) => summary.AsDictionary())
                .Where((KeyValuePair<string, double> entry) => !entry.Key.Equals(countColumnName))
                .Select((KeyValuePair<string, double> entry) => entry.Value);
            results.AddRange(nonCountStats);
            return results;
        }

        private string CSVHeader(string[] keyColumnsNames, IEnumerable<string> metrics)
        {
            string res = "";
            foreach (string columnName in keyColumnsNames)
            {
                res += columnName + csvSeparator;
            }
            IList<string> summaryHeaders = SummaryHeaders(metrics);
            Debug.Assert(summaryHeaders.Count >= 1);
            for (int i = 0; i < summaryHeaders.Count - 1; ++i)
            {
                res += summaryHeaders[i] + csvSeparator;
            }
            res += summaryHeaders[summaryHeaders.Count - 1] + newline;
            return res;
        }

        private string CSVLine(ICSVColumns key, IEnumerable<VariableDistributionSummary> record, string format)
        {
            string res = "";
            foreach (string name in key.GetRow())
            {
                res += name + csvSeparator;
            }
            IList<double> lineData = SummaryLine(record);
            Debug.Assert(lineData.Count >= 1);
            for (int i = 0; i < lineData.Count - 1; ++i)
            {
                res += lineData[i].ToString(format) + csvSeparator;
            }
            res += lineData[lineData.Count - 1] + newline;
            return res;
        }

        public Dictionary<string, string> ToCSV(string doubleFormatString = "G")
        {
            CheckCanQueryAndBuildAggregates();
            Dictionary<string, string> result = new Dictionary<string, string>();
            foreach (IMetricCollector collector in Tracer.Collectors)
            {
                result[collector.CollectorName()] = ToCSV(collector, doubleFormatString);
            }
            return result;
        }

        protected string ToCSV(IMetricCollector collector, string doubleFormatString = "G")
        {
            CheckCanQueryAndBuildAggregates();
            string res = "";
            IList<string> metrics = collector.Metrics();
            HashSet<int> metricIds = metrics.Select(metric => GetMetricId(metric)).ToHashSet(); ;
            res += CSVHeader(AggregateInvocation.ROOT_AGGREGATE.GetColumnNames(), metrics);
            foreach (KeyValuePair<AggregateInvocation, VariableDistributionSummary[]> entry in this.CachedAggregateMetrics)
            {
                IEnumerable<VariableDistributionSummary> filteredMetrics = entry.Value.Where((_, i) => metricIds.Contains(i));
                res += CSVLine(entry.Key, filteredMetrics, doubleFormatString);
            }
            return res;
        }

        public string ToCombinedCSV(string doubleFormatString = "G")
        {
            CheckCanQueryAndBuildAggregates();
            string res = "";
            res += CSVHeader(AggregateInvocation.ROOT_AGGREGATE.GetColumnNames(), Tracer.Metrics);
            foreach (KeyValuePair<AggregateInvocation, VariableDistributionSummary[]> entry in this.CachedAggregateMetrics)
            {
                res += CSVLine(entry.Key, entry.Value, doubleFormatString);
            }
            return res;
        }

        #endregion
    }
}
