namespace Microsoft.Quantum.Simulation.Simulators.NewTracer
{
    public abstract class TracerConfiguration
    {
        public bool UseWidthCounter = false;

        public bool ThrowOnUnconstrainedMeasurement = true;

        public bool UsePrimitiveOperationsCounter = false;

        //TODO: not implemented

        public bool UseDistinctInputsChecker = false;

        public bool UseInvalidatedQubitsUseChecker = false;

        //TODO: not implemented
        public uint CallStackDepthLimit = uint.MaxValue;
    }

    public class NewTracerConfiguration : TracerConfiguration
    {
        public bool UseDepthCounter = false;

        public NewTraceGateTimes TraceGateTimes = NewTraceGateTimes.TGatesOnly;
    }

    //TODO: rename to QCTraceSimulatorConfiguration once old tracer removed
    public class QCTraceSimConfiguration : TracerConfiguration
    {
  
    }

    //TODO: implement others

    //TODO: naming?
    public class NewTraceGateTimes
    {
        public double CZ { get; set; } = 0;

        public double CCZ { get; set; } = 0;

        public double T { get; set; } = 1;

        public double Rz { get; set; } = 0;

        public double M { get; set; } = 0;

        public NewTraceGateTimes Clone()
        {
            return new NewTraceGateTimes
            {
                CZ = CZ,
                CCZ = CCZ,
                T = T,
                Rz = Rz,
                M = M
            };
        }

        public static NewTraceGateTimes TGatesOnly
        {
            get
            {
                return new NewTraceGateTimes
                {
                    CZ = 0,
                    CCZ = 0,
                    T = 1,
                    Rz = 0,
                    M = 0
                };
            }
        }

        public static NewTraceGateTimes ControlledZOnly
        {
            get
            {
                return new NewTraceGateTimes
                {
                    CZ = 1,
                    CCZ = 1, //TODO: what should this be?
                    T = 0,
                    Rz = 0,
                    M = 0
                };
            }
        }
    }
}