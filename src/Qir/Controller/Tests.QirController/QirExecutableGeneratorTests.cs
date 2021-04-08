// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Quantum.Qir.Executable;
using Microsoft.Quantum.Qir.Utility;
using Moq;
using Xunit;

namespace Tests.QirController
{
    public class QirExecutableGeneratorTests
    {
        private readonly Mock<IClangClient> clangClientMock;
        private readonly QirExecutableGenerator executableGenerator;

        public QirExecutableGeneratorTests()
        {
            clangClientMock = new Mock<IClangClient>();
            executableGenerator = new QirExecutableGenerator(clangClientMock.Object, Mock.Of<ILogger>());
        }

        [Fact]
        public async Task TestGenerateExecutable()
        {
            var driverFile = new FileInfo("driver");
            var bytecodeFile = new FileInfo("bytecode");
            var libraryDirectory = new DirectoryInfo("libraries");
            var executableFile = new FileInfo("executable");
            string[] expectedLibraries = {
                "Microsoft.Quantum.Qir.Runtime",
                "Microsoft.Quantum.Qir.QSharp.Foundation",
                "Microsoft.Quantum.Qir.QSharp.Core",
            };
            string[] expectedInputFiles = { driverFile.FullName, bytecodeFile.FullName };
            await executableGenerator.GenerateExecutableAsync(driverFile, bytecodeFile, libraryDirectory, executableFile);
            clangClientMock.Verify(obj => obj.CreateExecutableAsync(
                It.Is<string[]>(s => s.SequenceEqual(expectedInputFiles)),
                It.Is<string[]>(s => s.SequenceEqual(expectedLibraries)),
                libraryDirectory.FullName,
                executableFile.FullName));
        }
    }
}
