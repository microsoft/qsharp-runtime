// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Microsoft.Quantum.QsCompiler;
using Microsoft.Quantum.QsCompiler.BondSchemas.EntryPoint;
using System.Collections.Generic;
using System;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Qir.Tools
{
    public class QirFullStateDriverGenerator : IQirDriverGenerator
    {
        public QirFullStateDriverGenerator()
        {
        }

        public async Task GenerateAsync(EntryPointOperation entryPoint, Stream stream) =>
            await Task.Run(() => QirDriverGeneration.GenerateQirDriverCpp(entryPoint, stream));

        public string GetCommandLineArguments(string entryPointName, IDictionary<string, object> arguments) => throw new NotImplementedException();

        public IList<string> LinkLibraries => Enumerable.Empty<string>().ToList();

        public string SourceType => "cpp";
    }
}
