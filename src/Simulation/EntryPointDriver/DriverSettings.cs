using Microsoft.Quantum.Simulation.Core;
using System;
using System.Collections.Immutable;

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
        internal ImmutableList<string> SimulatorOptionAliases { get; }

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
        /// The name of the default simulator to use when simulating the entry point.
        /// </summary>
        internal string DefaultSimulatorName { get; }

        /// <summary>
        /// The default execution target when to use when submitting the entry point to Azure Quantum.
        /// </summary>
        internal string DefaultExecutionTarget { get; }

        /// <summary>
        /// A function that returns a new instance of the default custom simulator, or throws
        /// <see cref="InvalidOperationException"/> if the default simulator is not a custom simulator.
        /// </summary>
        internal Func<IOperationFactory> CreateDefaultCustomSimulator { get; }

        /// <summary>
        /// Creates a new driver settings instance.
        /// </summary>
        /// <param name="simulatorOptionAliases">The aliases for the simulator command-line option.</param>
        /// <param name="quantumSimulatorName">The name of the quantum simulator.</param>
        /// <param name="toffoliSimulatorName">The name of the Toffoli simulator.</param>
        /// <param name="resourcesEstimatorName">The name of the resources estimator.</param>
        /// <param name="defaultSimulatorName">The name of the default simulator to use.</param>
        /// <param name="defaultExecutionTarget">The name of the default execution target to use.</param>
        /// <param name="createDefaultCustomSimulator">
        /// A function that returns a new instance of the default custom simulator, or throws
        /// <see cref="InvalidOperationException"/> if the default simulator is not a custom simulator.
        /// </param>
        public DriverSettings(
            ImmutableList<string> simulatorOptionAliases,
            string quantumSimulatorName,
            string toffoliSimulatorName,
            string resourcesEstimatorName,
            string defaultSimulatorName,
            string defaultExecutionTarget,
            Func<IOperationFactory> createDefaultCustomSimulator)
        {
            SimulatorOptionAliases = simulatorOptionAliases;
            QuantumSimulatorName = quantumSimulatorName;
            ToffoliSimulatorName = toffoliSimulatorName;
            ResourcesEstimatorName = resourcesEstimatorName;
            DefaultSimulatorName = defaultSimulatorName;
            DefaultExecutionTarget = defaultExecutionTarget;
            CreateDefaultCustomSimulator = createDefaultCustomSimulator;
        }
    }
}
