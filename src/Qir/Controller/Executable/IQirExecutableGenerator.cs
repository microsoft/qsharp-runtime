// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.IO;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Qir.Executable
{
    public interface IQirExecutableGenerator
    {
        /// <summary>
        /// Generates a quantum simulation program executable.
        /// </summary>
        /// <param name="driverFile">The C++ source driver file.</param>
        /// <param name="bytecodeFile">The QIR bytecode.</param>
        /// <param name="libraryDirectory">Location of the libraries that must be linked.</param>
        /// <param name="includeDirectory">Location of the headers that must be included.</param>
        /// <param name="executableFile">File path to create the executable at.</param>
        /// <returns></returns>
        Task GenerateExecutableAsync(FileInfo driverFile, FileInfo bytecodeFile, DirectoryInfo libraryDirectory, DirectoryInfo includeDirectory, FileInfo executableFile);
    }
}
