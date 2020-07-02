using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime;
using NewTracer.CallGraph;
using NewTracer.MetricCollection;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using CallGraphEdge = NewTracer.CallGraph.CallGraphEdge;

namespace NewTracer.Data
{
    public class TracerResults
    {
        private readonly CallGraphEdge RootCall;

        private readonly Dictionary<CallGraphEdge, VariableDistributionSummary[]> CallGraphMetrics;

        private readonly Dictionary<AggregateInvocation, VariableDistributionSummary[]> AggregateMetrics;

        private readonly string[] Metrics;
        private readonly Dictionary<string, int> MapMetricsToIds;

        internal TracerResults(CallGraphEdge rootEdge, Dictionary<CallGraphEdge, VariableDistributionSummary[]> results,
            IList<string> metrics)
        {
            if (metrics == null || metrics.Count == 0)
            { throw new ArgumentException("No metrics provided"); }

            this.Metrics = metrics.ToArray();
            this.MapMetricsToIds = metrics
                .Select((string metric, int index) => new { metric, index })
                .ToDictionary(
                    (pair) => pair.metric,
                    (pair) => pair.index
            );
            //NOT PERFORMANT CURRENTLY
            this.RootCall = rootEdge.Clone(null);
            this.CallGraphMetrics = results.ToDictionary(
                (entry) => entry.Key,
                (entry) => entry.Value.Select((VariableDistributionSummary metric) => metric.Clone()).ToArray()
            ); //TODO: using uncloned CallGraphEdge's in new dictionary - works as Ids the same but sketchy. Change?

            if (!this.CallGraphMetrics.TryGetValue(this.RootCall, out _))
            {
                throw new ArgumentException("Invalid result provided - no key for root.");
            }
            this.AggregateMetrics = GenerateAggregates(this.RootCall, this.CallGraphMetrics); //TODO: should this be delayed? 
        }

        public TracerResults Clone()
        {
            return new TracerResults(this.RootCall, this.CallGraphMetrics, this.GetMetricNames());
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
            return MapMetricsToIds.Keys.ToArray();
        }

        public IList<string> GetMetricStatisticNames(string metric)
        {
            int metricId = this.GetMetricId(metric);
            VariableDistributionSummary sampleSummary = this.CallGraphMetrics[this.RootCall][metricId];
            return sampleSummary.AsDictionary().Keys.ToArray();
        }

        protected VariableDistributionSummary[] GetAggregateEdgeSummaries(OPSpecialization caller, OPSpecialization callee)
        {
            return this.AggregateMetrics[this.GetAggregateInvocation(caller, callee)];
        }

        protected VariableDistributionSummary GetAggregateEdgeSummary(OPSpecialization caller, OPSpecialization callee, string metric)
        {
            int metricId = this.GetMetricId(metric);
            return this.GetAggregateEdgeSummaries(caller, callee)[metricId];
        }

        protected int GetMetricId(string metric)
        {
            if (!this.MapMetricsToIds.TryGetValue(metric, out int id))
            {
                throw new ArgumentException($"Given metric {metric} was not tracked by the tracer.");
            }
            return id;
        }

        protected OPSpecialization GetOperation<TOperation>(OperationFunctor functor)
        {
            return new OPSpecialization(GetOperationName<TOperation>(), functor);
        }

        protected AggregateInvocation GetAggregateInvocation(OPSpecialization caller, OPSpecialization callee)
        {
            AggregateInvocation invocation = new AggregateInvocation(callee, caller);
            if (!this.AggregateMetrics.ContainsKey(invocation))
            {
                throw new ArgumentException("Provided aggregate invocation necer occurred during tracer execution.");
            }
            return invocation;
        }

        protected string GetOperationName<TOperation>()
        {
            return typeof(TOperation).FullName;
            //TODO: does this work? or do simulator operation overrides necessitate the below
            //return this.GetInstance(typeof(T)).GetType().FullName;
        }


        //TODO: should these two methods be moved to a helper class?
        protected static Dictionary<AggregateInvocation, VariableDistributionSummary[]> GenerateAggregates(CallGraphEdge root,
            Dictionary<CallGraphEdge, VariableDistributionSummary[]> tracerData)
        {
            Dictionary<AggregateInvocation, VariableDistributionSummary[]> aggregates = new Dictionary<AggregateInvocation, VariableDistributionSummary[]>();
            GenerateAggregates(root, tracerData, aggregates);
            return aggregates;
        }

        //Recursively populates aggregated metrics
        protected static void GenerateAggregates(CallGraphEdge edge, Dictionary<CallGraphEdge, VariableDistributionSummary[]> tracerData,
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
            OPSpecialization callee = edge.Operation;
            OPSpecialization caller = edge.ParentEdge?.Operation;
            AggregateInvocation invocation = new AggregateInvocation(callee, caller);
            AggregateInvocation operationAggregatesIn = new AggregateInvocation(callee, OPSpecialization.ALL);

            VariableDistributionSummary[] edgeData = tracerData[edge];

            // Adding aggregates for this invocation
            mergeInvocationMetrics(invocation, edgeData);
            mergeInvocationMetrics(operationAggregatesIn, edgeData);

            foreach (CallGraphEdge childEdge in edge.GetChildren())
            {
                GenerateAggregates(childEdge, tracerData, aggregates);
            }
        }

        //mostly copied from QCTraceSimulator.StatisticsCollector
        //TODO: review and update

        #region Functionality to produce CSV file
        const string csvSeparator = "\t";
        const string variableNameStatisticNameSeparator = ":";
        readonly string newline = Environment.NewLine;
        const string countColumnName = "Count";

        public IList<string> SummaryHeaders()
        {
            VariableDistributionSummary[] sampleRecord = this.CallGraphMetrics.First().Value;
            Debug.Assert(sampleRecord.Length > 0);
            //TODO: this is hacky
            string[] statistics = sampleRecord[0].AsDictionary().Keys
                .Where((string statistic) => !statistic.Equals(countColumnName))
                .ToArray();

            List<string> results = new List<string> { countColumnName };
            IEnumerable<string> nonCountMetricStatistics = this.Metrics.SelectMany(
                (string metric) => statistics.Select(
                    (string statistic) => $"{metric}{variableNameStatisticNameSeparator}{statistic}"));

            results.AddRange(nonCountMetricStatistics);
            return results;
        }

        private IList<double> SummaryLine(VariableDistributionSummary[] record)
        {
            double count = record[0].Count;
            Debug.Assert(record.All(record => record.Count == count));
            List<double> results = new List<double> { count };
            //TODO: this is hacky
            IEnumerable<double> nonCountStats = record.SelectMany((VariableDistributionSummary summary) => summary.AsDictionary())
                .Where((KeyValuePair<string, double> entry) => !entry.Key.Equals(countColumnName))
                .Select((KeyValuePair<string, double> entry) => entry.Value);
            results.AddRange(nonCountStats);
            return results; 
        }

        private string CSVHeader(string[] keyColumnsNames)
        {
            string res = "";
            foreach (string columnName in keyColumnsNames)
            {
                res += columnName + csvSeparator;
            }
            IList<string> summaryHeaders = SummaryHeaders();
            Debug.Assert(summaryHeaders.Count >= 1);
            for (int i = 0; i < summaryHeaders.Count - 1; ++i)
            {
                res += summaryHeaders[i] + csvSeparator;
            }
            res += summaryHeaders[summaryHeaders.Count - 1] + newline;
            return res;
        }

        private string CSVLine(ICSVColumns key, VariableDistributionSummary[] record, string format)
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

        //TODO: old tracer seperated csv output by metric collector - implement similar functionality here
        public string ToCSV(string doubleFormatString = "G")
        {
            string res = "";
            res += CSVHeader(AggregateInvocation.ROOT_AGGREGATE.GetColumnNames());
            foreach (KeyValuePair<AggregateInvocation, VariableDistributionSummary[]> entry in this.AggregateMetrics)
            {
                res += CSVLine(entry.Key, entry.Value, doubleFormatString);
            }
            return res;
        }

        #endregion
    }
}