using System;
using System.Collections.Generic;
using System.Text;

namespace Microsoft.Quantum.Simulation.Core
{
    public class OperationInfo<I, O>
    {
        public Type Operation { get; }
        public Type InType => typeof(I);
        public Type OutType => typeof(O);
        public OperationInfo(Type operation)
        {
            this.Operation = operation;
        }
    }
}
