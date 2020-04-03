// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Threading.Tasks;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Runtime
{
    /// <summary>
    /// Interface that a quantum machine must implement.
    ///
    /// Type parameters:
    ///     - Job: Type of job that handles the execution of a program in the quantum machine.
    ///     - QResult: Type of result the quantum machine returns.
    /// </summary>
    // TODO: This interface should be migrated to the qsharp-runtime repository.

    public interface IQuantumMachine<Job, QRawResult>
    {
        /// <summary>
        /// Gets the ID of the quantum machine provider.
        /// </summary>
        string ProviderId { get; }

        /// <summary>
        /// Gets the name of the target quantum machine.
        /// A provider may expose multiple targets that can be used to execute programs.
        /// Users may select which target they would like to be used for execution.
        /// </summary>
        string Target { get; }

        /// <summary>
        /// Executes a Q# program.
        /// Submits a job to execute it and continuously checks whether it has been completed.
        /// Once its execution completes, returns its output.
        ///
        /// Type parameters:
        ///     - QInput: Type of input the quantum program receives.
        ///     - QOutput: Type of output the quantum program returns.
        /// </summary>
        /// <param name="info">Information about the Q# program</param>
        /// <param name="input">Input for the Q# program</param>
        /// <returns>Sampled output of the quantum program</returns>
        Task<Tuple<QOutput, QRawResult>> ExecuteAsync<QInput, QOutput>(OperationInfo<QInput, QOutput> info, QInput input);

        /// <summary>
        /// Submits a job to execute a Q# program.
        /// Does not wait for execution to be completed.
        ///
        /// Type parameters:
        ///     - QInput: Type of input the quantum program receives.
        ///     - QOutput: Type of output the quantum program returns.
        /// </summary>
        /// <param name="info">Information about the Q# program</param>
        /// <param name="input">Input for the Q# program</param>
        /// <returns>Job object</returns>
        Task<Job> SubmitAsync<QInput, QOutput>(OperationInfo<QInput, QOutput> info, QInput input);
    }
}
