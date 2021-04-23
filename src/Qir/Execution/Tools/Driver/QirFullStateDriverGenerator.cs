// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.IO;
using System.Threading.Tasks;
using Microsoft.Quantum.QsCompiler;
using Microsoft.Quantum.QsCompiler.BondSchemas.EntryPoint;

namespace Microsoft.Quantum.Qir.Tools.Driver
{
    public class QirFullStateDriverGenerator: IQirDriverGenerator
    {
        public async Task GenerateAsync(EntryPointOperation entryPoint, Stream stream)
        {
            await Task.Run(() => QirDriverGeneration.GenerateQirDriverCpp(entryPoint, stream));
        }

        public string GetCommandLineArguments(EntryPointOperation entryPoint)
        {
            return QirDriverGeneration.GenerateCommandLineArguments(entryPoint.Arguments);
        }
    }
}
