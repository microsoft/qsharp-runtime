using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime
{
    /// <summary>
    /// Interface used to collect statistics ( usually in a streaming fashion ).
    /// See <see cref="MomentsStatistic"/> and <see cref="MinMaxStatistic"/> for the examples of the implementation.
    /// </summary>
    public interface IDoubleStatistic
    {
        void AddSample(double value);

        /// <summary>
        /// Number of statistics being collected by given class
        /// </summary>
        int StatisticsCount { get; }

        /// <summary>
        /// Returns the names of the collected statistics. The length of the array is <see cref="StatisticsCount"/>
        /// </summary>
        string[] GetStatisticsNames();

        /// <summary>
        /// Values of the observed statistics. The length of the array is <see cref="StatisticsCount"/>.
        /// </summary>
        double[] GetStatistics();

        /// <summary>
        /// New instance of the class implementing the interface that contains zero samples. 
        /// </summary>
        /// <returns></returns>
        IDoubleStatistic GetNewInstance();
    }

    /// <summary>
    /// Extensions related to <see cref="IDoubleStatistic"/>
    /// </summary>
    public static class Extensions
    {
        /// <summary>
        /// Concatenates statistics names
        /// </summary>
        public static string[] GetStatisticsNames(this IEnumerable<IDoubleStatistic> statistics) =>
            statistics.SelectMany(st => st.GetStatisticsNames()).ToArray();

        /// <summary>
        /// Concatenates statistics values
        /// </summary>
        public static double[] GetStatistics(this IEnumerable<IDoubleStatistic> statistics) =>
            statistics.SelectMany(st => st.GetStatistics()).ToArray();
    }
}
