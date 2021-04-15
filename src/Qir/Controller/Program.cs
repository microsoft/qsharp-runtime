// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.CommandLine;
using System.CommandLine.Invocation;
using System.IO;
using Microsoft.Quantum.Qir.Driver;
using Microsoft.Quantum.Qir.Executable;
using Microsoft.Quantum.Qir.Utility;

namespace Microsoft.Quantum.Qir
{
    class Program
    {
        static void Main(string[] args)
        {
            var logger = new Logger(new Clock());
            var execGenerator = new QirExecutableGenerator(new ClangClient(logger), logger);
            var driverGenerator = new QirSourceFileGenerator(logger);
            var execRunner = new QuantumExecutableRunner(logger);
            logger.LogInfo("QIR controller beginning.");

            var rootCommand = new RootCommand(
                description: "Builds and runs QIR executable.");

            // Create and add options to the root command.
            var inputOption = new Option<FileInfo>(
                aliases: new string[] { "--input"})
            {
                Description = "Path to the file that contains the input.",
                IsRequired = true
            };
            
            rootCommand.AddOption(inputOption);
            var outputOption = new Option<FileInfo>(
                aliases: new string[] { "--output"})
            {
                Description = "Path to the file to which the output will be written.",
                IsRequired = true
            };

            rootCommand.AddOption(outputOption);

            var libraryDirectoryOption = new Option<DirectoryInfo>(
            aliases: new string[] { "--libraryDirectory" })
            {
                Description = "Path to the directory containing the libraries that must be linked to the driver executable.",
                IsRequired = true
            };

            rootCommand.AddOption(libraryDirectoryOption);
            var includeDirectoryOption = new Option<DirectoryInfo>(
            aliases: new string[] { "--includeDirectory" })
            {
                Description = "Path to the directory containing headers that must be included by the C++ driver.",
                IsRequired = true
            };

            rootCommand.AddOption(includeDirectoryOption);
            var errorOption = new Option<FileInfo>(
                aliases: new string[] { "--error",})
            {
                Description = "Path to the file to which errors will be logged.",
                IsRequired = true
            };

            rootCommand.AddOption(errorOption);

            // Bind to a handler and invoke.
            rootCommand.Handler = CommandHandler.Create<FileInfo, FileInfo, DirectoryInfo, DirectoryInfo, FileInfo>(
                async (input, output, libraryDirectory, includeDirectory, error) =>
                    await Controller.ExecuteAsync(input, output, libraryDirectory, includeDirectory, error, driverGenerator, execGenerator, execRunner, logger));
            rootCommand.Invoke(args);
        }
    }
}
