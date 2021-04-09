// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.IO;
using System.Threading.Tasks;
using Microsoft.Quantum.Qir.Utility;

namespace Microsoft.Quantum.Qir.Executable
{
    public class QirExecutableGenerator : IQirExecutableGenerator
    {
        private readonly IClangClient clangClient;
        private readonly ILogger logger;

        public QirExecutableGenerator(IClangClient clangClient, ILogger logger)
        {
            this.clangClient = clangClient;
            this.logger = logger;
        }

        public Task GenerateExecutableAsync(FileInfo driverFile, FileInfo bytecodeFile, DirectoryInfo libraryDirectory, DirectoryInfo includeDirectory, FileInfo executableFile)
        {
            // TODO: Compile and link libraries- "Microsoft.Quantum.Qir.Runtime", "Microsoft.Quantum.Qir.QSharp.Foundation", "Microsoft.Quantum.Qir.QSharp.Core"
            throw new System.NotImplementedException();
        }
    }
}
