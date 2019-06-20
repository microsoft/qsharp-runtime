using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Simulation.XUnit
{
    public class TestOperationException : Exception
    {
        public TestOperationException(string message) : base(message)
        {
        }
    }
}
