// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using Microsoft.Quantum.Qir.Serialization;
using Microsoft.Quantum.Qir.Tools.Driver;

#nullable enable

namespace Microsoft.Quantum.Qir.Tools.Executable
{
    /// <summary>
    /// Base for creating and running QIR-based executables.
    /// </summary>
    public abstract class QirExecutable : IQirExecutable
    {
        private const string DriverFileName = "driver";
        private const string BitcodeFileName = "qir.bc";

        public virtual string SourceDirectoryPath => "src";
        public abstract string DriverFileExtension { get; }
        public abstract IList<string> LinkLibraries { get; }
        public abstract IList<DirectoryInfo> HeaderDirectories { get; }
        public abstract IList<DirectoryInfo> LibraryDirectories { get; }

        protected FileInfo ExecutableFile { get; }

        private readonly byte[] qirBitcode;
        private readonly ILogger? logger;
        private readonly IQuantumExecutableRunner runner;
        private readonly IQirDriverGenerator driverGenerator;
        private readonly IQirExecutableGenerator executableGenerator;

        public QirExecutable(FileInfo executableFile, byte[] qirBitcode, IQirDriverGenerator driverGenerator, ILogger? logger = null)
            : this(executableFile,
              qirBitcode,
              driverGenerator,
              new QirExecutableGenerator(new ClangClient(logger), logger),
              new QuantumExecutableRunner(logger),
              logger)
        {
        }

        internal QirExecutable(FileInfo executableFile, byte[] qirBitcode, IQirDriverGenerator driverGenerator, IQirExecutableGenerator executableGenerator, IQuantumExecutableRunner runner, ILogger? logger)
        {
            ExecutableFile = executableFile;
            this.qirBitcode = qirBitcode;
            this.logger = logger;
            this.runner = runner;
            this.driverGenerator = driverGenerator;
            this.executableGenerator = executableGenerator;
        }

        public async Task BuildAsync(EntryPointOperation entryPoint, IList<DirectoryInfo> libraryDirectories, IList<DirectoryInfo> includeDirectories)
        {
            var sourceDirectory = new DirectoryInfo(SourceDirectoryPath);
            if (sourceDirectory.Exists)
            {
                sourceDirectory.Delete(true);
            }

            sourceDirectory.Create();
            logger?.LogInformation($"Created source directory at {sourceDirectory.FullName}.");

            // Create driver.
            var driverFileNameWithExtension = Path.ChangeExtension(DriverFileName, DriverFileExtension);
            var driverFile = new FileInfo(Path.Combine(sourceDirectory.FullName, driverFileNameWithExtension));
            using (var driverFileStream = driverFile.OpenWrite())
            {
                await driverGenerator.GenerateAsync(entryPoint, driverFileStream);
            }
            logger?.LogInformation($"Created driver file at {driverFile.FullName}.");

            // Create bitcode file.
            var bitcodeFile = new FileInfo(Path.Combine(sourceDirectory.FullName, BitcodeFileName));
            using (var bitcodeFileStream = bitcodeFile.OpenWrite())
            {
                await bitcodeFileStream.WriteAsync(qirBitcode);
            }
            logger?.LogInformation($"Created bitcode file at {bitcodeFile.FullName}.");
            await executableGenerator.GenerateExecutableAsync(ExecutableFile, sourceDirectory, libraryDirectories.Concat(this.LibraryDirectories).ToList(), includeDirectories.Concat(this.HeaderDirectories).ToList(), LinkLibraries);
        }

        public async Task RunAsync(ExecutionInformation executionInformation, Stream output)
        {
            var stringArguments = driverGenerator.GetCommandLineArguments(executionInformation);
            await runner.RunExecutableAsync(ExecutableFile, output, stringArguments);
        }
    }
}
