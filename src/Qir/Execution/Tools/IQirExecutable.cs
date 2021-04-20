// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Microsoft.Quantum.QsCompiler.BondSchemas.EntryPoint;
using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Qir.Tools
{
    public interface IQirExecutable
    {
        public IQirDriverGenerator DriverGenerator { get; }

        public IList<string> LinkLibraries { get; }

        public byte[] QirBytecode { get; }

        public Task BuildAsync(FileInfo executable, EntryPointOperation entryPoint, DirectoryInfo libraryDirectory, DirectoryInfo includeDirectory);

        // TODO: How arguments are passed to this API will change.
        public Task RunAsync(FileInfo executable, string entryPointName, IDictionary<string, object> arguments, Stream output);
    }
}
