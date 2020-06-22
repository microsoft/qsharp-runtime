// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System.Collections.Generic;

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime
{
    //Temporary bridge for allowing collection of both types of metrics: aggregate and detailed
    //TODO: Would be better for aggregates to be calculated dynamically from the details instead of storing both - 
    //doing so would also ensure data consistency

    public interface IHybridStatisticsCollectorResults : IStatisticCollectorResults<CallGraphEdge>, IStatisticCollectorResults<CallGraphTreeEdge>
    {
        //Hiding shared inherited members to avoid interface ambiguity

        new string ToCSV(string doubleFormatString = "G");

        new string[] GetStatisticsNamesCopy();

        new string[] GetVariablesNamesCopy();

        new CallGraphEdgeTable ToTable();
    }

    public class HybridStatisticsCollector : IHybridStatisticsCollectorResults
    {
        private StatisticsCollector<CallGraphTreeEdge> DetailedStatistics;
        private StatisticsCollector<CallGraphEdge> AggregateStatistics;

        public HybridStatisticsCollector(string[] variableNames, IList<IDoubleStatistic> statisticsToCollect)
        {
            this.DetailedStatistics = new StatisticsCollector<CallGraphTreeEdge>(variableNames, statisticsToCollect);
            this.AggregateStatistics = new StatisticsCollector<CallGraphEdge>(variableNames, statisticsToCollect);
        }
        public void AddSample(CallGraphTreeEdge key, double[] sampleData)
        {
            this.DetailedStatistics.AddSample(key, sampleData);
            this.AggregateStatistics.AddSample(key.ToCallGraphEdge(), sampleData);
        }

        public double GetStatistic(CallGraphEdge key, string variableName, string statisticName)
            => this.AggregateStatistics.GetStatistic(key, variableName, statisticName);

        public double[] GetStatistics(CallGraphEdge key, string variableName)
            => this.AggregateStatistics.GetStatistics(key, variableName);

        public double GetStatistic(CallGraphTreeEdge key, string variableName, string statisticName)
            => this.DetailedStatistics.GetStatistic(key, variableName, statisticName);

        public double[] GetStatistics(CallGraphTreeEdge key, string variableName)
            => this.DetailedStatistics.GetStatistics(key, variableName);

        public string[] GetStatisticsNamesCopy()
            => this.AggregateStatistics.GetStatisticsNamesCopy();

        public string[] GetVariablesNamesCopy()
            => this.AggregateStatistics.GetVariablesNamesCopy();

        public string ToCSV(string doubleFormatString = "G")
            => this.AggregateStatistics.ToCSV(doubleFormatString);

        public CallGraphEdgeTable ToTable()
            => this.AggregateStatistics.ToTable();
    }
}
