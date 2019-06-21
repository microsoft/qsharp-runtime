using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime
{
    public interface ICallGraphStatistics
    {
        IStatisticCollectorResults<CallGraphEdge> Results { get; }
    }
}
