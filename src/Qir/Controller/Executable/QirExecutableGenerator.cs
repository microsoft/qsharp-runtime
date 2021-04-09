// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.IO;
using System.Linq;
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

        public async Task GenerateExecutableAsync(FileInfo executableFile, DirectoryInfo sourceDirectory, DirectoryInfo libraryDirectory, DirectoryInfo includeDirectory)
        {
            // Wrap in a Task.Run because FileInfo methods are not asynchronous.
            await Task.Run(async () =>
            {
                var binDirectory = executableFile.Directory;
                logger.LogInfo($"Creating binary directory at {binDirectory.FullName}.");
                executableFile.Directory.Create();

                // Copy all library contents to bin.
                logger.LogInfo("Copying library directory contents into the executable's folder.");
                var libraryFiles = libraryDirectory.GetFiles();
                foreach (var file in libraryFiles)
                {
                    var newFile = file.CopyTo(Path.Combine(binDirectory.FullName, file.Name));
                    logger.LogInfo($"Copied file {file.FullName} to {newFile.FullName}");
                }

                // Copy all include contents to bin.
                logger.LogInfo("Copying include directory contents into the executable's folder.");
                var includeFiles = includeDirectory.GetFiles();
                foreach (var file in includeFiles)
                {
                    var newFile = file.CopyTo(Path.Combine(binDirectory.FullName, file.Name));
                    logger.LogInfo($"Copied file {file.FullName} to {newFile.FullName}");
                }

                var inputFiles = sourceDirectory.GetFiles().Select(fileInfo => fileInfo.FullName).ToArray();
                await clangClient.CreateExecutableAsync(inputFiles, LibrariesToLink, libraryDirectory.FullName, includeDirectory.FullName, executableFile.FullName);
            });
        }
    }
}
