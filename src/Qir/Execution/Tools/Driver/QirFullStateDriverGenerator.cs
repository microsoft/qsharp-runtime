// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.IO;
using System.Threading.Tasks;
using Microsoft.Quantum.QsCompiler;
using Microsoft.Quantum.QsCompiler.BondSchemas.Execution;

namespace Microsoft.Quantum.Qir.Tools.Driver
{
    public class QirFullStateDriverGenerator: IQirDriverGenerator
    {
        private readonly QirCppDriverGenerator DriverGenerator;
        public QirFullStateDriverGenerator()
        {
            DriverGenerator = new QirCppDriverGenerator(new QirFullStateSimulatorInitializer());
        }

        public async Task GenerateAsync(EntryPointOperation entryPoint, Stream stream) =>
            await DriverGenerator.GenerateAsync(entryPoint, stream);

        public string GetCommandLineArguments(ExecutionInformation executionInformation) =>
            DriverGenerator.GetCommandLineArguments(executionInformation);
    }
}
