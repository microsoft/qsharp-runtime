// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using Microsoft.Quantum.Qir.Driver;
using Microsoft.Quantum.Qir.Utility;
using Microsoft.Quantum.QsCompiler.BondSchemas.EntryPoint;
using Moq;
using Xunit;

namespace Tests.QirController
{
    public class QirDriverGeneratorTests : IDisposable
    {
        private readonly Mock<QirDriverGenerator> driverGeneratorMock;
        private readonly DirectoryInfo sourceDirectory;

        public QirDriverGeneratorTests()
        {
            driverGeneratorMock = new Mock<QirDriverGenerator>(Mock.Of<ILogger>()) { CallBase = true };
            driverGeneratorMock.Setup(obj => obj.GenerateQirDriverCppHelper(It.IsAny<EntryPointOperation>(), It.IsAny<Stream>()));
            sourceDirectory = new DirectoryInfo($"{Guid.NewGuid()}-source");
        }

        public void Dispose()
        {
            Util.DeleteDirectory(sourceDirectory);
        }

        [Fact]
        public async Task TestGenerateDriver()
        {
            var entryPoint = new EntryPointOperation()
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
            };
            byte[] bytes = { 1, 2, 3, 4, 5 };
            var bytecode = new ArraySegment<byte>(bytes, 1, 3);
            await driverGeneratorMock.Object.GenerateQirDriverCppAsync(sourceDirectory, entryPoint, bytecode);
            driverGeneratorMock.Verify(obj => obj.GenerateQirDriverCppHelper(It.Is<EntryPointOperation>(actualEntryPoint => Util.EntryPointsAreEqual(entryPoint, actualEntryPoint)), It.IsAny<Stream>()));

            // Verify that the "bytecode" file was created correctly.
            var bytecodeFilePath = new FileInfo(Path.Combine(sourceDirectory.FullName, "qir.bc"));
            using var bytecodeFileStream = bytecodeFilePath.OpenRead();
            Assert.Equal(bytecodeFileStream.Length, bytecode.Count);
            for (var i = 0; i < bytecodeFileStream.Length; ++i)
            {
                Assert.Equal(bytecode[i], bytecodeFileStream.ReadByte());
            }
        }
    }
}
