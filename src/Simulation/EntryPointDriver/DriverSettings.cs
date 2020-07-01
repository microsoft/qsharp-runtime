﻿using System.Collections.Immutable;

namespace Microsoft.Quantum.EntryPointDriver
{
    /// <summary>
    /// General settings for the entry point driver that do not depend on the entry point or compilation target.
    /// </summary>
    public sealed class DriverSettings
    {
        /// <summary>
        /// The aliases for the simulator command-line option.
        /// </summary>
        internal IImmutableList<string> SimulatorOptionAliases { get; }

        /// <summary>
        /// The name of the quantum simulator.
        /// </summary>
        internal string QuantumSimulatorName { get; }

        /// <summary>
        /// The name of the Toffoli simulator.
        /// </summary>
        internal string ToffoliSimulatorName { get; }

        /// <summary>
        /// The name of the resources estimator.
        /// </summary>
        internal string ResourcesEstimatorName { get; }

        /// <summary>
        /// Creates a new driver settings instance.
        /// </summary>
        /// <param name="simulatorOptionAliases">The aliases for the simulator command-line option.</param>
        /// <param name="quantumSimulatorName">The name of the quantum simulator.</param>
        /// <param name="toffoliSimulatorName">The name of the Toffoli simulator.</param>
        /// <param name="resourcesEstimatorName">The name of the resources estimator.</param>
        public DriverSettings(
            IImmutableList<string> simulatorOptionAliases,
            string quantumSimulatorName,
            string toffoliSimulatorName,
            string resourcesEstimatorName)
        {
            SimulatorOptionAliases = simulatorOptionAliases;
            QuantumSimulatorName = quantumSimulatorName;
            ToffoliSimulatorName = toffoliSimulatorName;
            ResourcesEstimatorName = resourcesEstimatorName;
        }
    }
}
