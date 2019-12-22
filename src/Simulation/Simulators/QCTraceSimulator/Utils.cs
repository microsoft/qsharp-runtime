// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System.Collections.Generic;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime;

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators
{
    /// <summary>
    /// Names of primitive operation groups for which statistics are collected 
    /// by <see cref="QCTraceSimulator"/> when
    /// <see cref="QCTraceSimulatorConfiguration.UsePrimitiveOperationsCounter"/> is set to <c>true</c>. 
    /// These can be passed as an argument 
    /// metric to
    /// <see cref="QCTraceSimulator.GetMetric{TOperation, TCaller}(string, Core.OperationFunctor, Core.OperationFunctor)"/>.
    /// </summary>
    public static class PrimitiveOperationsGroupsNames
    {
        /// <summary>
        /// The CNOT gate, also known as the Controlled Pauli X gate.
        /// </summary>
        public static string CNOT = PrimitiveOperationsGroups.CNOT.ToString();

        /// <summary>
        /// The T gate and its conjugates, including the T gate, T_x = H.T.H, and T_y = Hy.T.Hy.
        /// </summary>
        public static string T = PrimitiveOperationsGroups.T.ToString();

        /// <summary>
        /// Any single qubit Clifford and Pauli gate.
        /// </summary>
        public static string QubitClifford = PrimitiveOperationsGroups.QubitClifford.ToString();

        /// <summary>
        /// Any single qubit rotation excluding T, Clifford and Pauli gates.
        /// </summary>
        public static string R = PrimitiveOperationsGroups.R.ToString();

        /// <summary>
        /// Any measurement. 
        /// </summary>
        public static string Measure = PrimitiveOperationsGroups.Measure.ToString();
    }

    /// <summary>
    /// This class provides sample configurations 
    /// for the <see cref="QCTraceSimulatorConfiguration.TraceGateTimes"/> field
    /// that follow some conventions commonly used in the literature.
    /// </summary>
    static public class GateTimes
    {
        /// <summary>
        /// This configuration specifies that all gates except T take 0 time. 
        /// A T gate is set to take unit time.
        /// With this gate time configuration, <see cref="QCTraceSimulator"/>
        /// will compute T depth.
        /// </summary>
        public static Dictionary<PrimitiveOperationsGroups, double> TGatesOnly
        {
            get =>
                new Dictionary<PrimitiveOperationsGroups, double>()
                {
                    { PrimitiveOperationsGroups.CNOT, 0 },
                    { PrimitiveOperationsGroups.Measure, 0 },
                    { PrimitiveOperationsGroups.QubitClifford, 0 },
                    { PrimitiveOperationsGroups.R, 0 },
                    { PrimitiveOperationsGroups.T, 1 }
                };
        }

        /// <summary>
        /// This configuration specifies that all gates except CNOT take 0 time. 
        /// A CNOT gate is set to take unit time.
        /// With this gate time configuration, <see cref="QCTraceSimulator"/>
        /// will compute CNOT depth.
        /// </summary>
        public static Dictionary<PrimitiveOperationsGroups, double> CNOTOnly
        {
            get =>
                new Dictionary<PrimitiveOperationsGroups, double>()
                {
                    { PrimitiveOperationsGroups.CNOT, 1 },
                    { PrimitiveOperationsGroups.Measure, 0 },
                    { PrimitiveOperationsGroups.QubitClifford, 0 },
                    { PrimitiveOperationsGroups.R, 0 },
                    { PrimitiveOperationsGroups.T, 0 }
                };
        }
    }

    /// <summary>
    /// Names of the metrics supported by components of <see cref="QCTraceSimulator"/>.
    /// </summary>
    public static class MetricsNames
    {
        /// <summary>
        /// Metric names collected by the DepthCounter component. 
        /// Set <see cref="QCTraceSimulatorConfiguration.UseDepthCounter"/> to <c>true</c>
        /// to enable collection.
        /// </summary>
        public static class DepthCounter
        {
            /// <summary>
            /// Depth of the quantum circuit executed by an operation.
            /// </summary>
            public static string Depth = QCTraceSimulatorRuntime.DepthCounter.Metrics.Depth;

            /// <summary>
            /// Maximal difference in the availability time for qubits input into the operation.
            /// </summary>
            public static string StartTimeDifference = QCTraceSimulatorRuntime.DepthCounter.Metrics.StartTimeDifference;
        }

        /// <summary>
        /// Metric names collected by the Width Counter component. 
        /// Set <see cref="QCTraceSimulatorConfiguration.UseWidthCounter"/> to <c>true</c> to enable collection.
        /// </summary>
        public static class WidthCounter
        {
            /// <summary>
            /// Maximum number of qubits borrowed inside the operation.
            /// </summary>
            public static string BorrowedWith = QCTraceSimulatorRuntime.WidthCounter.Metrics.BorrowedWith;

            /// <summary>
            /// Maximum number of qubits allocated during the execution of the operation.
            /// </summary>
            public static string ExtraWidth = QCTraceSimulatorRuntime.WidthCounter.Metrics.ExtraWidth;

            /// <summary>
            /// Number of qubits input into the operation.
            /// </summary>
            public static string InputWidth = QCTraceSimulatorRuntime.WidthCounter.Metrics.InputWidth;

            /// <summary>
            /// Number of qubits returned from an operation.
            /// </summary>
            public static string ReturnWidth = QCTraceSimulatorRuntime.WidthCounter.Metrics.ReturnWidth;
        }
    }

    /// <summary>
    /// Names of the statistics collected by <see cref="QCTraceSimulator"/>.
    /// </summary>
    public static class StatisticsNames
    {
        /// <summary>
        /// The smallest value of a metric among all collected samples.
        /// </summary>
        public static string Min = MinMaxStatistic.Statistics.Min;

        /// <summary>
        /// The largest value of a metric among all collected samples.
        /// </summary>
        public static string Max = MinMaxStatistic.Statistics.Max;

        /// <summary>
        /// The average of a metric over all collected samples.
        /// </summary>
        public static string Average = MomentsStatistic.Statistics.Average;

        /// <summary>
        /// The second moment of a metric over all collected samples.
        /// </summary>
        public static string SecondMoment = MomentsStatistic.Statistics.SecondMoment;

        /// <summary>
        /// The variance of a metric over all collected samples.
        /// </summary>
        public static string Variance = MomentsStatistic.Statistics.Variance;

        /// <summary>
        /// The sum of a metric over all collected samples.
        /// </summary>
        public static string Sum = MomentsStatistic.Statistics.Sum;
    }

    /// <summary>
    /// Names of metric calculators used in <see cref="QCTraceSimulator"/>. These correspond to 
    /// the keys of the dictionary returned by <see cref="QCTraceSimulator.ToCSV(string)"/>.
    /// </summary>
    public static class MetricsCountersNames
    {
        /// <summary>
        /// Name of the Primitive Operation Counting component of <see cref="QCTraceSimulator"/>. 
        /// </summary>
        public const string primitiveOperationsCounter = nameof(PrimitiveOperationsCounter);

        /// <summary>
        /// Name of the Depth Counting component of <see cref="QCTraceSimulator"/>. 
        /// </summary>
        public const string depthCounter = nameof(DepthCounter);

        /// <summary>
        /// Name of the Width Counting component of <see cref="QCTraceSimulator"/>. 
        /// </summary>
        public const string widthCounter = nameof(WidthCounter);
    }

    static class SimulatorsUtils
    {
        /// <summary>
        /// Takes an array of doubles as
        /// input, and returns a randomly-selected index into the array 
        /// as an `Int`. The probability of selecting a specific index
        /// is proportional to the value of the array element at that index.
        /// Array elements that are equal to zero are ignored and their indices
        /// are never returned.If any array element is less than zero, or if
        /// no array element is greater than zero, then the operation fails.
        /// As a source of randomness uses a number uniformly distributed between 0 and 1. 
        /// Used for Quantum.Intrinsic.Random
        /// </summary>
        /// <param name="uniformZeroOneSample"> Number between Zero and one, uniformly distributed</param>
        public static long SampleDistribution(IQArray<double> unnormalizedDistribution, double uniformZeroOneSample)
        {
            double total = 0.0;
            foreach (double prob in unnormalizedDistribution)
            {
                if (prob < 0)
                {
                    throw new ExecutionFailException("Random expects array of non-negative doubles.");
                }
                total += prob;
            }

            if (total == 0)
            {
                throw new ExecutionFailException("Random expects array of non-negative doubles with positive sum.");
            }

            double sample = uniformZeroOneSample * total;
            double sum = unnormalizedDistribution[0];
            for (int i = 0; i < unnormalizedDistribution.Length - 1; ++i)
            {
                if (sum >= sample)
                {
                    return i;
                }
                sum += unnormalizedDistribution[i];
            }
            return unnormalizedDistribution.Length;
        }
    }
}
