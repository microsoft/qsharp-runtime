// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Microsoft.Quantum.QsCompiler.BondSchemas.EntryPoint;
using System;
using System.Collections.Generic;
using System.IO;

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

        public void Build(FileInfo executable, DirectoryInfo libraryDirectory, DirectoryInfo includeDirectory)
        {
            throw new NotImplementedException();
        }

        protected abstract void GenerateDriver(Stream driver);

        protected abstract IList<string> GetLinkLibraries();
    }
}
