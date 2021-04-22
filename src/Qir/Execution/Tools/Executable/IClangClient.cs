// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Threading.Tasks;

namespace Microsoft.Quantum.Qir.Tools.Executable
{
    /// <summary>
    /// Wraps the 'clang' tool used for compilation.
    /// </summary>
    internal interface IClangClient
    {
        Task CreateExecutableAsync(string[] inputFiles, string[] libraries, string libraryPath, string includePath, string outputPath);
    }
}
