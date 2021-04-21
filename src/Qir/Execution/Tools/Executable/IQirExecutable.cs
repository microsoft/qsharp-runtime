// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.IO;
using System.Threading.Tasks;
using Microsoft.Quantum.QsCompiler.BondSchemas.EntryPoint;

namespace Microsoft.Quantum.Qir.Tools.Executable
{
    public interface IQirExecutable
    {
        Task BuildAsync(EntryPointOperation entryPoint, DirectoryInfo libraryDirectory, DirectoryInfo includeDirectory);

        Task RunAsync(EntryPointOperation entryPoint, Stream output);
    }
}
