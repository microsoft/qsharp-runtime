// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.Quantum.Qir.Utility;
using Microsoft.Quantum.QsCompiler;
using Microsoft.Quantum.QsCompiler.BondSchemas.EntryPoint;

namespace Microsoft.Quantum.Qir.Driver
{
    public class QirSourceFileGenerator : IQirSourceFileGenerator
    {
        private const string BytecodeFileName = "qir.bc";
        private const string DriverFileName = "driver.cpp";
        private readonly ILogger logger;

        public QirSourceFileGenerator(ILogger logger)
        {
            this.logger = logger;
        }

        public async Task GenerateQirSourceFilesAsync(DirectoryInfo sourceDirectory, EntryPointOperation entryPointOperation, ArraySegment<byte> bytecode)
        {
            if (sourceDirectory.Exists)
            {
                sourceDirectory.Delete(true);
            }

            sourceDirectory.Create();
            logger.LogInfo($"Created source directory at {sourceDirectory.FullName}.");

            // Create driver.
            var driverFile = new FileInfo(Path.Combine(sourceDirectory.FullName, DriverFileName));
            using var driverFileStream = driverFile.OpenWrite();
            GenerateQirDriverCppHelper(entryPointOperation, driverFileStream);
            logger.LogInfo($"Created driver file at {driverFile.FullName}.");

            // Create bytecode file.
            var bytecodeFile = new FileInfo(Path.Combine(sourceDirectory.FullName, BytecodeFileName));
            using var bytecodeFileStream = bytecodeFile.OpenWrite();
            await bytecodeFileStream.WriteAsync(bytecode.Array, bytecode.Offset, bytecode.Count);
            logger.LogInfo($"Created bytecode file at {bytecodeFile.FullName}.");
        }

        // Virtual method wrapper is to enable mocking in unit tests.
        public virtual void GenerateQirDriverCppHelper(EntryPointOperation entryPointOperation, Stream stream)
        {
            QirDriverGeneration.GenerateQirDriverCpp(entryPointOperation, stream);
        }
    }
}
