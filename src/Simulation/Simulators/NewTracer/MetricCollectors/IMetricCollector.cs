using Microsoft.Quantum.Simulation.Core;
using System.Collections.Generic;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer.MetricCollection
{
    //Any call stack data a metric collector may need to store. //TODO: can something useful be done with generics?
    public interface IStackRecord
    {
    }

    public interface IMetricCollector : ITracerTarget
    {
        string CollectorName();

        IList<string> Metrics();

        IStackRecord SaveRecordOnOperationStart(IApplyData inputArgs);

        double[] OutputMetricsOnOperationEnd(IStackRecord savedParentState, IApplyData returned);
    }
}