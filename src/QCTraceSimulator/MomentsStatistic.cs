using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime
{
    [Serializable]
    public class MomentsStatistic : IDoubleStatistic
    {
        /// <summary>
        /// Number of samples collected
        /// </summary>
        uint count;
        double sumOfSquares;
        double mean;
        double m2;
        double total = 0.0;

        double GetAverage()
        {
            return count == 0 ? Double.NaN : mean;
        }

        double GetSecondMoment()
        {
            return count == 0 ? Double.NaN : sumOfSquares / count;
        }

        double GetVariance()
        {
            return count < 2 ? Double.NaN : m2 / (count - 1);
        }

        double GetSum()
        {
            return total;
        }

        #region IDoubleStatistic implementation
        public void AddSample(double value)
        {
            count += 1;
            total += value;
            sumOfSquares += value * value;
            double delta = value - mean;
            mean += delta / count;
            m2 += delta * (value - mean);
        }
        public int StatisticsCount => 3;

        public class Statistics
        {
            public const string Average = "Average";
            public const string SecondMoment = "SecondMoment";
            public const string Variance = "Variance";
            public const string Sum = "Sum";
        }

        public string[] GetStatisticsNames()
        {
            return new string[] { Statistics.Average, Statistics.SecondMoment, Statistics.Variance, Statistics.Sum };
        }

        public double[] GetStatistics()
        {
            return new double[] { GetAverage(), GetSecondMoment(), GetVariance(), GetSum() };
        }

        public IDoubleStatistic GetNewInstance()
        {
            return new MomentsStatistic();
        }
        #endregion
    }
}
