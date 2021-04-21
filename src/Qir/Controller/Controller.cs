// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.IO;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.Quantum.Qir.Model;
using Microsoft.Quantum.Qir.Tools.Executable;
using Microsoft.Quantum.Qir.Utility;
using QirExecutionWrapperSerialization = Microsoft.Quantum.QsCompiler.BondSchemas.QirExecutionWrapper.Protocols;

namespace Microsoft.Quantum.Qir
{
    public static class Controller
    {
        private const string BinaryDirectoryPath = "bin";
        private const string ExecutableName = "simulation.exe";

        public static async Task ExecuteAsync(
            FileInfo inputFile,
            FileInfo outputFile,
            DirectoryInfo libraryDirectory,
            DirectoryInfo includeDirectory,
            FileInfo errorFile,
            ILogger logger)
        {
            try
            {
                // Step 1: Parse input.
                logger.LogInfo("Parsing input.");
                using var inputFileStream = inputFile.OpenRead();
                var input = QirExecutionWrapperSerialization.DeserializeFromFastBinary(inputFileStream);

                // Step 2: Create executable.
                logger.LogInfo("Creating executable.");
                var bytecodeArray = input.QirBytecode.Array.Skip(input.QirBytecode.Offset).Take(input.QirBytecode.Count).ToList().ToArray();
                var executableFile = new FileInfo(Path.Combine(BinaryDirectoryPath, ExecutableName));
                var executable = QirFullStateExecutable.CreateInstance(executableFile, bytecodeArray, logger);
                await executable.BuildAsync(input.EntryPoint, libraryDirectory, includeDirectory);

                // Step 3: Run executable.
                if (outputFile.Exists)
                {
                    outputFile.Delete();
                }
                using var outputStream = outputFile.OpenWrite();
                await executable.RunAsync(input.EntryPoint, outputStream);
            }
            catch (Exception e)
            {
                logger.LogError("An error has been encountered. Will write an error to the error file.");
                logger.LogException(e);
                await WriteExceptionToFileAsync(e, errorFile);
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
