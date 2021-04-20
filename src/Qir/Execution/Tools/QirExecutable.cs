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
    /// Base for creating and running QIR-based executables.
    /// </summary>
    public abstract class QirExecutable : IQirExecutable
    {
        public IQirDriverGenerator DriverGenerator { get; }

        public abstract IList<string> LinkLibraries { get; }

        public byte[] QirBytecode { get; }

        /// <summary>
        /// Constructor for the QirExecutable class.
        /// </summary>
        /// <param name="qirBytecode">QIR bytecode used to build the executable.</param>
        public QirExecutable(byte[] qirBytecode, IQirDriverGenerator driverGenerator)
        {
            this.DriverGenerator = driverGenerator;
            this.QirBytecode = qirBytecode;
        }

        /// <summary>
        /// Creates a QIR-based executable.
        /// </summary>
        /// /// <param name="executable">File to write the executable to.</param>
        /// <param name="libraryDirectory">Directory where the libraries to link to are located.</param>
        /// <param name="includeDirectory">Directory where the headers needed for compilation are located.</param>
        public Task BuildAsync(FileInfo executable, EntryPointOperation entryPoint, DirectoryInfo libraryDirectory, DirectoryInfo includeDirectory)
        {
            throw new NotImplementedException();
        }

        // TODO: How arguments are passed to this API will change.
        public Task RunAsync(FileInfo executable, string entryPointName, IDictionary<string, object> arguments, Stream output)
        {
            throw new NotImplementedException();
        }
    }
}
