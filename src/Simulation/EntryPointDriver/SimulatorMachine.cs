using System;
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
    /// TODO: This class is only for testing the <see cref="IQuantumMachine{TJob,TRawResult}"/> interface. It should be
    /// removed once an actual quantum machine implementation can be used.
    /// </remarks>
    internal class SimulatorMachine : IQuantumMachine<object?, object?>
    {
        public string ProviderId => nameof(SimulatorMachine);

        public string Target => "QuantumSimulator";

        public async Task<Tuple<TOut, object?>> ExecuteAsync<TIn, TOut>(EntryPointInfo<TIn, TOut> info, TIn input)
        {
            var result = await (Task<TOut>)typeof(QuantumSimulator)
                .GetMethod(nameof(QuantumSimulator.Run))
                .MakeGenericMethod(info.Operation, info.InType, info.OutType)
                .Invoke(new QuantumSimulator(), new object?[] { input });
            return new Tuple<TOut, object?>(result, null);
        }

        public Task<object?> SubmitAsync<TIn, TOut>(EntryPointInfo<TIn, TOut> info, TIn input) =>
            throw new NotImplementedException();
    }
}
