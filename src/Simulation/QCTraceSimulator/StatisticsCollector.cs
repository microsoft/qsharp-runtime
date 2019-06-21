namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime
{
    using System;
    using System.Collections.Generic;
    using System.Diagnostics;

    /// <summary>
    /// Data stored per an edge of a call graph
    /// </summary>
    public struct CallGraphEdgeRow
    {
        /// <summary>
        /// Array of strings describing an edge of a call graph
        /// </summary>
        public string[] KeyRow;
        /// <summary>
        /// Two dimensional array that contains metrics and statistics.
        /// First index corresponds to a metric, the second to a statistic.
        /// </summary>
        public double[,] DataRow;
        /// <summary>
        /// Total number of samples collected per edge of the call-graph
        /// </summary>
        public long  NumberOfSamples;
    }

    /// <summary>
    /// Simple representations of information collected per edge of a call graph
    /// </summary>
    public struct CallGraphEdgeTable
    {
        /// <summary>
        /// Names of keys used to identify an edge of the call graph
        /// </summary>
        public string[] keyColumnNames;

        /// <summary>
        /// Metrics collected per edge of a call-graph
        /// </summary>
        public string[] metricNames;
        /// <summary>
        /// Statistics collected for each metric.
        /// </summary>
        public string[] statisticsNames;

        /// <summary>
        /// Data associated to all call-graph edges
        /// </summary>
        public IEnumerable<CallGraphEdgeRow> rows;
    }

    /// <summary>
    /// Intended for reading collected statistics
    /// </summary>
    public interface IStatisticCollectorResults<TKey>
    {
        /// <summary>
        /// Gets a statistics for a given key, variable name and statistic name. The array of possible names is returned by 
        /// <see cref="GetVariablesNamesCopy"/>. The array of possible names is
        /// returned by <see cref="GetStatisticsNamesCopy"/>.
        /// </summary>
        double GetStatistic(TKey key, string variableName, string statisticName);

        /// <summary>
        /// Gets array of statistics for a given key and variable name. The list of possible names is returned by 
        /// <see cref="GetVariablesNamesCopy"/>. Names of statistics corresponding to each array element are 
        /// returned by <see cref="GetStatisticsNamesCopy"/>.
        /// </summary>
        double[] GetStatistics(TKey key, string variableName);

        /// <summary>
        /// Returns names of the statistics being collected.
        /// </summary>
        string[] GetStatisticsNamesCopy();

        /// <summary>
        /// Returns names of the variable names for which statistics are collected.
        /// </summary>
        string[] GetVariablesNamesCopy();

        /// <summary>
        /// Creates string with all the statistics results in CSV format. 
        /// </summary>
        string ToCSV(string doubleFormatString = "G");

        /// <summary>
        /// Creates a simple data structure with all collected statistics
        /// </summary>
        CallGraphEdgeTable ToTable();
    }

    public class StatisticsCollector<TKey> : IStatisticCollectorResults<TKey> where TKey : class, ICSVColumns, new()
    {
        readonly string[] variableNames;
        readonly string[] statisticsNames;
        readonly int numberOfVariables;
        readonly List<IDoubleStatistic> statisticsToCollect;
        readonly Dictionary<string, int> variableNameToId;
        readonly Dictionary<string, int> statisticNameToId;

        /// <summary>
        /// Keeps track of all data collected so far.
        /// </summary>
        public Dictionary<TKey, MultivariableRecord> Data { get; }

        /// <summary>
        /// Statistic that are going to be collected by default if they were not specified explicitly.
        /// </summary>
        public static IList<IDoubleStatistic> DefaultStatistics()
        {
            return new IDoubleStatistic[] { new MomentsStatistic(), new MinMaxStatistic() };
        }

        public StatisticsCollector(string[] variableNames) :
            this(variableNames, DefaultStatistics())
        {
        }

        public StatisticsCollector(string[] variableNames, IList<IDoubleStatistic> statisticsToCollect)
        {
            Data = new Dictionary<TKey, MultivariableRecord>();
            this.numberOfVariables = variableNames.Length;
            this.variableNames = Utils.DeepClone(variableNames);
            this.statisticsToCollect = new List<IDoubleStatistic>(statisticsToCollect.Count);
            foreach (IDoubleStatistic stat in statisticsToCollect)
            {
                this.statisticsToCollect.Add(stat.GetNewInstance());
            }

            statisticsNames = statisticsToCollect.GetStatisticsNames();
            statisticNameToId = Utils.IListToDictionary(statisticsNames);
            variableNameToId = Utils.IListToDictionary(variableNames);
        }

        public void AddSample(TKey key, double[] sampleData)
        {
            Debug.Assert(sampleData != null);
            Debug.Assert(sampleData.Length == numberOfVariables);

            if (Data.ContainsKey(key))
            {
                Data[key].AddSample(sampleData);
            }
            else
            {
                MultivariableRecord newRec = InitializeKey(key);
                newRec.AddSample(sampleData);
            }
        }

        private MultivariableRecord InitializeKey(TKey key)
        {
            MultivariableRecord newRec = new MultivariableRecord(numberOfVariables, statisticsToCollect);
            Data.Add(key, newRec);
            return newRec;
        }

        public void PreInitializeKey(TKey key)
        {
            InitializeKey(key);
        }

        /// <summary>
        /// Gets array of statistics for a given key and variable name. The list of possible names is returned by 
        /// <see cref="GetVariablesNamesCopy"/>. Names of statistics corresponding to each array element are 
        /// returned by <see cref="GetStatisticsNamesCopy"/>.
        /// </summary>
        public double[] GetStatistics(TKey key, string variableName)
        {
            int variableId = variableNameToId[variableName];
            return Data[key].GetVariableStatistics(variableId);
        }

        /// <summary>
        /// Gets a statistics for a given key, variable name and statistic name. The array of possible names is returned by 
        /// <see cref="GetVariablesNamesCopy"/>. The array of possible names is
        /// returned by <see cref="GetStatisticsNamesCopy"/>.
        /// </summary>
        public double GetStatistic(TKey key, string variableName, string statisticName)
        {
            int statisticId = statisticNameToId[statisticName];
            return GetStatistics(key, variableName)[statisticId];
        }

        /// <summary>
        /// Returns names of the statistics being collected.
        /// </summary>
        public string[] GetStatisticsNamesCopy()
        {
            return Utils.DeepClone(statisticsNames);
        }

        /// <summary>
        /// Returns names of the variable names for which statistics are collected.
        /// </summary>
        public string[] GetVariablesNamesCopy()
        {
            return Utils.DeepClone(variableNames);
        }

        public TKey[] GetKeysCopy()
        {
            TKey[] res = new TKey[Data.Keys.Count];
            Data.Keys.CopyTo(res, 0);
            return res;
        }

        #region Functionality to produce CSV file
        const string csvSeparator = "\t";
        const string variableNameStatisticNameSeparator = ":";
        readonly string newline = Environment.NewLine;
        const string countColumnName = "Count";

        public string[] SummaryHeaders()
        {
            string[] res = new string[ 1 + statisticsNames.Length * variableNames.Length];
            res[0] = countColumnName;
            for ( int i =0; i < variableNames.Length; ++i )
            {
                for( int j =0; j < statisticsNames.Length; ++j )
                {
                    res[1 + i * statisticsNames.Length + j] = variableNames[i] + variableNameStatisticNameSeparator + statisticsNames[j];
                }
            }
            return res;
        }

        private double[] SummaryLine(MultivariableRecord record)
        {
            double[] res = new double[ 1 + statisticsNames.Length * variableNames.Length];
            res[0] = record.NumberOfSamples;
            for (int i = 0; i < variableNames.Length; ++i)
            {
                double[] stats = record.GetVariableStatistics(i);
                for (int j = 0; j < statisticsNames.Length; ++j)
                {
                    res[1 + i * statisticsNames.Length + j] = stats[j];
                }
            }
            return res;
        }

        private double[,] DataRow(MultivariableRecord record)
        {
            double[,] res = new double[variableNames.Length, statisticsNames.Length];
            for (int i = 0; i < variableNames.Length; ++i)
            {
                double[] stats = record.GetVariableStatistics(i);
                for (int j = 0; j < statisticsNames.Length; ++j)
                {
                    res[i,j] = stats[j];
                }
            }
            return res;
        }

        private string CSVHeader( string[] keyColumnsNames)
        {
            string res = "";
            foreach( string columnName in keyColumnsNames )
            {
                res += columnName + csvSeparator;
            }
            string[] summaryHeaders = SummaryHeaders();
            Debug.Assert(summaryHeaders.Length >= 1);
            for( int i = 0; i < summaryHeaders.Length - 1; ++i )
            {
                res += summaryHeaders[i] + csvSeparator;
            }
            res += summaryHeaders[summaryHeaders.Length - 1] + newline;
            return res;
        }

        private string CSVLine( TKey key, MultivariableRecord record, string format )
        {
            string res = "";
            foreach (string name in key.GetRow() )
            {
                res += name + csvSeparator;
            }
            double[] lineData = SummaryLine(record);
            Debug.Assert(lineData.Length >= 1);
            for (int i = 0; i < lineData.Length - 1; ++i)
            {
                res += lineData[i].ToString(format) + csvSeparator;
            }
            res += lineData[lineData.Length - 1] + newline;
            return res;
        }

        private IEnumerable<CallGraphEdgeRow> Rows()
        {
            foreach (KeyValuePair<TKey, MultivariableRecord> a in Data)
            {
                yield return new CallGraphEdgeRow { KeyRow = a.Key.GetRow(), NumberOfSamples = a.Value.NumberOfSamples, DataRow = DataRow(a.Value) };
            }
        }

        /// <summary>
        /// Creates string with all the statistics results in CSV format. 
        /// </summary>
        public string ToCSV( string doubleFormatString = "G" )
        {
            string res = "";
            res += CSVHeader( (new TKey()).GetColumnNames() );
            foreach( KeyValuePair<TKey,MultivariableRecord> a in Data )
            {
                res += CSVLine( a.Key, a.Value, doubleFormatString);
            }
            return res;
        }

        public CallGraphEdgeTable ToTable()
        {
            return new CallGraphEdgeTable {
                statisticsNames = GetStatisticsNamesCopy(),
                metricNames = GetVariablesNamesCopy(),
                keyColumnNames = new TKey().GetColumnNames(),
                rows = Rows()
            };
        }
        #endregion
    }
}