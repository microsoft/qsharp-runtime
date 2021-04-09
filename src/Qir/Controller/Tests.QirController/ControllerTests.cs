// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.Quantum.Qir;
using Microsoft.Quantum.Qir.Driver;
using Microsoft.Quantum.Qir.Executable;
using Microsoft.Quantum.Qir.Model;
using Microsoft.Quantum.Qir.Utility;
using Microsoft.Quantum.QsCompiler.BondSchemas.EntryPoint;
using Microsoft.Quantum.QsCompiler.BondSchemas.QirExecutionWrapper;
using Moq;
using Xunit;
using QirExecutionWrapperSerialization = Microsoft.Quantum.QsCompiler.BondSchemas.QirExecutionWrapper.Protocols;

namespace Tests.QirController
{
    public class ControllerTests : IDisposable
    {
        private Mock<IQirDriverGenerator> driverGeneratorMock;
        private Mock<IQirExecutableGenerator> executableGeneratorMock;
        private Mock<IQuantumExecutableRunner> executableRunnerMock;
        private Mock<ILogger> loggerMock;
        private FileInfo inputFile;
        private FileInfo bytecodeFile;
        private FileInfo errorFile;
        private FileInfo outputFile;
        private QirExecutionWrapper input;

        public ControllerTests()
        {
            driverGeneratorMock = new Mock<IQirDriverGenerator>();
            executableGeneratorMock = new Mock<IQirExecutableGenerator>();
            executableRunnerMock = new Mock<IQuantumExecutableRunner>();
            inputFile = new FileInfo($"{Guid.NewGuid()}-input");
            bytecodeFile = new FileInfo($"{Guid.NewGuid()}-bytecode");
            errorFile = new FileInfo($"{Guid.NewGuid()}-error");
            outputFile = new FileInfo($"{Guid.NewGuid()}-output");
            loggerMock = new Mock<ILogger>();

            // Create a QirExecutableWrapper to be used by the tests.
            byte[] bytecode = { 1, 2, 3, 4, 5 };
            input = new QirExecutionWrapper()
            {
                EntryPoint = new EntryPointOperation()
                {
                    Arguments = new List<Argument>
                    {
                        new Argument()
                        {
                            Position = 0,
                            Name = "argname",
                            Values = new List<ArgumentValue> { new ArgumentValue { String = "argvalue" } },
                        }
                    }
                },
                QirBytecode = new ArraySegment<byte>(bytecode, 1, 3),
            };
            using var fileStream = inputFile.OpenWrite();
            QirExecutionWrapperSerialization.SerializeToFastBinary(input, fileStream);
        }

        public void Dispose()
        {
            inputFile.Delete();
            bytecodeFile.Delete();
            errorFile.Delete();
            outputFile.Delete();
        }

        [Fact]
        public async Task TestExecute()
        {
            var libraryDirectory = new DirectoryInfo("libraries");
            var includeDirectory = new DirectoryInfo("includes");
            FileInfo actualExecutableFile = null;
            Action<FileInfo, DirectoryInfo, DirectoryInfo, DirectoryInfo> generateExecutableCallback = async (executableFile, srcDir, libDir, inclDir) =>
            {
                actualExecutableFile = executableFile;
                await Task.CompletedTask;
            };
            executableGeneratorMock.Setup(obj => obj.GenerateExecutableAsync(
                It.IsAny<FileInfo>(),
                It.IsAny<DirectoryInfo>(),
                It.Is<DirectoryInfo>(actualLibraryDirectory => actualLibraryDirectory.FullName == libraryDirectory.FullName),
                It.Is<DirectoryInfo>(actualIncludeDirectory => actualIncludeDirectory.FullName == includeDirectory.FullName))).Callback(generateExecutableCallback);

            await Controller.ExecuteAsync(
                inputFile,
                outputFile,
                libraryDirectory,
                includeDirectory,
                errorFile,
                driverGeneratorMock.Object,
                executableGeneratorMock.Object,
                executableRunnerMock.Object,
                loggerMock.Object);

            // Verify driver was created.
            driverGeneratorMock.Verify(obj => obj.GenerateQirDriverCppAsync(
                It.IsAny<DirectoryInfo>(),
                It.Is<EntryPointOperation>(entryPoint => Util.EntryPointsAreEqual(entryPoint, input.EntryPoint)),
                It.Is<ArraySegment<byte>>(bytecode => BytecodesAreEqual(bytecode, input.QirBytecode))));

            // Verify executable was generated.
            executableGeneratorMock.Verify(obj => obj.GenerateExecutableAsync(
                It.IsAny<FileInfo>(),
                It.IsAny<DirectoryInfo>(),
                It.Is<DirectoryInfo>(actualLibraryDirectory => actualLibraryDirectory.FullName == libraryDirectory.FullName),
                It.Is<DirectoryInfo>(actualIncludeDirectory => actualIncludeDirectory.FullName == includeDirectory.FullName)));
            Assert.NotNull(actualExecutableFile);

            // Verify executable was run.
            executableRunnerMock.Verify(obj => obj.RunExecutableAsync(
                It.Is<FileInfo>(executableFile => actualExecutableFile.FullName == executableFile.FullName),
                It.Is<EntryPointOperation>(entryPoint => Util.EntryPointsAreEqual(entryPoint, input.EntryPoint)),
                It.Is<FileInfo>(actualOutputFile => actualOutputFile.FullName == outputFile.FullName)));
        }

        [Fact]
        public async Task TestExecuteEncountersGenericException()
        {
            var libraryDirectory = new DirectoryInfo("libraries");
            var includeDirectory = new DirectoryInfo("includes");
            executableGeneratorMock.Setup(obj => obj.GenerateExecutableAsync(It.IsAny<FileInfo>(), It.IsAny<DirectoryInfo>(), It.IsAny<DirectoryInfo>(), It.IsAny<DirectoryInfo>()))
                .ThrowsAsync(new Exception("exception message"));

            // Execute controller.
            await Controller.ExecuteAsync(
                inputFile,
                outputFile,
                libraryDirectory,
                includeDirectory,
                errorFile,
                driverGeneratorMock.Object,
                executableGeneratorMock.Object,
                executableRunnerMock.Object,
                loggerMock.Object);

            // Verify error file was created and contains the error.
            Assert.True(errorFile.Exists);
            using var errorFileStream = errorFile.OpenRead();
            using var streamReader = new StreamReader(errorFileStream);
            var errorFileContents = await streamReader.ReadToEndAsync();
            var error = JsonSerializer.Deserialize<Error>(errorFileContents);
            Assert.Equal(ErrorMessages.InternalError, error.Message);
            Assert.Equal(Constant.ErrorCode.InternalError, error.Code);
        }

        [Fact]
        public async Task TestExecuteEncountersControllerException()
        {
            var exceptionMessage = "exception message";
            var errorCode = "error code";
            var libraryDirectory = new DirectoryInfo("libraries");
            var includeDirectory = new DirectoryInfo("includes");
            executableGeneratorMock.Setup(obj => obj.GenerateExecutableAsync(It.IsAny<FileInfo>(), It.IsAny<DirectoryInfo>(), It.IsAny<DirectoryInfo>(), It.IsAny<DirectoryInfo>()))
                .ThrowsAsync(new ControllerException(exceptionMessage, errorCode));

            // Execute controller.
            await Controller.ExecuteAsync(
                inputFile,
                outputFile,
                libraryDirectory,
                includeDirectory,
                errorFile,
                driverGeneratorMock.Object,
                executableGeneratorMock.Object,
                executableRunnerMock.Object,
                loggerMock.Object);

            // Verify error file was created and contains the error.
            Assert.True(errorFile.Exists);
            using var errorFileStream = errorFile.OpenRead();
            using var streamReader = new StreamReader(errorFileStream);
            var errorFileContents = await streamReader.ReadToEndAsync();
            var error = JsonSerializer.Deserialize<Error>(errorFileContents);
            Assert.Equal(exceptionMessage, error.Message);
            Assert.Equal(errorCode, error.Code);
        }

        private bool BytecodesAreEqual(ArraySegment<byte> bytecodeA, ArraySegment<byte> bytecodeB)
        {
            if (bytecodeA.Count != bytecodeB.Count)
            {
                return false;
            }

            for (var i = 0; i < bytecodeA.Count; ++i)
            {
                if (bytecodeA[i] != bytecodeB[i])
                {
                    return false;
                }
            }

            return true;
        }
    }
}
