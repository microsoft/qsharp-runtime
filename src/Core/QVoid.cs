using System.Collections.Generic;
using System.Diagnostics;

using Newtonsoft.Json;

namespace Microsoft.Quantum.Simulation.Core
{

    /// <summary>
    /// Used by ICallable when Input or Output parameters are zero-arity tuples.
    /// Corresponds to Q# type zero-arity tuple type <code>()</code>.
    /// </summary>
    public sealed class QVoid : IApplyData
    {
        private QVoid() { }

        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        object IApplyData.Value => this;

        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        [JsonIgnore]
        public IEnumerable<Qubit> Qubits => null;

        public override string ToString() => "()";

        /// <summary>
        /// The instance of zero-arity tuple <code>()</code>.
        /// </summary>
        public static readonly QVoid Instance = new QVoid();
    }
}
