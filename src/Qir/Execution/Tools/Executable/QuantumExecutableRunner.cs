// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Diagnostics;
using System.IO;
using System.Threading.Tasks;
using Microsoft.Quantum.Qir.Utility;

namespace Microsoft.Quantum.Qir.Tools.Executable
{
    public class QuantumExecutableRunner : IQuantumExecutableRunner
    {
        private readonly ILogger logger;

        public QuantumExecutableRunner(ILogger logger)
        {
            this.logger = logger;
        }

        public async Task RunExecutableAsync(FileInfo executableFile, Stream stream, string arguments)
        {
            logger.LogInfo($"Invoking executable {executableFile.FullName} with the following arguments: {arguments}");
            using var process = new Process();
            process.StartInfo = new ProcessStartInfo
            {
                FileName = executableFile.FullName,
                Arguments = arguments,
                RedirectStandardOutput = true,
            };

            process.EnableRaisingEvents = true;
            process.Start();
            var output = await process.StandardOutput.ReadToEndAsync();
            process.WaitForExit();
            using var streamWriter = new StreamWriter(stream);
            await streamWriter.WriteAsync(output);
            logger.LogInfo($"Executable has finished running. Result code: {process.ExitCode}");
        }
    }
}
