// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.IO;
using System.Threading.Tasks;
using Microsoft.Quantum.QsCompiler.BondSchemas.Execution;

namespace Microsoft.Quantum.Qir.Tools.Executable
{
    public interface IQirExecutable
    {
        /// <summary>
        /// Builds the executable.
        /// </summary>
        /// <param name="entryPoint">Entry point operation.</param>
        /// <param name="libraryDirectory">Directory containing libraries to link.</param>
        /// <param name="includeDirectory">Directory containing files to include.</param>
        /// <returns></returns>
        Task BuildAsync(EntryPointOperation entryPoint, DirectoryInfo libraryDirectory, DirectoryInfo includeDirectory);

        /// <summary>
        /// Runs the executable.
        /// </summary>
        /// <param name="executionInformation">Execution information to run the executable with..</param>
        /// <param name="output">Stream to which output will be written.</param>
        /// <returns></returns>
        Task RunAsync(ExecutionInformation executionInformation, Stream output);
    }
}
