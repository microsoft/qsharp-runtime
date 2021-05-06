// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.IO;
using System.Threading.Tasks;
using Microsoft.Quantum.Qir.Serialization;
using Microsoft.Quantum.QsCompiler;

namespace Microsoft.Quantum.Qir.Tools.Driver
{
    public class QirFullStateDriverGenerator: IQirDriverGenerator
    {
        public async Task GenerateAsync(EntryPointOperation entryPoint, Stream stream)
        {
            await Task.Run(() => QirDriverGeneration.GenerateQirDriverCpp(entryPoint, stream));
        }

        public string GetCommandLineArguments(ExecutionInformation executionInformation)
        {
            return QirDriverGeneration.GenerateCommandLineArguments(executionInformation);
        }
    }
}
