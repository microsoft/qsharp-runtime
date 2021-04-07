// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.CommandLine.Invocation;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Qir.Executable
{
    public class ClangClient : IClangClient
    {
        private const string LinkFlag = " -l ";

        public async Task CreateExecutableAsync(string[] inputFiles, string[] libraries, string libraryPath, string outputPath)
        {
            var inputsArg = string.Join(' ', inputFiles);
            var librariesArg = $"{LinkFlag} {string.Join(LinkFlag, libraries)}";
            var arguments = $"{inputsArg} -L {libraryPath} {librariesArg} -o {outputPath}";
            var result = await Process.ExecuteAsync("clang", arguments, stdOut: s => { Console.WriteLine(s); }, stdErr: s => { Console.WriteLine(s); });
        }
    }
}
