// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.CommandLine.Invocation;
using System.Threading.Tasks;
using Microsoft.Quantum.Qir.Utility;

namespace Microsoft.Quantum.Qir.Executable
{
    public class ClangClient : IClangClient
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
            var result = await Process.ExecuteAsync(
                "clang",
                arguments,
                stdOut: s => { logger.LogInfo("clang: " + s); },
                stdErr: s => { logger.LogError("clang: "  + s); });
        }
    }
}
