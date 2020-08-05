using Microsoft.Quantum.Simulation.Simulators.NewTracer.MetricCollectors;
using Microsoft.Quantum.Simulation.Simulators.NewTracer.NewDecomposition;
using Microsoft.Quantum.Simulation.Simulators.NewTracer.OldDecomposition;
using System.Collections.Generic;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer
{
    internal static class Utils
    {
        internal static ICollection<ITracerTarget> BuildTargetsFromConfig(NewTracerConfiguration? config)
        {
            if (config == null) { config = new NewTracerConfiguration(); }

            List<ITracerTarget> collectors = new List<ITracerTarget>()
            {
                new NewMeasurementAssertTracker(config.ThrowOnUnconstrainedMeasurement)
            };

            if (config.UsePrimitiveOperationsCounter)
            {
                collectors.Add(new NewGateTracker());
            }
            if (config.UseWidthCounter)
            {
                collectors.Add(new WidthTracker());
            }
            if (config.UseDepthCounter)
            {
                collectors.Add(new NewDepthCounter(config.TraceGateTimes));
            }
            if (config.UseInvalidatedQubitsUseChecker)
            {
                collectors.Add(new NewInvalidatedQubitChecker(true)); //TODO: why does the config object not have fields for this?
            }
            if (config.UseDistinctInputsChecker)
            {
                collectors.Add(new NewDistinctInputsChecker(true));
            }
            return collectors;
        }

        internal static ICollection<ITracerTarget> BuildTargetsFromConfig(QCTraceSimConfiguration? config)
        {
            if (config == null) { config = new QCTraceSimConfiguration(); }

            List<ITracerTarget> collectors = new List<ITracerTarget>()
            {
                new OldMeasurementAssertTracker(config.ThrowOnUnconstrainedMeasurement)
            };

            if (config.UsePrimitiveOperationsCounter)
            {
                collectors.Add(new OldGateTracker());
            }
            if (config.UseWidthCounter)
            {
                collectors.Add(new WidthTracker());
            }
            return collectors;
        }
    }
}
