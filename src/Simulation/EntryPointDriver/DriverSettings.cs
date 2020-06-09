using System.Collections.Immutable;

namespace Microsoft.Quantum.EntryPointDriver
{
    /// <summary>
    /// Settings for the entry point driver.
    /// </summary>
    public sealed class DriverSettings
    {
        /// <summary>
        /// The aliases for the simulator command-line option.
        /// </summary>
        public IImmutableList<string> SimulatorOptionAliases { get; set; }

        /// <summary>
        /// The name of the quantum simulator.
        /// </summary>
        public string QuantumSimulatorName { get; set; }

        /// <summary>
        /// The name of the Toffoli simulator.
        /// </summary>
        public string ToffoliSimulatorName { get; set; }

        /// <summary>
        /// The name of the resources estimator.
        /// </summary>
        public string ResourcesEstimatorName { get; set; }
    }
}
