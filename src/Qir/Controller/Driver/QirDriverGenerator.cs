// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.IO;
using System.Threading.Tasks;
using Microsoft.Quantum.Qir.Utility;
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

        public Task GenerateQirDriverCppAsync(EntryPointOperation entryPointOperation, FileInfo driverFile)
        {
            throw new System.NotImplementedException();
        }
    }
}
