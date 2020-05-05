using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.Threading.Tasks;
using Microsoft.Quantum.Runtime;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver
{
    /// <summary>
    /// A quantum machine that runs an operation using a local quantum simulator.
    /// </summary>
    /// <remarks>
    /// TODO: This class is only for testing the <see cref="IQuantumMachine"/> interface. It should be removed once an
    /// actual quantum machine implementation can be used.
    /// </remarks>
    internal class SimulatorMachine : IQuantumMachine
    {
        public string ProviderId => nameof(SimulatorMachine);

        public string Target => "QuantumSimulator";

        public async Task<IQuantumMachineOutput<TOut>> ExecuteAsync<TIn, TOut>(
            EntryPointInfo<TIn, TOut> info, TIn input)
        {
            var result = await (Task<TOut>)typeof(QuantumSimulator)
                .GetMethod(nameof(QuantumSimulator.Run))
                .MakeGenericMethod(info.Operation, info.InType, info.OutType)
                .Invoke(new QuantumSimulator(), new object?[] { input });
            return new SimulatorMachineOutput<TOut>(result);
        }

        public Task<IQuantumMachineJob> SubmitAsync<TIn, TOut>(EntryPointInfo<TIn, TOut> info, TIn input) =>
            throw new NotImplementedException();
    }

    internal class SimulatorMachineOutput<T> : IQuantumMachineOutput<T>
    {
        public IReadOnlyDictionary<T, double> Histogram { get; }
        
        public IQuantumMachineJob Job => throw new NotImplementedException();

        public int Shots => 1;

        internal SimulatorMachineOutput(T result) => Histogram = ImmutableDictionary<T, double>.Empty.Add(result, 1);
    }
}
