using System;
using System.Collections.Generic;

namespace NewTracer.MetricCollection
{
    /// <summary>
    /// Builds a variable distribution summary iteratively from samples.
    /// </summary>
    public class VariableDistributionSummary
    {
        public int Count { get; private set; }

        public double Sum { get; private set; }

        public double Min { get; private set; }

        public  double Max { get; private set; }

        public double Average => Count == 0 ? Double.NaN : Sum / Count;

        //TODO: implement variance

        public VariableDistributionSummary()
        {
            Count = 0;
            Sum = 0.0d;
            Min = Double.MaxValue;
            Max = Double.MinValue;
        }

        internal void AddSample(double sample)
        {
            Count++;
            Sum += sample;

            if (sample < Min) { Min = sample; }
            if (sample > Max) { Max = sample; }
        }

        internal void MergeSummary(VariableDistributionSummary other)
        {
            Count += other.Count;
            Sum += other.Sum;
            Min = Min < other.Min ? Min : other.Min;
            Max = Max > other.Max ? Max : other.Max;
        }

        public VariableDistributionSummary Clone()
        {
            return new VariableDistributionSummary
            {
                Count = Count,
                Sum = Sum,
                Min = Min,
                Max = Max
            };
        }

        public IDictionary<string, double> AsDictionary()
        {
            return new Dictionary<string, double>(StringComparer.InvariantCultureIgnoreCase)
            {
                {   "Sum",      Sum      },
                {   "Average",  Average  },
                {   "Min",      Min      },
                {   "Max",      Max      }
            };
        }

        public double this[string statistic]
        {
            get
            {
                return this.AsDictionary()[statistic];
            }
        }

        public override string ToString()
        {
            return this.AsDictionary().ToString();
        }
    }
}
