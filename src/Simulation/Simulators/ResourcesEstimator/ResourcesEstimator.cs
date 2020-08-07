// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.Text;
using Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime;
using Microsoft.Quantum.Simulation.Simulators.NewTracer;
using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;

namespace Microsoft.Quantum.Simulation.Simulators
{
    /// <summary>
    /// The ResourceEstimator estimates statistics about how many resources
    /// the given operation needs for execution.
    /// The resources it calculates are:
    /// <ol>
    ///   <li>Primitive operations count</li>
    ///   <li>Qubits depth (max number of qubits allocated at any given point)</li>
    ///   <li>Gates width (total number of gates used for the computation)</li>
    /// </ol>
    /// </summary>
    public partial class ResourcesEstimator : TracerSimulator
    {
        /// <summary>
        /// The ResourceEstimator is based on <see cref="TracerSimulator"/>; this returns
        /// the correct configuration expected by the ResourceEstimator and what get used when
        /// a new instance is created with no parameters. It is
        /// optimized for performance and metrics collection.
        /// </summary>
        public static NewTracerConfiguration RecommendedConfig() =>
            new NewTracerConfiguration
            {
                CallStackDepthLimit = 1,

                ThrowOnUnconstrainedMeasurement = false,
                UseDistinctInputsChecker = false,
                UseInvalidatedQubitsUseChecker = false,

                UsePrimitiveOperationsCounter = true,
                UseDepthCounter = true,
                UseWidthCounter = true
            };

        /// <summary>
        /// Parameter-less constructor. It initializes the ResourceEstimator
        /// with a QCTraceSimulatorConfiguration as returned by <see cref="RecommendedConfig"/>.
        /// </summary>
        public ResourcesEstimator() : this(RecommendedConfig())
        {
        }

        /// <summary>
        /// It initializes the ResourceEstimator with the given QCTraceSimulatorConfiguration.
        /// It is recommended to use <see cref="RecommendedConfig"/> to create a new config instance
        /// and tweak it, to make sure the data collection is correctly configured.
        /// </summary>
        public ResourcesEstimator(NewTracerConfiguration config) : base(config)
        {
        }

        /// <summary>
        /// Returns the label to use for the given metric. If the metric should be skipped
        /// it returns null. Otherwise, it returns the same metric's name or some other alias.
        /// </summary>
        public virtual string? GetMetricLabel(string name)
        {
            if (name == MetricsNames.DepthCounter.StartTimeDifference ||
                name == MetricsNames.WidthCounter.InputWidth ||
                name == MetricsNames.WidthCounter.ReturnWidth)
            {
                return null;
            }
            else if (name == MetricsNames.WidthCounter.ExtraWidth)
            {
                return "Width";
            }
            else
            {
                return name;
            }
        }

        /// <summary>
        /// <para>Returns the values collected as a DataTable with the first
        /// column two columns: the metric name and its value.
        /// The metric name column is marked as PrimaryKey
        /// for easy access.
        /// </para>
        /// <para>
        /// The table looks like this:
        /// <pre>
        ///  -------------------------
        ///  | Metric        | Sum   |
        ///  -------------------------
        ///  | QubitsCount   | 100   |
        ///  | T             | 10000 |
        ///  ...
        ///  -------------------------
        /// </pre>
        /// </para>
        /// </summary>
        public virtual DataTable Data
        {
            get
            {
                //TODO: how should this be done instead?
                string MetricString = "Metric";
                string SumString = "Sum";
                string MaxString = "Max";

                DataTable table = new DataTable();

                table.Columns.Add(new DataColumn { DataType = typeof(string), ColumnName = MetricString });
                table.Columns.Add(new DataColumn { DataType = typeof(double), ColumnName = SumString });
                table.Columns.Add(new DataColumn { DataType = typeof(double), ColumnName = MaxString });
                table.PrimaryKey = new DataColumn[] { table.Columns[0] };

                foreach(string metric in this.GetMetricNames())
                {
                    string? label = GetMetricLabel(metric);
                    if (label == null) continue;

                    DataRow row = table.NewRow();
                    row[MetricString] = label;
                    row[SumString] = this.GetMetricStatistic(metric, SumString);
                    row[MaxString] = this.GetMetricStatistic(metric, MaxString);
                    table.Rows.Add(row);
                }
                return table;
            }
        }

        /// <summary>
        /// Returns <see cref="Data"/> in TSV format where the key is the Metric name,
        /// and the value is the statistics in tab-seperated format.
        /// </summary>
        public virtual string ToTSV()
        {
            var content = new StringBuilder();
            var table = Data;

            content.Append(table.Columns[0].ColumnName.PadRight(15)).Append('\t');
            var columns = table.Columns.Cast<DataColumn>().Skip(1).Select(c => c.ColumnName.PadRight(15));
            content.Append(string.Join("\t", columns));

            foreach(DataRow r in table.Rows)
            {
                content.Append('\n');
                content.Append(r[0].ToString().PadRight(15)).Append('\t');
                content.Append(string.Join("\t", r.ItemArray.Skip(1).Select(i => i.ToString())));
            }

            return content.ToString();
        }
    }
}
