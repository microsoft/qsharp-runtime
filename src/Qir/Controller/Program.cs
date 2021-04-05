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
            var errorOption = new Option<FileInfo>(
                aliases: new string[] { "--error",})
            {
                Description = "Path to the file to which errors will be logged.",
                IsRequired = true
            };

            rootCommand.AddOption(errorOption);

            // Bind to a handler and invoke.
            rootCommand.Handler = CommandHandler.Create<FileInfo, FileInfo, FileInfo>((input, output, error) => Controller.Execute(input, output, error));
            rootCommand.Invoke(args);
        }
    }
}
