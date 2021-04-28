// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.IO;
using System.Text;
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
            var qirCppDriver = new QirCppDriver(entryPointOperation, SimulatorInitalizer);
            var cppSource = qirCppDriver.TransformText();
            await stream.WriteAsync(Encoding.UTF8.GetBytes(cppSource));
            await stream.FlushAsync();
            stream.Position = 0;
        }

        public string GetCommandLineArguments(EntryPointOperation entryPoint) => throw new NotImplementedException();
    }
}
