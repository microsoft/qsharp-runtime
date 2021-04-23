// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;
using System.IO;
using Microsoft.Quantum.Qir.Tools.Driver;
using Microsoft.Quantum.Qir.Utility;

namespace Microsoft.Quantum.Qir.Tools.Executable
{
    /// <summary>
    /// Class to create and run QIR-based executables that use the full-state simulator.
    /// </summary>
    public class QirFullStateExecutable : QirExecutable
    {
        public QirFullStateExecutable(FileInfo executableFile, byte[] qirBytecode, ILogger logger = null)
            : base(executableFile,
                  qirBytecode,
                  new QirFullStateDriverGenerator(),
                  logger)
        {
        }

        public override IList<string> LinkLibraries => new List<string> {
                "Microsoft.Quantum.Qir.Runtime",
                "Microsoft.Quantum.Qir.QSharp.Foundation",
                "Microsoft.Quantum.Qir.QSharp.Core"
            };

        public override string DriverFileExtension => "cpp";
    }
}
