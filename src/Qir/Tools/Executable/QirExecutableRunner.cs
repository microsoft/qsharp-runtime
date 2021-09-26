// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Diagnostics;
using System.IO;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

#nullable enable

namespace Microsoft.Quantum.Qir.Runtime.Tools.Executable
{
    internal class QirExecutableRunner : IQirExecutableRunner
    {
        private readonly ILogger? logger;

        public QirExecutableRunner(ILogger? logger)
        {
            this.logger = logger;
        }

        public async Task RunExecutableAsync(FileInfo executableFile, Stream stream, string arguments)
        {
            logger?.LogInformation($"Invoking executable {executableFile.FullName} with the following arguments: {arguments}");
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
            logger?.LogInformation($"Executable has finished running. Result code: {process.ExitCode}");

            if (process.ExitCode != 0)
            {
                throw new InvalidOperationException($"Executable failed with exit code: {process.ExitCode}");
            }
        }
    }
}
