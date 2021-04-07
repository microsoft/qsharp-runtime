// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.CommandLine;
using System.CommandLine.Invocation;
using System.IO;
using Microsoft.Quantum.Qir.Driver;
using Microsoft.Quantum.Qir.Executable;

namespace Microsoft.Quantum.Qir
{
    class Program
    {
        static void Main(string[] args)
        {
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
            var errorOption = new Option<FileInfo>(
                aliases: new string[] { "--error",})
            {
                Description = "Path to the file to which errors will be logged.",
                IsRequired = true
            };

            rootCommand.AddOption(errorOption);

            var execGenerator = new QirExecutableGenerator(new ClangClient());
            var driverGenerator = new QirDriverGenerator();
            var execRunner = new QuantumExecutableRunner();

            // The bytecode file is not needed as an input to the program, but we provide the path as an argument to the controller so it can be configured by tests.
            var bytecodeFile = new FileInfo(Constant.FilePath.BytecodeFilePath);

            // Bind to a handler and invoke.
            rootCommand.Handler = CommandHandler.Create<FileInfo, FileInfo, DirectoryInfo, FileInfo>(
                async (input, output, libraryDirectory, error) =>
                    await Controller.ExecuteAsync(input, output, libraryDirectory, error, bytecodeFile, driverGenerator, execGenerator, execRunner));
            rootCommand.Invoke(args);
        }
    }
}
