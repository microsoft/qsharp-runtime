// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.CommandLine;
using System.CommandLine.Builder;
using System.CommandLine.Help;
using System.CommandLine.Invocation;
using System.CommandLine.Parsing;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Quantum.Qir.Tools;

namespace CommandLineCompiler
{
    class Program
    {
        private static async Task<int> Main(string[] args)
        {
            var buildCommand = CreateBuildCommand();

            var root = new RootCommand() { buildCommand };
            SetSubCommandAsDefault(root, buildCommand);
            root.Description = "Command-line tool for processing QIR DLL files.";
            root.TreatUnmatchedTokensAsErrors = true;

            Console.OutputEncoding = Encoding.UTF8;
            return await new CommandLineBuilder(root)
                .UseDefaults()
                .UseHelpBuilder(context => new QsHelpBuilder(context.Console))
                .Build()
                .InvokeAsync(args);
        }

        /// <summary>
        /// Creates the Build command for the command line compiler, which is used to
        /// compile the executables from a given QIR DLL.
        /// </summary>
        /// <returns>The Build command.</returns>
        private static Command CreateBuildCommand()
        {
            var buildCommand = new Command("build", "(default) Build the executables from a QIR DLL.")
            {
                Handler = CommandHandler.Create((BuildOptions settings) =>
                    QirTools.BuildFromQSharpDll(settings.QsharpDll, settings.LibraryDirectory, settings.IncludeDirectory, settings.ExecutablesDirectory))
            };
            buildCommand.TreatUnmatchedTokensAsErrors = true;

            Option<FileInfo> qsharpDllOption = new Option<FileInfo>(
                aliases: new string[] { "--qsharpDll", "--dll" },
                description: "The path to the QIR DLL file that is to be compiled.")
            {
                Required = true
            };
            buildCommand.AddOption(qsharpDllOption);

            Option<DirectoryInfo> libraryDirectory = new Option<DirectoryInfo>(
                aliases: new string[] { "--libraryDirectory", "--lib" },
                description: "The path to the directory containing the required libraries.")
            {
                Required = true
            };
            buildCommand.AddOption(libraryDirectory);

            Option<DirectoryInfo> includeDirectory = new Option<DirectoryInfo>(
                aliases: new string[] { "--includeDirectory", "--include" },
                description: "The path to the directory containing the required resources to be included.")
            {
                Required = true
            };
            buildCommand.AddOption(includeDirectory);

            Option<DirectoryInfo> executablesDirectory = new Option<DirectoryInfo>(
                aliases: new string[] { "--executablesDirectory", "--exe" },
                description: "The path to the output directory where the created executables will be placed.")
            {
                Required = true
            };
            buildCommand.AddOption(executablesDirectory);

            return buildCommand;
        }

        /// <summary>
        /// Copies the handle and options from the given sub command to the given command.
        /// </summary>
        /// <param name="root">The command whose handle and options will be set.</param>
        /// <param name="subCommand">The sub command that will be copied from.</param>
        private static void SetSubCommandAsDefault(Command root, Command subCommand)
        {
            root.Handler = subCommand.Handler;
            foreach (var option in subCommand.Options)
            {
                root.AddOption(option);
            }
        }

        /// <summary>
        /// A modification of the command-line <see cref="HelpBuilder"/> class.
        /// </summary>
        private sealed class QsHelpBuilder : HelpBuilder
        {
            /// <summary>
            /// Creates a new help builder using the given console.
            /// </summary>
            /// <param name="console">The console to use.</param>
            internal QsHelpBuilder(IConsole console) : base(console)
            {
            }

            protected override string ArgumentDescriptor(IArgument argument)
            {
                // Hide long argument descriptors.
                var descriptor = base.ArgumentDescriptor(argument);
                return descriptor.Length > 30 ? argument.Name : descriptor;
            }
        }

        /// <summary>
        /// A class for encapsulating the different options for the build command.
        /// </summary>
        public sealed class BuildOptions
        {
            /// <summary>
            /// The path to the QIR DLL file that is to be compiled.
            /// </summary>
            public FileInfo QsharpDll { get; set; }

            /// <summary>
            /// The path to the directory containing the required libraries.
            /// </summary>
            public DirectoryInfo LibraryDirectory { get; set; }

            /// <summary>
            /// The path to the directory containing the required resources to be included.
            /// </summary>
            public DirectoryInfo IncludeDirectory { get; set; }

            /// <summary>
            /// The path to the output directory where the created executables will be placed.
            /// </summary>
            public DirectoryInfo ExecutablesDirectory { get; set; }
        }
    }
}
