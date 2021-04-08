// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.IO;
using System.Threading.Tasks;
using Microsoft.Quantum.Qir.Utility;

namespace Microsoft.Quantum.Qir.Executable
{
    public class QirExecutableGenerator : IQirExecutableGenerator
    {
        private static readonly string[] LibrariesToLink = {
            "Microsoft.Quantum.Qir.Runtime",
            "Microsoft.Quantum.Qir.QSharp.Foundation",
            "Microsoft.Quantum.Qir.QSharp.Core"
        };
        private readonly IClangClient clangClient;
        private readonly ILogger logger;

        public QirExecutableGenerator(IClangClient clangClient, ILogger logger)
        {
            this.clangClient = clangClient;
            this.logger = logger;
        }

        public async Task GenerateExecutableAsync(FileInfo driverFile, FileInfo bytecodeFile, DirectoryInfo libraryDirectory, FileInfo executableFile)
        {
            logger.LogInfo("Generating executable.");
            string[] inputFiles = { driverFile.FullName, bytecodeFile.FullName };
            await clangClient.CreateExecutableAsync(inputFiles, LibrariesToLink, libraryDirectory.FullName, executableFile.FullName);
        }
    }
}
