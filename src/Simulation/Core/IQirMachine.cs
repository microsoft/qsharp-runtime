// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Threading.Tasks;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Runtime
{
    public interface IQirMachine : IAzureMachine
    {
        /// <summary>
        /// Submits a job to execute a QIR program. Does not wait for execution to be completed.
        /// </summary>
        /// <param name="info">The entry point information.</param>
        /// <param name="input">The input to the entry point.</param>
        /// <param name="qir">The QIR program as a byte string.</param>
        /// <typeparam name="TInput">Type of input the QIR program receives.</typeparam>
        /// <typeparam name="TOutput">Type of output the QIR program returns.</typeparam>
        /// <returns>
        /// An object that implements the IQuantumMachineJob interface through which data about the job can be obtained.
        /// </returns>
        Task<IQuantumMachineJob> SubmitAsync<TInput, TOutput>(
            EntryPointInfo<TInput, TOutput> info,
            TInput input,
            byte[] qir);
    }
}
