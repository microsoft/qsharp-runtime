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
        public override IList<string> LinkLibraries =>
            new List<string> {
                "Microsoft.Quantum.Qir.Runtime",
                "Microsoft.Quantum.Qir.QSharp.Foundation",
                "Microsoft.Quantum.Qir.QSharp.Core"
            };

        /// <inheritdoc/>
        public QirFullStateExecutable(byte[] qirBytecode) :
            base(qirBytecode, new QirFullStateDriverGenerator())
        {
        }
    }
}
