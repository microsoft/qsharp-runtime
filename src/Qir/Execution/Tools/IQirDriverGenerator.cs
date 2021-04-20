// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Microsoft.Quantum.QsCompiler.BondSchemas.EntryPoint;
using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Qir.Tools
{
    public interface IQirDriverGenerator
    {
        public Task GenerateAsync(EntryPointOperation entryPoint, Stream stream);

        // TODO: How arguments are passed to this API will change.
        public string GetCommandLineArguments(string entryPointName, IDictionary<string, object> arguments);

        public IList<string> LinkLibraries { get; }

        public string SourceType { get; }
    }
}
