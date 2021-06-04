// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
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

        public async Task GenerateExecutableAsync(FileInfo executableFile, DirectoryInfo sourceDirectory, IList<DirectoryInfo> libraryDirectories, IList<DirectoryInfo> includeDirectories, IList<string> linkLibraries)
        {
            // Wrap in a Task.Run because FileInfo methods are not asynchronous.
            await Task.Run(async () =>
            {
                var binDirectory = executableFile.Directory;
                logger?.LogInfo($"Creating binary directory at {binDirectory.FullName}.");
                executableFile.Directory.Create();

                // Copy all library contents to bin.
                logger?.LogInfo("Copying library directories into the executable's folder.");

                if (!sourceDirectory.Exists)
                {
                    throw new ArgumentException($"Could not find source directory: {sourceDirectory.FullName}");
                }

                foreach (var dir in libraryDirectories)
                {
                    if (!dir.Exists)
                    {
                        throw new ArgumentException($"Could not find given directory: {dir.FullName}");
                    }
                    CopyDirectoryContents(dir, binDirectory);
                }

                foreach (var dir in includeDirectories)
                {
                    if (!dir.Exists)
                    {
                        throw new ArgumentException($"Could not find given directory: {dir.FullName}");
                    }
                }

                var inputFiles = sourceDirectory.GetFiles().Select(fileInfo => fileInfo.FullName).ToArray();
                await clangClient.CreateExecutableAsync(inputFiles, linkLibraries.ToArray(), libraryDirectories.Select(dir => dir.FullName).ToArray(), includeDirectories.Select(dir => dir.FullName).ToArray(), executableFile.FullName);
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

        private void CopyDirectoryContents(DirectoryInfo directoryToCopy, DirectoryInfo destinationDirectory)
        {
            FileInfo[] files = directoryToCopy.GetFiles();
            foreach (var file in files)
            {
                CopyFileIfNotExists(file, destinationDirectory);
            }
        }
    }
}
