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

        public Task BuildAsync(DirectoryInfo librariesDirectory, DirectoryInfo includeDirectory, FileInfo executable)
        {
            throw new NotImplementedException();
        }

        // TODO: How arguments are passed to this API will change.
        public Task RunAsync(FileInfo executable, DirectoryInfo librariesDirectory, IList<ArgumentValue> arguments)
        {
            throw new NotImplementedException();
        }

        // TODO: To be used by BuildAsync.
        protected abstract Task GenerateDriverAsync(Stream driver);

        // TODO: To be used by RunAsync.
        // TODO: How arguments are passed to this API will change.
        protected abstract string GetCommandLineArguments(IList<ArgumentValue> arguments);

        // TODO: To be used by BuildAsync.
        protected abstract IList<string> GetLinkLibraries();
    }
}
