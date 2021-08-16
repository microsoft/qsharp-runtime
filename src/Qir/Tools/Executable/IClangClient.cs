// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Threading.Tasks;

namespace Microsoft.Quantum.Qir.Runtime.Tools.Executable
{
    /// <summary>
    /// Wraps the 'clang' tool used for compilation.
    /// </summary>
    public interface IClangClient
    {
        Task CreateExecutableAsync(string[] inputFiles, string[] linkedLibraries, string[] libraryPaths, string[] includePaths, string outputPath);
    }
}
