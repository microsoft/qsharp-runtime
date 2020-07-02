using NewTracer.CallGraph;
using NewTracer.MetricCollection;
using NewTracer.Utils;
using Microsoft.Quantum.Simulation.Common;
using System.Collections.Generic;
using System.Linq;
using NewTracer.Data;
using NewTracer.MetricCollectors;
using Microsoft.Quantum.Simulation.QuantumProcessor;
using static Microsoft.Quantum.Simulation.QuantumProcessor.QuantumProcessorDispatcher;
using System.Runtime.CompilerServices;

namespace NewTracer
{
    public class NewTracerCore : MultiSinkQuantumProcessor
    {
        private readonly ICollection<IMetricCollector> MetricCollectors;

        private readonly ICollection<IQuantumProcessor> IQPListeners;


        public NewTracerCore(ICollection<IMetricCollector> metricCollectors, ICollection<IQuantumProcessor> iqpListeners)
            : base(new CallGraphBuilder(metricCollectors)) // The Core of this PassthroughExecutor is a CallGraphBuilder
        {
            MetricCollectors = metricCollectors;
            IQPListeners = iqpListeners;
            RegisterSinks(IQPListeners);
        }

        public TracerResults ExtractCurrentResults()
        {
            //TODO: remove cast
            return ((CallGraphBuilder)this.Core).GetResults();
        }

        public static SimulatorBase DefaultTracer(out NewTracerCore tracerCore)
        {
            MeasurementAssertTracker measurementTracker = new MeasurementAssertTracker(throwOnUnconstrainedMeasurement: true);
            GateTracker gateTracker = new GateTracker();
            WidthTracker widthTracker = new WidthTracker();
            DepthCounter depthTracker = new DepthCounter();


            MultiSinkQuantumProcessor decomposerFanout = new MultiSinkQuantumProcessor(measurementTracker); //measure tracker is the core block
            decomposerFanout.RegisterSinks(new IQuantumProcessor[] { gateTracker, widthTracker, depthTracker });

            IMetricCollector[] metricCollectors = new IMetricCollector[]
            {
                measurementTracker,
                gateTracker,
                widthTracker,
                depthTracker
            };

            (gateTracker as IMetricCollector).SaveRecordOnOperationStart(null);

            IQuantumProcessor decomposer = new DefaultDecomposer(decomposerFanout);
            tracerCore = new NewTracerCore(metricCollectors, new[] { decomposer });

            IQubitTraceSubscriber[] qubitTraceListeners = metricCollectors
                .Select(collector => collector as IQubitTraceSubscriber)
                .Where(subscriber => subscriber != null)
                .ToArray();

            IQubitManager qubitManager = new TraceableQubitManager(qubitTraceListeners);
            return new QuantumProcessorDispatcher(tracerCore, qubitManager);
        }

        public static SimulatorBase DefaultTracer()
        {
            return DefaultTracer(out _);
        }
    }
}