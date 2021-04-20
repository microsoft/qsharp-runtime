// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Microsoft.Quantum.Qir.Tools.Executable;
using Microsoft.Quantum.Qir.Tools.SourceGeneration;
using Microsoft.Quantum.Qir.Utility;
using Microsoft.Quantum.QsCompiler.BondSchemas.EntryPoint;
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
        protected EntryPointOperation EntryPointOperation { get; }
        private readonly byte[] qirBytecode;
        private const string SourceDirectoryPath = "src";
        private readonly ILogger logger;
        private readonly IQuantumExecutableRunner runner;
        private readonly IQirSourceFileGenerator sourceGenerator;
        private readonly IQirExecutableGenerator executableGenerator;

        /// <summary>
        /// Constructor for the QirExecutable class.
        /// </summary>
        /// <param name="entryPoint">Object that provides data to specify which entry-point to use for building and running a QIR-based executable.</param>
        /// <param name="qirBytecode">QIR bytecode used to build the executable.</param>
        public QirExecutable(EntryPointOperation entryPoint, byte[] qirBytecode)
        {
            EntryPointOperation = entryPoint;
            this.qirBytecode = qirBytecode;
            logger = new Logger(new Clock());
            runner = new QuantumExecutableRunner(logger);
            sourceGenerator = new QirSourceFileGenerator(logger, GenerateDriverAsync);
            var clangClient = new ClangClient(logger);
            executableGenerator = new QirExecutableGenerator(clangClient, logger);
        }

        internal QirExecutable(EntryPointOperation entryPoint, byte[] qirBytecode, ILogger logger, IQirSourceFileGenerator sourceGenerator, IQuantumExecutableRunner runner)
        {
            EntryPointOperation = entryPoint;
            this.qirBytecode = qirBytecode;
            this.logger = logger;
            this.runner = runner;
            this.sourceGenerator = sourceGenerator;
        }

        /// <summary>
        /// Creates a QIR-based executable.
        /// </summary>
        /// <param name="libraryDirectory">Directory where the libraries to link to are located.</param>
        /// <param name="includeDirectory">Directory where the headers needed for compilation are located.</param>
        /// <param name="executable">File to write the executable to.</param>
        public async Task BuildAsync(DirectoryInfo libraryDirectory, DirectoryInfo includeDirectory, FileInfo executable)
        {
            var linkLibraries = GetLinkLibraries();
            var sourceDirectory = new DirectoryInfo(SourceDirectoryPath);
            await sourceGenerator.GenerateQirSourceFilesAsync(sourceDirectory, EntryPointOperation, qirBytecode);
            await executableGenerator.GenerateExecutableAsync(executable, sourceDirectory, libraryDirectory, includeDirectory, linkLibraries);
        }

        public async Task RunAsync(FileInfo executable, FileInfo outputFile)
        {
            var stringArguments = GetCommandLineArguments(EntryPointOperation.Arguments);
            await runner.RunExecutableAsync(executable, outputFile, stringArguments);
        }

        protected abstract Task GenerateDriverAsync(Stream driver);

        protected abstract string GetCommandLineArguments(IList<Argument> arguments);

        protected abstract IList<string> GetLinkLibraries();
    }
}
