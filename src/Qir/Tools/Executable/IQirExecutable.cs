// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using Microsoft.Quantum.Qir.Serialization;

namespace Microsoft.Quantum.Qir.Runtime.Tools.Executable
{
    public interface IQirExecutable
    {
        /// <summary>
        /// Builds the executable.
        /// </summary>
        /// <param name="entryPoint">Entry point operation.</param>
        /// <param name="libraryDirectories">Directories containing libraries to link.</param>
        /// <param name="includeDirectories">Directories containing files to include.</param>
        /// <returns></returns>
        Task BuildAsync(EntryPointOperation entryPoint, IList<DirectoryInfo> libraryDirectories, IList<DirectoryInfo> includeDirectories);

        /// <summary>
        /// Runs the executable.
        /// </summary>
        /// <param name="executionInformation">Execution information to run the executable with..</param>
        /// <param name="output">Stream to which output will be written.</param>
        /// <returns></returns>
        Task RunAsync(ExecutionInformation executionInformation, Stream output);
    }
}
