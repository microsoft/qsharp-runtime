// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using Microsoft.Quantum.Qir.Tools.Driver;
using Microsoft.Quantum.Qir.Tools.Executable;
using Microsoft.Quantum.Qir.Utility;
using Microsoft.Quantum.QsCompiler.BondSchemas.EntryPoint;
using Moq;
using Xunit;

namespace Tests.QirController
{
    public class QirExecutableTests : IDisposable
    {
        private readonly DirectoryInfo sourceDirectory;
        private readonly DirectoryInfo includeDirectory;
        private readonly DirectoryInfo libraryDirectory;
        private readonly DirectoryInfo binDirectory;
        private readonly Mock<IQirDriverGenerator> driverGeneratorMock;
        private readonly Mock<IQirExecutableGenerator> executableGeneratorMock;
        private readonly Mock<IQuantumExecutableRunner> runnerMock;
        private readonly Mock<QirExecutable> qirExecutable;
        private readonly FileInfo executableFile;
        private readonly byte[] qirBytecode = { 1, 2, 3, 4, 5 };
        private readonly IList<string> linkLibraries;

        public QirExecutableTests()
        {
            // Set up files.
            var prefix = Guid.NewGuid().ToString();
            binDirectory = new DirectoryInfo($"{prefix}-bin");
            binDirectory.Create();
            libraryDirectory = new DirectoryInfo($"{prefix}-library");
            libraryDirectory.Create();
            includeDirectory = new DirectoryInfo($"{prefix}-include");
            includeDirectory.Create();
            sourceDirectory = new DirectoryInfo($"{prefix}-source");
            sourceDirectory.Create();
            executableFile = new FileInfo(Path.Combine(binDirectory.FullName, "executable"));
            driverGeneratorMock = new Mock<IQirDriverGenerator>();
            executableGeneratorMock = new Mock<IQirExecutableGenerator>();
            runnerMock = new Mock<IQuantumExecutableRunner>();
            qirExecutable = new Mock<QirExecutable>(executableFile, qirBytecode, Mock.Of<ILogger>(), driverGeneratorMock.Object, executableGeneratorMock.Object, runnerMock.Object) { CallBase = true };
            linkLibraries = new List<string> { "lib1", "lib2" };
            qirExecutable.SetupGet(obj => obj.LinkLibraries).Returns(linkLibraries);
            qirExecutable.SetupGet(obj => obj.SourceDirectoryPath).Returns(sourceDirectory.FullName);
        }

        public void Dispose()
        {
            Util.DeleteDirectory(sourceDirectory);
            Util.DeleteDirectory(includeDirectory);
            Util.DeleteDirectory(libraryDirectory);
            Util.DeleteDirectory(binDirectory);
        }

        [Fact]
        public async Task TestBuild()
        {
            // Set up.
            var entryPoint = new EntryPointOperation();
            var driverFileContents = "driver file contents";
            driverGeneratorMock.Setup(obj => obj.GenerateAsync(entryPoint, It.IsAny<Stream>())).Callback<EntryPointOperation, Stream>((entryPoint, stream) =>
            {
                using var streamWriter = new StreamWriter(stream);
                streamWriter.Write(driverFileContents);
            });

            // Build the executable.
            await qirExecutable.Object.BuildAsync(entryPoint, libraryDirectory, includeDirectory);

            // Verify that the "bytecode" file was created correctly.
            var bytecodeFilePath = new FileInfo(Path.Combine(sourceDirectory.FullName, "qir.bc"));
            using var bytecodeFileStream = bytecodeFilePath.OpenRead();
            Assert.Equal(bytecodeFileStream.Length, qirBytecode.Length);
            for (var i = 0; i < bytecodeFileStream.Length; ++i)
            {
                Assert.Equal(qirBytecode[i], bytecodeFileStream.ReadByte());
            }

            // Verify that the driver was written to the correct file.
            var driver = new FileInfo(Path.Combine(sourceDirectory.FullName, "qir.driver"));
            using var driverStreamReader = driver.OpenText();
            var actualDriverContents = driverStreamReader.ReadToEnd();
            Assert.Equal(driverFileContents, actualDriverContents);

            // Verify that the executable was generated.
            executableGeneratorMock.Verify(obj => obj.GenerateExecutableAsync(executableFile, It.Is<DirectoryInfo>(arg => arg.FullName == sourceDirectory.FullName), libraryDirectory, includeDirectory, linkLibraries));
        }

        [Fact]
        public async Task TestRun()
        {
            // Set up.
            using var outputStream = new MemoryStream();
            var entryPoint = new EntryPointOperation();
            var arguments = "arguments";
            driverGeneratorMock.Setup(obj => obj.GetCommandLineArguments(entryPoint)).Returns(arguments);

            // Run executable.
            await qirExecutable.Object.RunAsync(entryPoint, outputStream);

            // Verify runner was invoked properly.
            runnerMock.Verify(obj => obj.RunExecutableAsync(executableFile, outputStream, arguments));
        }
    }
}
