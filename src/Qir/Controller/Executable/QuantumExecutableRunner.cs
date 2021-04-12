// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;
using System.CommandLine.Invocation;
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

        public async Task RunExecutableAsync(FileInfo executableFile, EntryPointOperation entryPointOperation, FileInfo outputFile)
        {
            var arguments = GenerateArgumentsString(entryPointOperation.Arguments);
            logger.LogInfo($"Invoking executable {executableFile.FullName} with the following arguments: {arguments}");
            using var outputFileStream = outputFile.OpenWrite();
            using var streamWriter = new StreamWriter(outputFileStream);
            var result = await Process.ExecuteAsync(
                executableFile.FullName,
                arguments,
                stdOut: async s => { await streamWriter.WriteAsync(s); },
                stdErr: s => { logger.LogError("executable: " + s); });
            logger.LogInfo("Executable has finished running.");
        }

        private string GenerateArgumentsString(IList<Argument> args)
        {
            throw new System.NotImplementedException();
        }
    }
}
