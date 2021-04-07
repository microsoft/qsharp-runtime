// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.IO;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Qir.Executable
{
    public class QirExecutableGenerator : IQirExecutableGenerator
    {
        private readonly IClangClient clangClient;

        public QirExecutableGenerator(IClangClient clangClient)
        {
            this.clangClient = clangClient;
        }

        public Task GenerateExecutableAsync(FileInfo driverFile, FileInfo bytecodeFile, DirectoryInfo libraryDirectory, FileInfo executableFile)
        {
            // TODO: Compile and link libraries- "Microsoft.Quantum.Qir.Runtime", "Microsoft.Quantum.Qir.QSharp.Foundation", "Microsoft.Quantum.Qir.QSharp.Core"
            throw new System.NotImplementedException();
        }
    }
}
