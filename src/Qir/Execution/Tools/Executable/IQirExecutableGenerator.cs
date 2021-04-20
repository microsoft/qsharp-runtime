// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Qir.Tools.Executable
{
    public interface IQirExecutableGenerator
    {
        /// <summary>
        /// Generates a quantum simulation program executable.
        /// </summary>
        /// <param name="executableFile">File path to create the executable at. Dependencies will be copied to its directory.</param>
        /// <param name="sourceDirectory">Location of the source files.</param>
        /// <param name="libraryDirectory">Location of the libraries that must be linked.</param>
        /// <param name="includeDirectory">Location of the headers that must be included.</param>
        /// <param name="linkLibraries">Libraries to link.</param>
        /// <returns></returns>
        public Task GenerateExecutableAsync(FileInfo executableFile, DirectoryInfo sourceDirectory, DirectoryInfo libraryDirectory, DirectoryInfo includeDirectory, IList<string> linkLibraries);
    }
}
