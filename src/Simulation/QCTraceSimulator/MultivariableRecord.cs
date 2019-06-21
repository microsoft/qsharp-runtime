// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime
{
    /// <summary>
    /// Collects statistics for multiple random variables. Used by <see cref="StatisticsCollector{TKey}"/>.
    /// </summary>
    public class MultivariableRecord
    {
        class VariableRecord : List<IDoubleStatistic>
        {
            public VariableRecord(IList<IDoubleStatistic> statistics)
                : base(statistics.Count)
            {
                for (int i = 0; i < statistics.Count; ++i)
                {
                    Add(statistics[i].GetNewInstance());
                }
            }
            public void AddSample(double sample)
            {
                foreach (IDoubleStatistic st in this)
                {
                    st.AddSample(sample);
                }
            }
        }

        readonly VariableRecord[] VariableRecords;
        readonly int NumberOfVariables;
        public long NumberOfSamples { get; private set; } = 0;

        public MultivariableRecord(int numberOfVariables, IList<IDoubleStatistic> statisticsToCollect)
        {
            Debug.Assert(statisticsToCollect != null);
            Debug.Assert(numberOfVariables > 0);

            this.NumberOfVariables = numberOfVariables;
            VariableRecords = new VariableRecord[numberOfVariables];
            for (int i = 0; i < numberOfVariables; ++i)
            {
                VariableRecords[i] = new VariableRecord(statisticsToCollect);
            }
        }

        public void AddSample(double[] sampleArray)
        {
            Debug.Assert(sampleArray != null);
            Debug.Assert(sampleArray.Length == NumberOfVariables);
            NumberOfSamples++;
            for (int i = 0; i < NumberOfVariables; ++i)
            {
                VariableRecords[i].AddSample(sampleArray[i]);
            }
        }
        public string[] GetStatisticsNames(int variableId = 0)
        {
            return VariableRecords[variableId].GetStatisticsNames();
        }

        public double[] GetVariableStatistics(int variableId)
        {
            return VariableRecords[variableId].GetStatistics();
        }
    }
}
