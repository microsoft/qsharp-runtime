// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.IO;
using System.Threading.Tasks;
using Microsoft.Quantum.QsCompiler.BondSchemas.EntryPoint;

namespace Microsoft.Quantum.Qir.Executable
{
    public class QuantumExecutableRunner : IQuantumExecutableRunner
    {
        public Task RunExecutableAsync(FileInfo executableFile, EntryPointOperation entryPointOperation, FileInfo outputFile)
        {
            throw new System.NotImplementedException();
        }
    }
}
