// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime
{
    [Serializable]
    public class MinMaxStatistic : IDoubleStatistic
    {

        public double Min { get; private set; } = double.MaxValue;
        public double Max { get; private set; } = double.MinValue;

        #region IDoubleStatistic implementation
        public void AddSample(double value)
        {
            Min = System.Math.Min(Min, value);
            Max = System.Math.Max(Max, value);
        }
        public int StatisticsCount => 2;
        public double[] GetStatistics()
        {
            return new double[] { Min, Max };
        }

        public class Statistics
        {
            public const string Min = "Min";
            public const string Max = "Max";
        }
        public string[] GetStatisticsNames()
        {
            return new string[] { Statistics.Min, Statistics.Max };
        }

        public IDoubleStatistic GetNewInstance()
        {
            return new MinMaxStatistic();
        }
        #endregion
    }
}
