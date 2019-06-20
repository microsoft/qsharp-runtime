namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Implementation
{
    using Microsoft.Quantum.Simulation.Core;
    using Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime;

    public partial class QCTraceSimulatorImpl
    {
        public class TracerAllocate : Intrinsic.Allocate
        {
            private readonly QCTraceSimulatorCore core;
            public TracerAllocate(QCTraceSimulatorImpl m) : base(m){
                core = m.tracingCore;
            }

            public override Qubit Apply()
            {
                return core.Allocate(1)[0];
            }

            public override IQArray<Qubit> Apply( long count )
            {
                return core.Allocate(count);
            }
        }
    }
}