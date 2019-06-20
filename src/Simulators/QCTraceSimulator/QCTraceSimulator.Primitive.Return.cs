namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Implementation
{
    using Microsoft.Quantum.Simulation.Core;
    using Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime;

    public partial class QCTraceSimulatorImpl
    {
        public class TracerReturn : Intrinsic.Return
        {
            private readonly QCTraceSimulatorCore core;
            public TracerReturn(QCTraceSimulatorImpl m) : base(m){
                core = m.tracingCore;
            }

            public override void Apply(Qubit q)
            {
                core.Return(q);
            }

            public override void Apply(IQArray<Qubit> qubits)
            {
                core.Return(qubits);
            }
        }
    }
}