using NewTracer.CallGraph;
using NewTracer.MetricCollection;
using NewTracer.Utils;
using Microsoft.Quantum.Simulation.Common;
using System.Collections.Generic;
using System.Linq;
using NewTracer.MetricCollectors;
using Microsoft.Quantum.Simulation.QuantumProcessor;
using System;
using Microsoft.Quantum.Simulation.Core;
using System.Diagnostics;

namespace NewTracer
{
    public class NewTracerCore : MultiSinkQuantumProcessor
    {
        private readonly IMetricCollector[] Collectors;
        private readonly Stack<IStackRecord>[] StackRecords;

        private readonly CallGraphEdge RootCall;

        private CallGraphEdge CurrentCall;
        private int CurrentCallGraphDepth;
        private int NextFreeEdgeId;

        //variables sorted first by the order of 'Collectors', and then within by the ordering given by the listener
        private readonly Dictionary<CallGraphEdge, VariableDistributionSummary[]> TracerData;


        private Dictionary<AggregateInvocation, VariableDistributionSummary[]> CachedAggregateMetrics;

        private readonly string[] Metrics;

        //Does not register IQuantumProcessors!!! rethink this flow.
        public NewTracerCore(IEnumerable<IMetricCollector> allMetricCollectors)
        {
            //TODO: check for uniqueness of metric names in Collectors
            if (allMetricCollectors == null || allMetricCollectors.Count() == 0)
            {
                throw new ArgumentException("No metric collectors provided.");
            }
            this.Collectors = allMetricCollectors.ToArray();
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

        public static NewTracerCore CreateCore(ICollection<IMetricCollector> metricCollectors, bool throwOnUnconstrainedMeasurement = true)
        {
            if (metricCollectors == null || metricCollectors.Count == 0)
            {
                throw new ArgumentException("No metric collectors provided");
            }
            MeasurementAssertTracker measurementTracker = new MeasurementAssertTracker(throwOnUnconstrainedMeasurement);

            MultiSinkQuantumProcessor decomposerFanout = new MultiSinkQuantumProcessor(measurementTracker); //measure tracker is the core IQP
            decomposerFanout.RegisterSinks(metricCollectors);
            IQuantumProcessor decomposer = new DefaultDecomposer(decomposerFanout);

            IEnumerable<IMetricCollector> allCollectors = metricCollectors.Append(measurementTracker);
            NewTracerCore tracer = new NewTracerCore(allCollectors);
            tracer.Core = decomposer; //registering the decomposer and thus the trackers for IQP events
            return tracer;
        }

        public static SimulatorBase CreateTracer(ICollection<IMetricCollector> metricCollectors, 
            bool throwOnUnconstrainedMeasurement, out NewTracerCore tracerCore)
        {
            tracerCore = NewTracerCore.CreateCore(metricCollectors, throwOnUnconstrainedMeasurement);

            IQubitTraceSubscriber[] qubitTraceCollectors = tracerCore.Collectors
                .Select(collector => collector as IQubitTraceSubscriber)
                .Where(subscriber => subscriber != null)
                .ToArray();

            IQubitManager qubitManager = new TraceableQubitManager(qubitTraceCollectors);
            return new QuantumProcessorDispatcher(tracerCore, qubitManager);
        }

        public static SimulatorBase DefaultTracer(out NewTracerCore tracerCore)
        {
            GateTracker gateTracker = new GateTracker();
            WidthTracker widthTracker = new WidthTracker();
            DepthCounter depthTracker = new DepthCounter();

            IMetricCollector[] metricCollectors = new IMetricCollector[]
            {
                gateTracker,
                widthTracker,
                depthTracker
            };

            return CreateTracer(metricCollectors, true, out tracerCore);
        }

        public static SimulatorBase DefaultTracer()
        {
            return DefaultTracer(out _);
        }

        public override void OnOperationStart(ICallable op, IApplyData arguments)
        {
            this.CachedAggregateMetrics = null; //flushing cache as it is now outdated
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
            base.OnOperationStart(op, arguments);
        }

        public override void OnOperationEnd(ICallable op, IApplyData arguments)
        {
            base.OnOperationEnd(op, arguments);
            if (!this.IsExecuting() || this.CurrentCallGraphDepth <= 0 || this.CurrentCall.ParentEdge == null
                || this.CurrentCall.Operation.FullName != op.FullName || this.CurrentCall.Operation.Variant != op.Variant)
            {
                throw new InvalidOperationException("An error has ocurred - invalid call graph state.");
            }
            VariableDistributionSummary[] edgeVariableSummaries = this.LookupVariableSummaries(this.CurrentCall);
            int v = 0;
            for (int i = 0; i < Collectors.Length; i++)
            {
                IMetricCollector listener = Collectors[i];
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

        protected void CheckCanQuery()
        {
            if (this.IsExecuting())
            {
                throw new QueryingTracerResultsDuringExecutionException();
            }
            if (this.CachedAggregateMetrics == null)
            {
                //TODO: make this logic concurrency-safe
                this.CachedAggregateMetrics = GenerateAggregates();
            }
        }

        protected VariableDistributionSummary[] LookupVariableSummaries(CallGraphEdge edge)
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


        protected VariableDistributionSummary[] GetAggregateEdgeMetrics(OPSpecialization caller, OPSpecialization callee)
        {
            this.CheckCanQuery();
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
            for (int m = 0; m < this.Metrics.Length; m++)
            {
                if (this.Metrics[m].Equals(metric, StringComparison.InvariantCultureIgnoreCase))
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
            foreach (CallGraphEdge rootInvocation in this.RootCall.GetChildren())
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
            VariableDistributionSummary[] edgeData = this.TracerData[edge];
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
            return GetAggregateEdgeMetric(OPSpecialization.ROOT, OPSpecialization.ALL, metric);
        }

        public double GetMetricStatistic(string metric, string statistic)
        {
            return GetAggregateEdgeMetricStatistic(OPSpecialization.ROOT, OPSpecialization.ALL, metric, statistic);
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
            return this.Metrics.ToArray();
        }

        public IList<string> GetMetricStatisticNames(string metric)
        {
            int metricId = this.GetMetricId(metric);
            VariableDistributionSummary sampleSummary = this.TracerData.First().Value[metricId]; //TOOD: use a better way
            return sampleSummary.AsDictionary().Keys.ToArray();
        }

        //mostly copied from QCTraceSimulator.StatisticsCollector
        //TODO: review and update

        #region Functionality to produce CSV file
        const string csvSeparator = "\t";
        const string variableNameStatisticNameSeparator = ":";
        readonly string newline = Environment.NewLine;
        const string countColumnName = "Count";

        public IList<string> SummaryHeaders(IEnumerable<string> metrics)
        {
            VariableDistributionSummary[] sampleRecord = this.TracerData.First().Value;
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
            CheckCanQuery();
            Dictionary<string, string> result = new Dictionary<string, string>();
            foreach(IMetricCollector collector in this.Collectors)
            {
                result[collector.CollectorName()] = ToCSV(collector, doubleFormatString);
            }
            return result;
        }

        protected string ToCSV(IMetricCollector collector, string doubleFormatString = "G")
        {
            CheckCanQuery();
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
            CheckCanQuery();
            string res = "";
            res += CSVHeader(AggregateInvocation.ROOT_AGGREGATE.GetColumnNames(), this.Metrics);
            foreach (KeyValuePair<AggregateInvocation, VariableDistributionSummary[]> entry in this.CachedAggregateMetrics)
            {
                res += CSVLine(entry.Key, entry.Value, doubleFormatString);
            }
            return res;
        }

        #endregion
    }
}