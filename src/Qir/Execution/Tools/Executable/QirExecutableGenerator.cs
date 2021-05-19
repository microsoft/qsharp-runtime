// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Quantum.Qir.Utility;

namespace Microsoft.Quantum.Qir.Tools.Executable
{
    internal class QirExecutableGenerator : IQirExecutableGenerator
    {
        private readonly IClangClient clangClient;
        private readonly ILogger logger;

        public QirExecutableGenerator(IClangClient clangClient, ILogger logger)
        {
            this.clangClient = clangClient;
            this.logger = logger;
        }

        public async Task GenerateExecutableAsync(FileInfo executableFile, DirectoryInfo sourceDirectory, DirectoryInfo libraryDirectory, DirectoryInfo includeDirectory, IList<string> linkLibraries)
        {
            // Wrap in a Task.Run because FileInfo methods are not asynchronous.
            await Task.Run(async () =>
            {
                var binDirectory = executableFile.Directory;
                logger?.LogInfo($"Creating binary directory at {binDirectory.FullName}.");
                executableFile.Directory.Create();

                // Copy all library contents to bin.
                logger?.LogInfo("Copying library directory contents into the executable's folder.");
                var libraryFiles = libraryDirectory.GetFiles();
                foreach (var file in libraryFiles)
                {
                    CopyFileIfNotExists(file, binDirectory);
                }

                var inputFiles = sourceDirectory.GetFiles().Select(fileInfo => fileInfo.FullName).ToArray();
                await clangClient.CreateExecutableAsync(inputFiles, linkLibraries.ToArray(), libraryDirectory.FullName, includeDirectory.FullName, executableFile.FullName);
            });
        }

        private void CopyFileIfNotExists(FileInfo fileToCopy, DirectoryInfo destinationDirectory)
        {
            var newPath = Path.Combine(destinationDirectory.FullName, fileToCopy.Name);
            if (!File.Exists(newPath))
            {
                var newFile = fileToCopy.CopyTo(newPath);
                logger?.LogInfo($"Copied file {fileToCopy.FullName} to {newFile.FullName}");
            }
        }
    }
}
