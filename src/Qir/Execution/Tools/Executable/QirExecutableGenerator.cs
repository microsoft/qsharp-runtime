// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

#nullable enable

namespace Microsoft.Quantum.Qir.Tools.Executable
{
    internal class QirExecutableGenerator : IQirExecutableGenerator
    {
        private readonly IClangClient clangClient;
        private readonly ILogger? logger;

        public QirExecutableGenerator(IClangClient clangClient, ILogger? logger)
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
                logger?.LogInformation($"Creating binary directory at {binDirectory.FullName}.");
                executableFile.Directory.Create();

                // Copy all library contents to bin.
                logger?.LogInformation("Copying library directories into the executable's folder.");

                if (!sourceDirectory.Exists)
                {
                    logger?.LogWarning($"Cannot find source directory: {sourceDirectory.FullName}");
                }

                var libDirs = new List<string>();
                foreach (var dir in libraryDirectories)
                {
                    if (!dir.Exists)
                    {
                        logger?.LogWarning($"Cannot find given directory: {dir.FullName}");
                    }
                    else
                    {
                        CopyDirectoryFilesIfNotExist(dir, binDirectory);
                        libDirs.Add(dir.FullName);
                    }
                }

                var includeDirs = new List<string>();
                foreach (var dir in includeDirectories)
                {
                    if (!dir.Exists)
                    {
                        logger?.LogWarning($"Could not find given directory: {dir.FullName}");
                    }
                    else
                    {
                        includeDirs.Add(dir.FullName);
                    }
                }

                var inputFiles = sourceDirectory.GetFiles().Select(fileInfo => fileInfo.FullName).ToArray();
                await clangClient.CreateExecutableAsync(inputFiles, linkLibraries.ToArray(), libDirs.ToArray(), includeDirs.ToArray(), executableFile.FullName);
            });
        }

        private void CopyFileIfNotExists(FileInfo fileToCopy, DirectoryInfo destinationDirectory)
        {
            var newPath = Path.Combine(destinationDirectory.FullName, fileToCopy.Name);
            if (!File.Exists(newPath))
            {
                var newFile = fileToCopy.CopyTo(newPath);
                logger?.LogInformation($"Copied file {fileToCopy.FullName} to {newFile.FullName}");
            }
        }

        private void CopyDirectoryFilesIfNotExist(DirectoryInfo directoryToCopy, DirectoryInfo destinationDirectory)
        {
            FileInfo[] files = directoryToCopy.GetFiles();
            foreach (var file in files)
            {
                CopyFileIfNotExists(file, destinationDirectory);
            }
        }
    }
}
