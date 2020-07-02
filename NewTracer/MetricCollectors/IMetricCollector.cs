using NewTracer.CallGraph;
using Microsoft.Quantum.Simulation.Core;
using System.Collections.Generic;

namespace NewTracer.MetricCollection
{
    //Any call stack data a metric collector may need to store. //TODO: can something useful be done with generics?
    public interface IStackRecord
    {
    }

    public interface IMetricCollector
    {
        new string CollectorName();

        new IList<string> Metrics();

        new IStackRecord SaveRecordOnOperationStart(IApplyData inputArgs);

        double[] OutputMetricsOnOperationEnd(IStackRecord savedParentState, IApplyData returned);
    }
}
