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
    public abstract class QirExecutable
    {
        private readonly EntryPointOperation EntryPointOperation;
        private readonly byte[] QirBytecode;

        /// <summary>
        /// Constructor for the QirExecutable class.
        /// </summary>
        /// <param name="entryPoint">Object that provides data to specify which entry-point to use for building and running a QIR-based executable.</param>
        /// <param name="qirBytecode">QIR bytecode used to build the executable.</param>
        public QirExecutable(EntryPointOperation entryPoint, byte[] qirBytecode)
        {
            this.EntryPointOperation = entryPoint;
            this.QirBytecode = qirBytecode;
        }

        /// <summary>
        /// Creates a QIR-based executable.
        /// </summary>
        /// <param name="libraryDirectory">Directory where the libraries to link to are located.</param>
        /// <param name="includeDirectory">Directory where the headers needed for compilation are located.</param>
        /// <param name="executable">File to write the executable to.</param>
        public Task BuildAsync(DirectoryInfo libraryDirectory, DirectoryInfo includeDirectory, FileInfo executable)
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
