// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Microsoft.Quantum.QsCompiler.BondSchemas.EntryPoint;
using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Qir.Tools
{
    public class QirFullStateExecutable : QirExecutable
    {
        public QirFullStateExecutable(EntryPointOperation entryPoint, byte[] qirBytecode) :
            base(entryPoint, qirBytecode)
        {
        }

        protected override Task GenerateDriverAsync(Stream driver)
        {
            throw new NotImplementedException();
        }

        protected override IList<string> GetLinkLibraries()
        {
            throw new NotImplementedException();
        }
    }
}
