// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.IO;
using Microsoft.Quantum.QsCompiler.BondSchemas.EntryPoint;

namespace Microsoft.Quantum.Qir.Tools.Driver
{
    public class QirCppDriverGenerator
    {
        private readonly IQirSimulatorInitializer SimulatorInitalizer;

        public QirCppDriverGenerator(IQirSimulatorInitializer simulatorInitializer)
        {
            SimulatorInitalizer = simulatorInitializer;
        }

        public void GenerateDriver(EntryPointOperation entryPointOperation, Stream stream)
        {
            throw new NotImplementedException();
        }
    }
}
