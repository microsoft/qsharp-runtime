// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Microsoft.Quantum.QsCompiler.BondSchemas.EntryPoint;
using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Qir.Tools
{
    public abstract class QirExecutable
    {
        private readonly EntryPointOperation EntryPointOperation;
        private readonly byte[] QirBytecode;

        public QirExecutable(EntryPointOperation entryPoint, byte[] qirBytecode)
        {
            this.EntryPointOperation = entryPoint;
            this.QirBytecode = qirBytecode;
        }

        public Task BuildAsync(DirectoryInfo libraryDirectory, DirectoryInfo includeDirectory, FileInfo executable)
        {
            throw new NotImplementedException();
        }

        protected abstract Task GenerateDriverAsync(Stream driver);

        protected abstract IList<string> GetLinkLibraries();
    }
}
