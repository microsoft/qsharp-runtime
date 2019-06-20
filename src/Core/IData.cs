using System.Collections.Generic;

namespace Microsoft.Quantum.Simulation.Core
{
    /// <summary>
    /// Represents data that can be used as input arguments or return values of an Apply operation.
    /// </summary>
    public interface IApplyData
    {
        object Value { get; }

        /// <summary>
        /// If there are no qubits contained in the value returns null 
        /// </summary>
        /// <returns></returns>
        IEnumerable<Qubit> Qubits { get; }
    }
}
