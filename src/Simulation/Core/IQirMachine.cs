// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Threading.Tasks;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Runtime
{
    public interface IQirMachine : IAzureMachine
    {
        /// <summary>
        /// Submits a job to execute a Q# program.
        /// Does not wait for execution to be completed.
        /// </summary>
        /// <param name="info">Information about the Q# program.</param>
        /// <param name="input">Input for the Q# program.</param>
        /// <param name="qir">Input for the Q# program.</param>
        /// <typeparam name="TInput">Type of input the quantum program receives.</typeparam>
        /// <typeparam name="TOutput">Type of output the quantum program returns.</typeparam>
        /// <returns>An object that implements the IQuantumMachineJob interface through which data about the job can be obtained.</returns>
        Task<IQuantumMachineJob> SubmitAsync<TInput, TOutput>(
            EntryPointInfo<TInput, TOutput> info,
            TInput input,
            byte[] qir) => SubmitAsync(info, input, qir, null);

        /// <summary>
        /// Submits a job to execute a Q# program.
        /// Does not wait for execution to be completed.
        /// </summary>
        /// <param name="info">Information about the Q# program.</param>
        /// <param name="input">Input for the Q# program.</param>
        /// <param name="qir">Input for the Q# program.</param>
        /// <param name="configureJobCallback">Function that configures a job object before submission.</param>
        /// <typeparam name="TInput">Type of input the quantum program receives.</typeparam>
        /// <typeparam name="TOutput">Type of output the quantum program returns.</typeparam>
        /// <returns>An object that implements the IQuantumMachineJob interface through which data about the job can be obtained.</returns>
        Task<IQuantumMachineJob> SubmitAsync<TInput, TOutput>(
            EntryPointInfo<TInput, TOutput> info,
            TInput input,
            byte[] qir,
            ConfigureJob configureJobCallback);
    }
}
