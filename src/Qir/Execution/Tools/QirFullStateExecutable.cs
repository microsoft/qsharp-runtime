// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Microsoft.Quantum.QsCompiler.BondSchemas.EntryPoint;
using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Qir.Tools
{
    /// <summary>
    /// Class to create and run QIR-based executables that use the full-state simulator.
    /// </summary>
    public class QirFullStateExecutable : QirExecutable
    {
        /// <inheritdoc/>
        public QirFullStateExecutable(EntryPointOperation entryPoint, byte[] qirBytecode) :
            base(entryPoint, qirBytecode)
        {
        }

        protected override Task GenerateDriverAsync(Stream driver)
        {
            throw new NotImplementedException();
        }

        // TODO: How arguments are passed to this API will change.
        protected override string GetCommandLineArguments(IList<ArgumentValue> arguments)
        {
            throw new NotImplementedException();
        }

        protected override IList<string> GetLinkLibraries()
        {
            throw new NotImplementedException();
        }
    }
}
