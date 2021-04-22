// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Diagnostics;
using System.Threading.Tasks;
using Microsoft.Quantum.Qir.Utility;

namespace Microsoft.Quantum.Qir.Tools.Executable
{
    internal class ClangClient : IClangClient
    {
        private const string LinkFlag = " -l ";
        private readonly ILogger logger;

        public ClangClient(ILogger logger)
        {
            this.logger = logger;
        }

        public async Task CreateExecutableAsync(string[] inputFiles, string[] libraries, string libraryPath, string includePath, string outputPath)
        {
            var inputsArg = string.Join(' ', inputFiles);

            // string.Join does not automatically prepend the delimiter, so it is included again in the string here.
            var librariesArg = $"{LinkFlag} {string.Join(LinkFlag, libraries)}";
            var arguments = $"{inputsArg} -I {includePath} -L {libraryPath} {librariesArg} -o {outputPath}";
            logger.LogInfo($"Invoking clang with the following arguments: {arguments}");
            var taskCompletionSource = new TaskCompletionSource<bool>();
            using var process = new Process();
            process.StartInfo = new ProcessStartInfo
            {
                FileName = "clang",
                Arguments = arguments,
            };
            process.EnableRaisingEvents = true;
            process.Exited += (sender, args) => { taskCompletionSource.SetResult(true); };
            process.Start();
            await taskCompletionSource.Task;
        }
    }
}
