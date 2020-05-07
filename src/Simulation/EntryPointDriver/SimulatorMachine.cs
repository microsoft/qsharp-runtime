using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Quantum.Runtime;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver
{
    /// <summary>
    /// A quantum machine that runs the entry point using a local quantum simulator.
    /// </summary>
    /// <remarks>
    /// TODO: This class is only for testing the <see cref="IQuantumMachine"/> interface. It should be removed once an
    /// actual quantum machine implementation can be used.
    /// </remarks>
    internal class SimulatorMachine : IQuantumMachine
    {
        public string ProviderId => nameof(SimulatorMachine);

        public string Target => "QuantumSimulator";

        /// <summary>
        /// The number of times to simulate the entry point.
        /// </summary>
        private readonly int shots;

        /// <summary>
        /// Creates a simulator machine.
        /// </summary>
        /// <param name="shots">The number of times to simulate the entry point.</param>
        internal SimulatorMachine(int shots) => this.shots = shots;

        public async Task<IQuantumMachineOutput<TOut>> ExecuteAsync<TIn, TOut>(
                EntryPointInfo<TIn, TOut> info, TIn input) =>
            new SimulatorMachineOutput<TOut>(await RunShots(info, input).ToListAsync());

        public Task<IQuantumMachineJob> SubmitAsync<TIn, TOut>(EntryPointInfo<TIn, TOut> info, TIn input) =>
            throw new NotImplementedException();

        /// <summary>
        /// Runs all of the simulator shots and yields the results.
        /// </summary>
        /// <param name="info">The entry point information.</param>
        /// <param name="input">The input to the entry point.</param>
        /// <typeparam name="TIn">The entry point input type.</typeparam>
        /// <typeparam name="TOut">The entry point output type.</typeparam>
        /// <returns>The results of simulating the entry point.</returns>
        private async IAsyncEnumerable<TOut> RunShots<TIn, TOut>(EntryPointInfo<TIn, TOut> info, TIn input)
        {
            var run = typeof(QuantumSimulator)
                .GetMethod(nameof(QuantumSimulator.Run))
                .MakeGenericMethod(info.Operation, info.InType, info.OutType);
            using var simulator = new QuantumSimulator();
            foreach (var _ in Enumerable.Range(0, shots))
            {
                yield return await (Task<TOut>)run.Invoke(simulator, new object?[] { input });
            }
        }
    }

    /// <summary>
    /// The output of executing the <see cref="SimulatorMachine"/>.
    /// </summary>
    /// <typeparam name="T">The output result type.</typeparam>
    internal class SimulatorMachineOutput<T> : IQuantumMachineOutput<T>
    {
        public IReadOnlyDictionary<T, double> Histogram { get; }

        public IQuantumMachineJob Job => throw new NotImplementedException();

        public int Shots { get; }

        /// <summary>
        /// Creates a new output from the results.
        /// </summary>
        /// <param name="results">The results.</param>
        internal SimulatorMachineOutput(IReadOnlyCollection<T> results)
        {
            Histogram = results
                .GroupBy(result => result)
                .ToImmutableDictionary(group => group.Key, group => (double)group.Count() / results.Count);
            Shots = results.Count;
        }
    }
}
