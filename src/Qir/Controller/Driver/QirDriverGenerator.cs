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
    public class QirDriverGenerator : IQirDriverGenerator
    {
        private readonly ILogger logger;

        public QirDriverGenerator(ILogger logger)
        {
            this.logger = logger;
        }

        public Task GenerateQirDriverCppAsync(DirectoryInfo sourceDirectory, EntryPointOperation entryPointOperation, ArraySegment<byte> bytecode)
        {
            await Task.Run(() =>
            {
                logger.LogInfo("Creating driver file.");
                using var driverFileStream = driverFile.OpenWrite();
                QirDriverGeneration.GenerateQirDriverCpp(entryPointOperation, driverFileStream);
            });
        }
    }
}
