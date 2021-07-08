// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Quantum.Qir.Serialization;
using Microsoft.Quantum.Qir.Tools.Driver;
using Microsoft.Quantum.Qir.Tools.Executable;
using Moq;
using Xunit;

namespace Tests.Microsoft.Quantum.Qir.Tools
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
        private readonly IList<DirectoryInfo> headerDirectories;
        private readonly IList<DirectoryInfo> libraryDirectories;

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
            qirExecutable = new Mock<QirExecutable>(executableFile, qirBytecode, driverGeneratorMock.Object, executableGeneratorMock.Object, runnerMock.Object, null) { CallBase = true };
            linkLibraries = new List<string> { "lib1", "lib2" };
            headerDirectories = new List<DirectoryInfo>();
            libraryDirectories = new List<DirectoryInfo>();
            qirExecutable.SetupGet(obj => obj.LinkLibraries).Returns(linkLibraries);
            qirExecutable.SetupGet(obj => obj.SourceDirectoryPath).Returns(sourceDirectory.FullName);
            qirExecutable.SetupGet(obj => obj.DriverFileExtension).Returns(".cpp");
            qirExecutable.SetupGet(obj => obj.HeaderDirectories).Returns(headerDirectories);
            qirExecutable.SetupGet(obj => obj.LibraryDirectories).Returns(libraryDirectories);
        }

        public void Dispose()
        {
            sourceDirectory.Delete(true);
            includeDirectory.Delete(true);
            libraryDirectory.Delete(true);
            binDirectory.Delete(true);
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
            await qirExecutable.Object.BuildAsync(entryPoint, new[] { libraryDirectory }, new[] { includeDirectory });

            // Verify that the "bytecode" file was created correctly.
            var bytecodeFilePath = new FileInfo(Path.Combine(sourceDirectory.FullName, "qir.bc"));
            using var bytecodeFileStream = bytecodeFilePath.OpenRead();
            Assert.True(Util.CompareStreams(new MemoryStream(qirBytecode), bytecodeFileStream));

            // Verify that the driver was written to the correct file.
            var driver = new FileInfo(Path.Combine(sourceDirectory.FullName, "driver.cpp"));
            using var driverStreamReader = driver.OpenText();
            var actualDriverContents = driverStreamReader.ReadToEnd();
            Assert.Equal(driverFileContents, actualDriverContents);

            // Verify that the executable was generated.
            executableGeneratorMock.Verify(obj => obj.GenerateExecutableAsync(executableFile, It.Is<DirectoryInfo>(arg => arg.FullName == sourceDirectory.FullName), new[] { libraryDirectory }, new[] { includeDirectory }, linkLibraries));
        }

        [Fact]
        public async Task TestRun()
        {
            // Set up.
            using var outputStream = new MemoryStream();
            var execInfo = new ExecutionInformation();
            var arguments = "arguments";
            driverGeneratorMock.Setup(obj => obj.GetCommandLineArguments(execInfo)).Returns(arguments);

            // Run executable.
            await qirExecutable.Object.RunAsync(execInfo, outputStream);

            // Verify runner was invoked properly.
            runnerMock.Verify(obj => obj.RunExecutableAsync(executableFile, outputStream, arguments));
        }
    }
}
