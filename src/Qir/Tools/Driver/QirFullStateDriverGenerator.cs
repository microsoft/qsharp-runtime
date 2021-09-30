// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.IO;
using System.Threading.Tasks;
using Microsoft.Quantum.Qir.Runtime.Tools.Serialization;

namespace Microsoft.Quantum.Qir.Runtime.Tools.Driver
{
    public class QirFullStateDriverGenerator: IQirDriverGenerator
    {
        private readonly QirCppDriverGenerator DriverGenerator;

        public QirFullStateDriverGenerator(bool debug) =>
            DriverGenerator = new QirCppDriverGenerator(new QirFullStateSimulatorInitializer(debug));

        public async Task GenerateAsync(EntryPointOperation entryPoint, Stream stream) =>
            await DriverGenerator.GenerateAsync(entryPoint, stream);

        public string GetCommandLineArguments(ExecutionInformation executionInformation) =>
            DriverGenerator.GetCommandLineArguments(executionInformation);
    }
}
