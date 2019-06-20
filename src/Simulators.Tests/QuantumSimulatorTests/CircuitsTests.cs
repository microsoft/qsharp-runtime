using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Quantum.Intrinsic;
using Microsoft.Quantum.Simulation.Core;
using Xunit;
using Microsoft.Quantum.Simulation.XUnit;
using Microsoft.Quantum.Simulation.Simulators.Tests.Circuits;

namespace Microsoft.Quantum.Simulation.Simulators.Tests
{
    public partial class QuantumSimulatorTests
    {
        [OperationDriver(TestCasePrefix ="QSim", TestNamespace = "Microsoft.Quantum.Simulation.Simulators.Tests.Circuits")]
        public void QSimTestTarget( TestOperation op )
        {
            using (var sim = new QuantumSimulator(throwOnReleasingQubitsNotInZeroState: true))
            {
                op.TestOperationRunner(sim);
            }
        }
    }
}
