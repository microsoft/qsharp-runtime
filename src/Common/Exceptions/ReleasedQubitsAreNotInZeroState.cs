using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Simulation.Simulators.Exceptions
{
    public class ReleasedQubitsAreNotInZeroState : Exception
    {
        public ReleasedQubitsAreNotInZeroState()
            : base("Released qubits are not in zero state.")
        {
        }
    }
}
