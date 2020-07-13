using System.Collections.Generic;
using System.Linq;
using Microsoft.Quantum.Simulation.QuantumProcessor;
using System;
using System.Diagnostics;
using Microsoft.Quantum.Simulation.Simulators.NewTracer.Tracing;
using Microsoft.Quantum.Simulation.Simulators.NewTracer.MetricCollection;
using Microsoft.Quantum.Simulation.Simulators.NewTracer.Utils;
using Microsoft.Quantum.Simulation.Simulators.NewTracer.MetricCollectors;
using Microsoft.Quantum.Simulation.Simulators.NewTracer.CallGraph;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulators.NewTracer.GateDecomposition;
using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer
{
    public enum PrimitiveOperationsGroups : int
    {
        CZ,
        CCZ,
        RZ,
        Measure,
        T
    }

    public class NewTracerConfiguration
    {
        public bool UseDistinctInputsChecker = false;

        public bool UseInvalidatedQubitsUseChecker = false;

        public bool UsePrimitiveOperationsCounter = false;

        public bool UseDepthCounter = false;

        public bool UseWidthCounter = false;

        public Dictionary<PrimitiveOperationsGroups, double> TraceGateTimes = 
            new Dictionary<PrimitiveOperationsGroups, double>()
        {
            { PrimitiveOperationsGroups.CZ, 0 },
            { PrimitiveOperationsGroups.CCZ, 0 },
            { PrimitiveOperationsGroups.RZ, 0 },
            { PrimitiveOperationsGroups.Measure, 0 },
            { PrimitiveOperationsGroups.T, 1 }
        };

        public bool ThrowOnUnconstrainedMeasurement = true;

        //TODO: not implemented
        public uint CallStackDepthLimit = uint.MaxValue;
    }

    public class NewTracerSim : QuantumProcessorDispatcher
    {
        internal TracingCore TracerCore;

        private Dictionary<AggregateInvocation, VariableDistributionSummary[]>? CachedAggregateMetrics;

        public override string Name => "NewTracer";

        //TODO: migrate over to own config class
        public NewTracerSim()
            :this(new NewTracerConfiguration())
        {
        }

        public NewTracerSim(NewTracerConfiguration config)
            : this(BuildMeasurementTracker(config), BuildNonMeasurementCollectors(config))
        {
        }

        //TODO: delete; just for testing
        public NewTracerSim(IMetricCollector measurementTracker, ICollection<IMetricCollector> otherCollectors, bool noDecomposition)
            : base(null, BuildQubitManager(measurementTracker, otherCollectors))
        {
            FanoutQuantumProcessor fanout = new FanoutQuantumProcessor(measurementTracker); //measure tracker is the core IQP
            fanout.RegisterSinks(otherCollectors);
            IEnumerable<IMetricCollector> allCollectors = otherCollectors.Append(measurementTracker);

            //we cannot pass the tracercore into the base constructor, so this is a hack to register it post construction
            this.QuantumProcessor = this.TracerCore = new TracingCore(fanout, allCollectors);
            this.OnOperationStart += QuantumProcessor.OnOperationStart;
            this.OnOperationEnd += QuantumProcessor.OnOperationEnd;

            this.OnOperationStart += (_, x) => this.CachedAggregateMetrics = null; //resetting cache when new data comes 
        }

        public NewTracerSim(IMetricCollector measurementTracker, ICollection<IMetricCollector> otherCollectors)
            : base(null, BuildQubitManager(measurementTracker, otherCollectors))
        {
            if (measurementTracker == null) { throw new ArgumentNullException(nameof(measurementTracker)); }
            if (otherCollectors == null) { otherCollectors = new IMetricCollector[] { }; }

            FanoutQuantumProcessor decomposerFanout = new FanoutQuantumProcessor(measurementTracker); //measure tracker is the core IQP
            decomposerFanout.RegisterSinks(otherCollectors);
            IQuantumProcessor decomposer = new DefaultDecomposer(decomposerFanout, this);
            IEnumerable<IMetricCollector> allCollectors = otherCollectors.Append(measurementTracker);

            //we cannot pass the tracercore into the base constructor, so this is a hack to register it post construction
            this.QuantumProcessor = this.TracerCore = new TracingCore(decomposer, allCollectors);
            this.OnOperationStart += QuantumProcessor.OnOperationStart;
            this.OnOperationEnd += QuantumProcessor.OnOperationEnd;

            this.OnOperationStart += (_, x) => this.CachedAggregateMetrics = null; //resetting cache when new data comes in
        }

        private static TraceableQubitManager BuildQubitManager(IMetricCollector measurementTracker,
            ICollection<IMetricCollector> otherCollectors)
        {
            IEnumerable<IMetricCollector> allCollectors = otherCollectors.Append(measurementTracker);
            IQubitTraceSubscriber[] qubitTraceSubscribers = allCollectors
              .Where(collector => collector is IQubitTraceSubscriber)
              .Cast<IQubitTraceSubscriber>()
              .ToArray();
            return new TraceableQubitManager(qubitTraceSubscribers);
        }

        protected static IMetricCollector BuildMeasurementTracker(NewTracerConfiguration config)
        {
            return new MeasurementAssertTracker(config.ThrowOnUnconstrainedMeasurement);
        }

        protected static ICollection<IMetricCollector> BuildNonMeasurementCollectors(NewTracerConfiguration config)
        {
            List<IMetricCollector> collectors = new List<IMetricCollector>();
            if (config.UsePrimitiveOperationsCounter)
            {
                collectors.Add(new GateTracker());
            }
            if (config.UseWidthCounter)
            {
                collectors.Add(new WidthTracker());
            }
            if (config.UseDepthCounter)
            {
                collectors.Add(new DepthCounter(config.TraceGateTimes));
            }
            if (config.UseInvalidatedQubitsUseChecker)
            {
                collectors.Add(new InvalidatedQubitUseChecker(true)); //TODO: why does the config object not have fields for this?
            }
            if (config.UseDistinctInputsChecker)
            {
                collectors.Add(new DistinctInputsChecker(true));
            }
            return collectors;
        }

        protected void CheckCanQueryAndBuildAggregates()
        {
            if (TracerCore.IsExecuting())
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
            for (int m = 0; m < TracerCore.Metrics.Length; m++)
            {
                if (TracerCore.Metrics[m].Equals(metric, StringComparison.InvariantCultureIgnoreCase))
                {
                    return m;
                }
            }
            throw new ArgumentException($"Given metric {metric} was not tracked by the tracer.");
        }

        protected string GetOperationName<TOperation>()
        {
            return typeof(TOperation).FullName;
            //TODO: does this work? or do simulator operation overrides necessitate the below
            //return this.GetInstance(typeof(T)).GetType().FullName;
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
            foreach (CallGraphEdge rootInvocation in TracerCore.RootCall.GetChildren())
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
            if (!this.TracerCore.TryGetRecord(edge, out VariableDistributionSummary[] edgeData))
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
            return TracerCore.Metrics.ToArray();
        }

        public IList<string> GetMetricStatisticNames(string metric)
        {
            int metricId = this.GetMetricId(metric);
            VariableDistributionSummary sampleSummary = this.TracerCore.GetSampleRecord()[metricId];
            return sampleSummary.AsDictionary().Keys.ToArray();
        }

        //mostly copied from QCTraceSimulator.StatisticsCollector
        //TODO: review and update

        #region Functionality to produce CSV file
        const string csvSeparator = "\t";
        const string variableNameStatisticNameSeparator = ":";
        readonly string newline = System.Environment.NewLine;
        const string countColumnName = "Count";

        public IList<string> SummaryHeaders(IEnumerable<string> metrics)
        {
            VariableDistributionSummary[] sampleRecord = this.TracerCore.GetSampleRecord();
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
            foreach (IMetricCollector collector in TracerCore.Collectors)
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
            res += CSVHeader(AggregateInvocation.ROOT_AGGREGATE.GetColumnNames(), TracerCore.Metrics);
            foreach (KeyValuePair<AggregateInvocation, VariableDistributionSummary[]> entry in this.CachedAggregateMetrics)
            {
                res += CSVLine(entry.Key, entry.Value, doubleFormatString);
            }
            return res;
        }

        #endregion
    }
}