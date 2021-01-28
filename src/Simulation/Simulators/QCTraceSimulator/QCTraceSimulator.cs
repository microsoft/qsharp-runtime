// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

/// <summary>
/// Types and functionality related to Quantum Computer Trace Simulator
/// </summary>
namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators
{
    using Microsoft.Quantum.Simulation.Core;
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Reflection;

    /// <summary>
    /// Groups of primitive operations counted by <see cref="QCTraceSimulator"/>.
    /// Used as a key for the <see cref="QCTraceSimulatorConfiguration.TraceGateTimes"/> 
    /// dictionary.
    /// </summary>
    public enum PrimitiveOperationsGroups : int
    {
        /// <summary>
        /// Controlled Pauli X gate, also known as CNOT
        /// </summary>
        CNOT,

        /// <summary>
        /// Any single qubit Clifford and Pauli gate.
        /// </summary>
        QubitClifford,

        /// <summary>
        /// Any single qubit rotation excluding T and Clifford gates
        /// </summary>
        R,

        /// <summary>
        /// Any measurement. 
        /// </summary>
        Measure, 

        /// <summary>
        /// This includes T gate, T_x = H.T.H, T_y = Hy.T.Hy 
        /// </summary>
        T
    }

    /// <summary>
    /// The configuration of <see cref="QCTraceSimulator"/>. 
    /// </summary>
    [Serializable]
    public class QCTraceSimulatorConfiguration
    {
        /// <summary>
        /// If set to <c>true</c>, the Distinct Inputs Checker component of QCTraceSimulator is used.
        /// If input to an operation containing non-distinct qubits is detected, a
        /// <see cref="DistinctInputsCheckerException"/> is thrown.
        /// For more details, please refer to the 
        /// "Quantum computer trace simulator/Distinct Inputs Checker" 
        /// documentation section.
        /// </summary>
        public bool UseDistinctInputsChecker = false;

        /// <summary>
        /// If set to <c>true</c>, the Invalidated Qubits Use Checker component
        /// of QCTraceSimulator is used. If the problem is detected,
        /// <see cref="InvalidatedQubitsUseCheckerException"/> is thrown.
        /// For more details, please refer to the 
        /// "Quantum computer trace simulator/Invalidated Qubits Use Checker" 
        /// documentation section.
        /// </summary>
        public bool UseInvalidatedQubitsUseChecker = false;

        /// <summary>
        /// If set to <c>true</c>, QCTraceSimulator collects primitive operation counts for each call graph edge.
        /// The names of the metrics collected by Primitive Operations Counter are listed in 
        /// <see cref="PrimitiveOperationsGroupsNames"/>.
        /// For more details, please refer to the 
        /// "Quantum computer trace simulator/Primitive Operations Counter" 
        /// documentation section.
        /// </summary>
        public bool UsePrimitiveOperationsCounter = false;

        /// <summary>
        /// If set to <c>true</c>, QCTraceSimulator collects operations depth per each call graph edge.
        /// The names of the metrics collected by the Depth Counter 
        /// are listed in <see cref="MetricsNames.DepthCounter"/>
        /// For more details, please refer to the 
        /// "Quantum computer trace simulator/Depth Counter" documentation section.
        /// </summary>
        public bool UseDepthCounter = false;

        /// <summary>
        /// If set to <c>true</c>, QCTraceSimulator collects information about the number of qubits used per call graph edge.
        /// The names of the metrics collected by the Width Counter 
        /// are listed in <see cref="MetricsNames.WidthCounter"/>. 
        /// For more details, please refer to the 
        /// "Quantum computer trace simulator/ Width Counter" documentation section.
        /// </summary>
        public bool UseWidthCounter = false;

        /// <summary>
        /// Controls if depth or width optimization is favored.
        /// If set to <c>true</c>, resulting circuit is optimized for depth by discouraging qubit reuse.
        /// If set to <c>false</c>, resulting circuit is optimized for width be encouraging qubit reuse.
        /// Optimization is only limited to reuse of qubits after they are released by user code.
        /// </summary>
        public bool OptimizeDepth = false;

        /// <summary>
        /// Specifies the time it takes to execute each gate.
        /// In other words, specifies the depth of each primitive operation. 
        /// These fields are used by the 
        /// Depth Counter component of <see cref="QCTraceSimulator"/> to compute the aggregate 
        /// depth of operations.
        /// </summary>
        public Dictionary<PrimitiveOperationsGroups, double> TraceGateTimes = GateTimes.TGatesOnly;

        /// <summary>
        /// If set to <c>true</c>, an <see cref="UnconstrainedMeasurementException"/> is thrown 
        /// every time there is an unconstrained measurement. For more details,
        /// please refer to the "Quantum computer trace simulator" documentation  section.
        /// </summary>
        public bool ThrowOnUnconstrainedMeasurement = true;

        /// <summary>
        /// Bounds the call stack depth for which information per call graph edge is stored.
        /// The depth of a given node in the call graph is the distance from the node to the root 
        /// of the call graph.
        /// </summary>
        public uint CallStackDepthLimit = uint.MaxValue;
    }

    /// <summary>
    /// Quantum Computer Trace Simulator. Simulates a trace of the execution of a quantum 
    /// program on a quantum computer without performing full quantum state simulation.
    /// </summary>
    /// 
    /// <remarks>
    /// <para>
    /// The simulator collects metrics describing the performance of Q# operations and 
    /// resource consumption by Q# operations. For example, these metrics include the number
    /// of qubits that an operation takes as an input; the number of qubits allocated
    /// by an operation; and the number of T gates executed by an operation. 
    /// For the full list of metrics, see the <see cref="MetricNames"/> property and the
    /// <see cref="PrimitiveOperationsGroupsNames"/> and <see cref="MetricsNames"/> classes.
    /// </para>
    /// <para>
    /// Q# operations may have different variants that are invoked using functors. Each operation
    /// in Q# can have up to four variants: body, adjoint, controlled, and controlled adjoint. 
    /// Usually, the controlled version of an operation uses a different number of gates, 
    /// has a different depth, and uses a different number of qubits than the body of 
    /// the operation. For this reason, the simulator collects metrics separately 
    /// for each operation variant.
    /// </para>
    /// <para>
    /// The simulator collects metrics for each edge of the call graph. For example, if the 
    /// adjoint variant of operation A calls the controlled variant of operation B, 
    /// the edge (B: Controlled, A: Adjoint) will appear in the call graph with the adjoint variant 
    /// of A as a caller of the controlled variant of B. The operations that are called 
    /// by the Run method of the simulator are top-level. The metrics collected for 
    /// top-level operations are obtained by their names without specifying the caller name.
    /// </para>
    /// <para>
    /// The simulator can potentially collect multiple values of the same metric 
    /// associated with the same call graph edge. For example, the adjoint variant of 
    /// operation A can be called multiple times and with different parameters. The 
    /// simulator does not store all collected values of the metrics. Instead, the simulator 
    /// computes functions of the collected values of the metric on the fly. For example, 
    /// the simulator computes minimum, maximum and average of the collected values. 
    /// We call these functions statistics of the metric. 
    /// To get the full list of statistics computed for a given
    /// metric use the <see cref="GetMetricStatisticNames(string)"/> method. 
    /// The list of statistics is also available through the members of the
    /// <see cref="StatisticsNames"/> class.
    /// </para>
    /// <para>
    /// Q# operations are mapped to C# types. For example, the 
    /// C# type <see cref="Microsoft.Quantum.Intrinsic.X"/> 
    /// corresponds to the Q# operation <a href="https://docs.microsoft.com/qsharp/api/prelude/microsoft.quantum.intrinsic.x">Microsoft.Quantum.Intrinsic.X</a>. 
    /// When the value of the metrics is requested for a Q# operation, 
    /// the corresponding C# type is passed as type parameter.
    /// </para>
    /// <para>
    /// When the maximum of all collected values of the metric is equal to the minimum, 
    /// the metric value is well-defined and the methods
    /// <see cref="GetMetric{TOperation}(string, OperationFunctor)"/> and 
    /// <see cref="GetMetric{TOperation, TCaller}(string, OperationFunctor, OperationFunctor)"/>
    /// can be used. Otherwise, the methods
    /// <see cref="GetMetricStatistic{T}(string, string, OperationFunctor)"/> and
    /// <see cref="GetMetricStatistic{TOperation, TCaller}(string, string, OperationFunctor, OperationFunctor)"/>
    /// must be used to retrieve the statistics of the metric. 
    /// </para>
    /// </remarks>
    public class QCTraceSimulator : Implementation.QCTraceSimulatorImpl
    {
        /// <summary>
        /// Returns a copy of the configuration used to create this instance of 
        /// <see cref="QCTraceSimulator"/>.
        /// </summary>
        public QCTraceSimulatorConfiguration GetConfigurationCopy()
        {
            return QCTraceSimulatorRuntime.Utils.DeepClone(configuration);
        }

        /// <summary> 
        /// Returns the value of a given metric for a top level operation. 
        /// </summary>
        /// 
        /// <param name="metric">
        /// The name of the metric requested for the top level 
        /// operation specified by <typeparamref name="TOperation"/> 
        /// </param>
        /// 
        /// <typeparam name="TOperation">
        /// The C# type corresponding to the Q# operation for which the metric is requested. 
        /// </typeparam>
        /// 
        /// <exception cref="System.Exception"> Thrown when a given metric
        /// is not well-defined. </exception>
        /// 
        /// <param name="functor">
        /// The functor (also called variant) of the operation for which the metric is requested.
        /// If not specified, this defaults to the "body" specialization.
        /// </param>
        /// 
        /// <remarks>
        /// For a more detailed discussion of metrics, statistics, call graph edges and 
        /// operation specializations, see the Remarks section of the <see cref="QCTraceSimulator"/> class
        /// documentation.
        /// </remarks>
        public double GetMetric<TOperation>(
            string metric,
            OperationFunctor functor = OperationFunctor.Body )
        {
            return GetMetric(
                GetOperationName<TOperation>(), 
                metric, 
                functor: functor );
        }

        /// <summary> 
        /// Returns the value of a given metric associated with an edge of the 
        /// call graph.
        /// </summary>
        /// 
        /// <param name="metric">
        /// The name of the metric requested for the specified call graph edge.
        /// </param>
        /// 
        /// <typeparam name="TOperation">
        /// The C# type corresponding to Q# operation for which the metric is requested. 
        /// </typeparam>
        /// 
        /// <typeparam name="TCaller">
        /// The C# type corresponding to the caller of the Q# operation for which the metric is requested.
        /// </typeparam>
        /// 
        /// <exception cref="System.Exception"> Thrown when a given metric
        /// is not well-defined. </exception>
        /// 
        /// <param name="functor">
        /// The functor specialization of the operation for which the metric is requested. 
        /// If not specified, this defaults to the "body" variant.
        /// </param>
        /// 
        /// <param name="callerFunctor">
        /// The functor specialization of the caller of the operation
        /// for which the metric is requested.
        /// If not specified, this defaults to the "body" variant.
        /// </param>
        ///
        /// <remarks>
        /// For a more detailed discussion of metrics, statistics, call graph edges and 
        /// operation specializations, see the Remarks section of the <see cref="QCTraceSimulator"/> class
        /// documentation.
        /// </remarks>
        public double GetMetric<TOperation, TCaller>(
            string metric,
            OperationFunctor functor = OperationFunctor.Body,
            OperationFunctor callerFunctor = OperationFunctor.Body)
        {
            return GetMetric(
                GetOperationName<TOperation>(),
                metric,
                callerName: GetOperationName<TCaller>(),
                functor: functor,
                callerFunctor: callerFunctor);
        }

        /// <summary> 
        /// Returns a statistic of a given metric for a top level operation. 
        /// </summary>
        /// 
        /// <param name="metric">
        /// The name of the metric requested for the top level 
        /// operation specified by <typeparamref name="T"/>.
        /// </param>
        /// 
        /// <param name="statistic">
        /// The name of a statistic of the specified metric for the specified top level operation.
        /// </param>
        /// 
        /// <typeparam name="T">
        /// The C# type corresponding to the Q# operation for which the metric is requested. 
        /// </typeparam>
        /// 
        /// <param name="functor">
        /// The functor specialization of the operation for which the metric is requested. 
        /// If not specified, this defaults to the "body" variant.
        /// </param>
        /// 
        /// <remarks>
        /// For a more detailed discussion of metrics, statistics, call graph edges and 
        /// operation specializations, see the Remarks section of the <see cref="QCTraceSimulator"/> class
        /// documentation.
        /// </remarks>
        public double GetMetricStatistic<T>(
            string metric,
            string statistic,
            OperationFunctor functor = OperationFunctor.Body )
        {
            return GetMetricStatistic(GetOperationName<T>(), metric, statistic, functor: functor );
        }

        /// <summary> 
        /// Returns a statistic of a given metric associated with an edge of the call graph.
        /// </summary>
        /// 
        /// <param name="metric">
        /// The name of the metric requested for the specified call graph edge.
        /// </param>
        /// 
        /// <param name="statistic">
        /// The name of the statistic of the metric requested for a given call graph edge.
        /// </param>
        /// 
        /// 
        /// <typeparam name="TOperation">
        /// The C# type corresponding to the Q# operation for which the metric is requested. 
        /// </typeparam>
        /// 
        /// <typeparam name="TCaller">
        /// The C# type corresponding to the caller of the Q# operation for which the metric is requested. 
        /// </typeparam>
        /// 
        /// <param name="functor">
        /// The functor specialization of the operation for which the metric is requested. 
        /// If not specified, this defaults to the "body" specialization.
        /// </param>
        /// 
        /// <param name="callerFunctor">
        /// The functor specialization of the caller of the operation
        /// for which the metric is requested. 
        /// If not specified, this defaults to the "body" specialization.
        /// </param>
        /// 
        /// <remarks>
        /// For a more detailed discussion of metrics, statistics, call graph edges and 
        /// operation specializations, see the Remarks section of the <see cref="QCTraceSimulator"/> class
        /// documentation.
        /// </remarks>
        public double GetMetricStatistic<TOperation, TCaller>(
            string metric,
            string statistic,
            OperationFunctor functor = OperationFunctor.Body,
            OperationFunctor callerFunctor = OperationFunctor.Body)
        {
            return GetMetricStatistic(GetOperationName<TOperation>(), metric, statistic, GetOperationName<TCaller>(), functor: functor, callerFunctor: callerFunctor);
        }

        /// <summary>
        /// Returns the names of all statistics currently collected for a given metric.
        /// </summary>
        /// 
        /// <param name="metric">
        /// The metric may be any member of <see cref="PrimitiveOperationsGroupsNames"/>
        /// and <see cref="MetricsNames"/>.
        /// The full list of the metrics collected by this instance of <see cref="QCTraceSimulator"/>
        /// can be obtained by calling <see cref="QCTraceSimulator.MetricNames"/>.
        /// </param>
        /// 
        /// <returns>
        /// An array of strings with the names of statistics collected for a given metric.
        /// </returns>
        /// 
        /// <remarks>
        /// For a more detailed discussion of metrics and statistics,
        /// see the Remarks section of the <see cref="QCTraceSimulator"/> class
        /// documentation.
        /// </remarks>
        public string[] GetMetricStatisticNames(string metric)
        {
            QCTraceSimulatorRuntime.ICallGraphStatistics st = metricNameToListener[metric];
            return st.Results.GetStatisticsNamesCopy();
        }

        /// <summary>
        /// Creates a new instance of the simulator with the default 
        /// <see cref="QCTraceSimulatorConfiguration"/>.
        /// </summary>
        public QCTraceSimulator() : this(new QCTraceSimulatorConfiguration() ) { }

        /// <summary>
        /// Creates a new instance of the simulator with configuration given by 
        /// the <paramref name="config"/> parameter.
        /// </summary>
        public QCTraceSimulator(QCTraceSimulatorConfiguration config, Assembly? coreAssembly = null) : 
            base(config, coreAssembly) { }

        /// <summary>
        /// Array of the names of all of the metrics collected by this instance of the simulator.
        /// This array includes the members of <see cref="PrimitiveOperationsGroupsNames"/>
        /// and <see cref="MetricsNames"/>.
        /// </summary>
        ///         
        /// <remarks>
        /// For a more detailed discussion of metrics, 
        /// see the Remarks section of the <see cref="QCTraceSimulator"/> class
        /// documentation.
        /// </remarks>
        public string[] MetricNames { get => metricNameToListener.Keys.ToArray(); }

        /// <summary>
        /// Returns all collected metrics for each call graph edge in CSV format. 
        /// The key in the dictionary is the name of metric counter  
        /// from <see cref="MetricsCountersNames"/>. 
        /// The value for each key is a collection of statistics formatted as a string in CSV format.
        /// In the CSV format, columns names are formated as "MetricName:StatisticName", and rows 
        /// correspond to call graph edges.
        /// </summary>
        /// 
        /// <param name="format"> The format string used to format values of type 
        /// <c>double</c> in the CSV file. The method supports the same format strings as the
        /// <see cref="double.ToString(string)"/> method.
        /// </param>
        public Dictionary<string, string> ToCSV(string format = "G")
        {
            Dictionary<string, string> dictionary = new Dictionary<string, string>();
            foreach (QCTraceSimulatorRuntime.IQCTraceSimulatorListener lsn in tCoreConfig.Listeners)
            {
                if (lsn is QCTraceSimulatorRuntime.ICallGraphStatistics lstat)
                {
                    dictionary.Add(lsn.GetType().Name, lstat.Results.ToCSV(format));
                }
            }
            return dictionary;
        }


    }


}
