// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.Quantum.QsCompiler.BondSchemas.EntryPoint;

namespace Microsoft.Quantum.Qir.Tools.Driver
{
    public class QirCppDriverGenerator : IQirDriverGenerator
    {
        private readonly IQirSimulatorInitializer SimulatorInitalizer;

        public QirCppDriverGenerator(IQirSimulatorInitializer simulatorInitializer)
        {
            SimulatorInitalizer = simulatorInitializer;
        }

        public async Task GenerateAsync(EntryPointOperation entryPointOperation, Stream stream)
        {
            throw new NotImplementedException();
        }

        public string GetCommandLineArguments(EntryPointOperation entryPoint) => throw new NotImplementedException();
    }
}
