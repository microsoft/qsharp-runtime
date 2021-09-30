// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Diagnostics;
using System.IO;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

namespace Microsoft.Quantum.Qir.Runtime.Tools.Executable
{
    internal class ClangClient : IClangClient
    {
        private const string LinkFlag = " -l ";
        private const string LibraryPathFlag = " -L ";
        private const string IncludePathFlag = " -I ";
        private readonly ILogger? logger;

        public ClangClient(ILogger? logger)
        {
            this.logger = logger;
        }

        public async Task CreateExecutableAsync(string[] inputFiles, string[] linkedLibraries, string[] libraryPaths, string[] includePaths, string outputPath)
        {
            var inputsArg = string.Join(' ', inputFiles);

            // string.Join does not automatically prepend the delimiter, so it is included again in the string here.
            var linkedLibrariesArg = $"{LinkFlag} {string.Join(LinkFlag, linkedLibraries)}";
            var libraryPathsArg = $"{LibraryPathFlag} {string.Join(LibraryPathFlag, libraryPaths)}";
            var includePathsArg = $"{IncludePathFlag} {string.Join(IncludePathFlag, includePaths)}";
            var arguments = $"{inputsArg} {includePathsArg} {libraryPathsArg} {linkedLibrariesArg} -o {outputPath} -std=c++17 -v";
            logger?.LogInformation($"Invoking clang with the following arguments: {arguments}");
            var taskCompletionSource = new TaskCompletionSource<bool>();
            using var process = new Process();
            AddPathsToEnvironmentVariable("DYLD_LIBRARY_PATH", libraryPaths);
            AddPathsToEnvironmentVariable("LD_LIBRARY_PATH", libraryPaths);
            process.StartInfo = new ProcessStartInfo
            {
                FileName = "clang++",
                Arguments = arguments,
            };
            process.EnableRaisingEvents = true;
            process.Exited += (sender, args) => { taskCompletionSource.SetResult(true); };
            process.Start();
            await taskCompletionSource.Task;
        }

        private static void AddPathsToEnvironmentVariable(string variable, string[] values)
        {
            var newValue = string.Join(Path.PathSeparator, values);
            var oldValue = Environment.GetEnvironmentVariable(variable);
            if (oldValue != null)
            {
                newValue = oldValue + $"{Path.PathSeparator}{newValue}";
            }
            Environment.SetEnvironmentVariable(variable, newValue);
        }
    }
}
