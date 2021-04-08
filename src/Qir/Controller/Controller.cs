// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.IO;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.Quantum.Qir.Driver;
using Microsoft.Quantum.Qir.Executable;
using Microsoft.Quantum.Qir.Model;
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
            // TODO: Logging.
            try
            {
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
                using var outputFileStream = outputFile.OpenWrite();
                await executableRunner.RunExecutableAsync(executableFile, input.EntryPoint, outputFile);
            }
            catch (Exception e)
            {
                await WriteExceptionToFileAsync(e, errorFile);
                outputFile.Delete();
            }
        }

        private static async Task WriteExceptionToFileAsync(Exception e, FileInfo errorFile)
        {
            // Create the error object.
            Error error;
            if (e is ControllerException controllerException)
            {
                error = new Error
                {
                    Code = controllerException.Code,
                    Message = controllerException.Message,
                };
            }
            else
            {
                error = new Error
                {
                    Code = Constant.ErrorCode.InternalError,
                    Message = ErrorMessages.InternalError,
                };
            }

            // Serialize the error to JSON.
            var errorJson = JsonSerializer.Serialize(error, new JsonSerializerOptions
            {
                WriteIndented = true,
            });

            // Write the error to the error file.
            using var errorFileStream = errorFile.OpenWrite();
            using var streamWriter = new StreamWriter(errorFileStream);
            await streamWriter.WriteAsync(errorJson);
        }
    }
}
