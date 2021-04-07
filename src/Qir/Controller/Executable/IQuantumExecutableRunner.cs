// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.IO;
using System.Threading.Tasks;
using Microsoft.Quantum.QsCompiler.BondSchemas.EntryPoint;

namespace Microsoft.Quantum.Qir.Executable
{
    public interface IQuantumExecutableRunner
    {
        /// <summary>
        /// Runs a quantum program executable with the given arguments.
        /// </summary>
        /// <param name="executableFile">Location of the executable to run.</param>
        /// <param name="entryPointOperation">Entry point and arguments to pass.</param>
        /// <param name="outputFile">Location to write program output.</param>
        /// <returns></returns>
        Task RunExecutableAsync(FileInfo executableFile, EntryPointOperation entryPointOperation, FileInfo outputFile);
    }
}
