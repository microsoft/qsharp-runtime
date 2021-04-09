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
            var expectedDriverPath = new FileInfo(Constant.FilePath.DriverFilePath);
            var expectedExecutablePath = new FileInfo(Constant.FilePath.ExecutableFilePath);
            executableGeneratorMock.Setup(obj => obj.GenerateExecutableAsync(It.IsAny<FileInfo>(), It.IsAny<FileInfo>(), It.IsAny<DirectoryInfo>(), It.IsAny<DirectoryInfo>(), It.IsAny<FileInfo>())).Callback(() =>
            {
                // Verify that the "bytecode" file was created correctly.
                using var bytecode = bytecodeFile.OpenRead();
                Assert.Equal(bytecode.Length, input.QirBytecode.Count);
                for (var i = 0; i < bytecode.Length; ++i)
                {
                    Assert.Equal(input.QirBytecode[i], bytecode.ReadByte());
                }
            });

            await Controller.ExecuteAsync(
                inputFile,
                outputFile,
                libraryDirectory,
                includeDirectory,
                errorFile,
                bytecodeFile,
                driverGeneratorMock.Object,
                executableGeneratorMock.Object,
                executableRunnerMock.Object,
                loggerMock.Object);

            // Verify driver was created.
            driverGeneratorMock.Verify(obj => obj.GenerateQirDriverCppAsync(
                It.Is<EntryPointOperation>(entryPoint => EntryPointsAreEqual(entryPoint, input.EntryPoint)),
                It.Is<FileInfo>(fileInfo => fileInfo.FullName == expectedDriverPath.FullName)));

            // Verify executable was generated.
            executableGeneratorMock.Verify(obj => obj.GenerateExecutableAsync(
                It.Is<FileInfo>(driverPath => driverPath.FullName == expectedDriverPath.FullName),
                It.Is<FileInfo>(actualBytecodeFile => actualBytecodeFile.FullName == bytecodeFile.FullName),
                It.Is<DirectoryInfo>(actualLibraryDirectory => actualLibraryDirectory.FullName == libraryDirectory.FullName),
                It.Is<DirectoryInfo>(actualIncludeDirectory => actualIncludeDirectory.FullName == includeDirectory.FullName),
                It.Is<FileInfo>(actualExecutableFile => actualExecutableFile.FullName == expectedExecutablePath.FullName)));

            // Verify executable was run.
            executableRunnerMock.Verify(obj => obj.RunExecutableAsync(
                It.Is<FileInfo>(actualExecutableFile => actualExecutableFile.FullName == expectedExecutablePath.FullName),
                It.Is<EntryPointOperation>(entryPoint => EntryPointsAreEqual(entryPoint, input.EntryPoint)),
                It.Is<DirectoryInfo>(actualLibraryDirectory => actualLibraryDirectory.FullName == libraryDirectory.FullName),
                It.Is<FileInfo>(actualOutputFile => actualOutputFile.FullName == outputFile.FullName)));
        }

        [Fact]
        public async Task TestExecuteEncountersGenericExceptionWithOutputFileAlreadyCreated()
        {
            var libraryDirectory = new DirectoryInfo("libraries");
            var includeDirectory = new DirectoryInfo("includes");
            var expectedDriverPath = new FileInfo(Constant.FilePath.DriverFilePath);
            var expectedExecutablePath = new FileInfo(Constant.FilePath.ExecutableFilePath);
            executableGeneratorMock.Setup(obj => obj.GenerateExecutableAsync(It.IsAny<FileInfo>(), It.IsAny<FileInfo>(), It.IsAny<DirectoryInfo>(), It.IsAny<DirectoryInfo>(), It.IsAny<FileInfo>()))
                .ThrowsAsync(new Exception("exception message"));

            // Create output file to ensure that it will be deleted unconditionally.
            using (var outputFileStream = outputFile.OpenWrite())
            using (var streamWriter = new StreamWriter(outputFileStream))
            {
                await streamWriter.WriteAsync("program output");
            }

            // Execute controller.
            await Controller.ExecuteAsync(
                inputFile,
                outputFile,
                libraryDirectory,
                includeDirectory,
                errorFile,
                bytecodeFile,
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

            // Verify output file was deleted.
            Assert.False(outputFile.Exists);
        }

        [Fact]
        public async Task TestExecuteEncountersGenericExceptionWithOutputFileNeverCreated()
        {
            var libraryDirectory = new DirectoryInfo("libraries");
            var includeDirectory = new DirectoryInfo("includes");
            var expectedDriverPath = new FileInfo(Constant.FilePath.DriverFilePath);
            var expectedExecutablePath = new FileInfo(Constant.FilePath.ExecutableFilePath);
            executableGeneratorMock.Setup(obj => obj.GenerateExecutableAsync(It.IsAny<FileInfo>(), It.IsAny<FileInfo>(), It.IsAny<DirectoryInfo>(), It.IsAny<DirectoryInfo>(), It.IsAny<FileInfo>()))
                .ThrowsAsync(new Exception("exception message"));

            // Execute controller.
            await Controller.ExecuteAsync(
                inputFile,
                outputFile,
                libraryDirectory,
                includeDirectory,
                errorFile,
                bytecodeFile,
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
            var expectedDriverPath = new FileInfo(Constant.FilePath.DriverFilePath);
            var expectedExecutablePath = new FileInfo(Constant.FilePath.ExecutableFilePath);
            executableGeneratorMock.Setup(obj => obj.GenerateExecutableAsync(It.IsAny<FileInfo>(), It.IsAny<FileInfo>(), It.IsAny<DirectoryInfo>(), It.IsAny<DirectoryInfo>(), It.IsAny<FileInfo>()))
                .ThrowsAsync(new ControllerException(exceptionMessage, errorCode));

            // Create output file to ensure that it will be deleted unconditionally.
            using (var outputFileStream = outputFile.OpenWrite())
            using (var streamWriter = new StreamWriter(outputFileStream))
            {
                await streamWriter.WriteAsync("program output");
            }

            // Execute controller.
            await Controller.ExecuteAsync(
                inputFile,
                outputFile,
                libraryDirectory,
                includeDirectory,
                errorFile,
                bytecodeFile,
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

            // Verify output file was deleted.
            Assert.False(outputFile.Exists);
        }

        private bool EntryPointsAreEqual(EntryPointOperation entryPointA, EntryPointOperation entryPointB)
        {
            var method = typeof(Extensions)
                .GetMethod("ValueEquals", BindingFlags.Static | BindingFlags.NonPublic, null, new[] { typeof(EntryPointOperation), typeof(EntryPointOperation) }, null);
            object[] parameters = { entryPointA, entryPointB };
            return (bool)method.Invoke(null, parameters);
        }
    }
}
