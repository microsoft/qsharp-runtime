// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.IO;
using System.Threading.Tasks;
using Microsoft.Quantum.Qir.Driver;
using Microsoft.Quantum.Qir.Executable;
using QirExecutionWrapperSerialization = Microsoft.Quantum.QsCompiler.BondSchemas.QirExecutionWrapper.Protocols;

namespace Microsoft.Quantum.Qir
{
    public static class Controller
    {
        public static async Task ExecuteAsync(
            FileInfo inputFile,
            FileInfo outputFile,
            DirectoryInfo libraryDirectory,
            FileInfo errorFile,
            FileInfo bytecodeFile,
            IQirDriverGenerator driverGenerator,
            IQirExecutableGenerator executableGenerator,
            IQuantumExecutableRunner executableRunner)
        {
            // TODO: Error handling.
            // TODO: Logging.
            // Step 1: Parse input.
            using var inputFileStream = inputFile.OpenRead();
            var input = QirExecutionWrapperSerialization.DeserializeFromFastBinary(inputFileStream);

            // Step 2: Create bytecode file.
            using (var bytecodeFileStream = bytecodeFile.OpenWrite())
            {
                await bytecodeFileStream.WriteAsync(input.QirBytecode.Array, input.QirBytecode.Offset, input.QirBytecode.Count);
            }

            // Step 3: Create the driver file.
            var driverFile = new FileInfo(Constant.FilePath.DriverFilePath);
            await driverGenerator.GenerateQirDriverCppAsync(input.EntryPoint, driverFile);

            // Step 4: Create the executable.
            var executableFile = new FileInfo(Constant.FilePath.ExecutableFilePath);
            await executableGenerator.GenerateExecutableAsync(driverFile, bytecodeFile, libraryDirectory, executableFile);

            // Step 5: Run the executable.
            using var outputFileStream = outputFile.Exists ? outputFile.OpenWrite() : outputFile.Create();
            await executableRunner.RunExecutableAsync(executableFile, input.EntryPoint, outputFile);
        }
    }
}
