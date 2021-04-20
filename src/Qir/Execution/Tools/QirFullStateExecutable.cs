// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Microsoft.Quantum.QsCompiler;
using Microsoft.Quantum.QsCompiler.BondSchemas.EntryPoint;
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

        protected override async Task GenerateDriverAsync(Stream driver)
        {
            await Task.Run(() => QirDriverGeneration.GenerateQirDriverCpp(EntryPointOperation, driver));
        }

        protected override string GetCommandLineArguments(IList<Argument> arguments)
        {
            return QirDriverGeneration.GenerateCommandLineArguments(arguments);
        }

        protected override IList<string> GetLinkLibraries()
        {
            return new List<string> {
                "Microsoft.Quantum.Qir.Runtime",
                "Microsoft.Quantum.Qir.QSharp.Foundation",
                "Microsoft.Quantum.Qir.QSharp.Core"
            };
        }
    }
}
