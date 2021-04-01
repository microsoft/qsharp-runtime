// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.CommandLine;
using System.CommandLine.Invocation;
using System.IO;

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
                aliases: new string[] { "--input", "-i" })
            {
                Description = "Path to the file that contains the input.",
                Required = true
            };

            rootCommand.AddOption(inputOption);
            var outputOption = new Option<FileInfo>(
                aliases: new string[] { "--output", "-o" })
            {
                Description = "Path to the file to which the output will be written.",
                Required = true
            };

            rootCommand.AddOption(outputOption);
            var errorOption = new Option<FileInfo>(
                aliases: new string[] { "--error", "-e" })
            {
                Description = "Path to the file to which errors will be logged.",
                Required = true
            };

            rootCommand.AddOption(errorOption);
            // Bind to a handler and invoke.
            rootCommand.Handler = CommandHandler.Create<FileInfo, FileInfo, FileInfo>(Controller.Execute);
            rootCommand.Invoke(args);
        }
    }
}
