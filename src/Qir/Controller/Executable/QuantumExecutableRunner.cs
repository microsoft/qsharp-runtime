// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.IO;
using System.Threading.Tasks;
using Microsoft.Quantum.Qir.Utility;
using Microsoft.Quantum.QsCompiler.BondSchemas.EntryPoint;

namespace Microsoft.Quantum.Qir.Executable
{
    public class QuantumExecutableRunner : IQuantumExecutableRunner
    {
        private readonly ILogger logger;

        public QuantumExecutableRunner(ILogger logger)
        {
            this.logger = logger;
        }

        public Task RunExecutableAsync(FileInfo executableFile, EntryPointOperation entryPointOperation, DirectoryInfo libraryDirectory, FileInfo outputFile)
        {
            throw new System.NotImplementedException();
        }
    }
}
