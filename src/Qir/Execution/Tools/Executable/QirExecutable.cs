// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using Microsoft.Quantum.Qir.Tools.Driver;
using Microsoft.Quantum.Qir.Utility;
using Microsoft.Quantum.QsCompiler.BondSchemas.EntryPoint;

namespace Microsoft.Quantum.Qir.Tools.Executable
{
    /// <summary>
    /// Base for creating and running QIR-based executables.
    /// </summary>
    public abstract class QirExecutable : IQirExecutable
    {
        private const string DriverFileName = "qir.driver";
        private const string BytecodeFileName = "qir.bc";
        protected FileInfo ExecutableFile { get; }
        private readonly byte[] qirBytecode;
        public virtual string SourceDirectoryPath => "src";
        private readonly ILogger logger;
        private readonly IQuantumExecutableRunner runner;
        private readonly IQirDriverGenerator driverGenerator;
        private readonly IQirExecutableGenerator executableGenerator;

        public QirExecutable(FileInfo executableFile, byte[] qirBytecode, ILogger logger, IQirDriverGenerator driverGenerator, IQirExecutableGenerator executableGenerator, IQuantumExecutableRunner runner)
        {
            ExecutableFile = executableFile;
            this.qirBytecode = qirBytecode;
            this.logger = logger;
            this.runner = runner;
            this.driverGenerator = driverGenerator;
            this.executableGenerator = executableGenerator;
        }

        public async Task BuildAsync(EntryPointOperation entryPoint, DirectoryInfo libraryDirectory, DirectoryInfo includeDirectory)
        {
            var sourceDirectory = new DirectoryInfo(SourceDirectoryPath);
            if (sourceDirectory.Exists)
            {
                sourceDirectory.Delete(true);
            }

            sourceDirectory.Create();
            logger.LogInfo($"Created source directory at {sourceDirectory.FullName}.");

            // Create driver.
            var driverFile = new FileInfo(Path.Combine(sourceDirectory.FullName, DriverFileName));
            using var driverFileStream = driverFile.OpenWrite();
            await driverGenerator.GenerateAsync(entryPoint, driverFileStream);
            logger.LogInfo($"Created driver file at {driverFile.FullName}.");

            // Create bytecode file.
            var bytecodeFile = new FileInfo(Path.Combine(sourceDirectory.FullName, BytecodeFileName));
            using var bytecodeFileStream = bytecodeFile.OpenWrite();
            await bytecodeFileStream.WriteAsync(qirBytecode);
            logger.LogInfo($"Created bytecode file at {bytecodeFile.FullName}.");

            await executableGenerator.GenerateExecutableAsync(ExecutableFile, sourceDirectory, libraryDirectory, includeDirectory, LinkLibraries);
        }

        public async Task RunAsync(EntryPointOperation entryPoint, Stream output)
        {
            var stringArguments = driverGenerator.GetCommandLineArguments(entryPoint);
            await runner.RunExecutableAsync(ExecutableFile, output, stringArguments);
        }

        public abstract IList<string> LinkLibraries { get; }
    }
}
