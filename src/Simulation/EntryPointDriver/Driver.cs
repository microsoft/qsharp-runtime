// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.CommandLine;
using System.CommandLine.Builder;
using System.CommandLine.Help;
using System.CommandLine.Invocation;
using System.CommandLine.Parsing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Quantum.QsCompiler.ReservedKeywords;
using Microsoft.Quantum.Simulation.Core;
using static Microsoft.Quantum.EntryPointDriver.Driver;

namespace Microsoft.Quantum.EntryPointDriver
{
    /// <summary>
    /// The entry point driver is the entry point for the C# application that executes the Q# entry point.
    /// </summary>
    /// <typeparam name="TCallable">The entry point's callable type.</typeparam>
    /// <typeparam name="TIn">The entry point's argument type.</typeparam>
    /// <typeparam name="TOut">The entry point's return type.</typeparam>
    public sealed class Driver<TCallable, TIn, TOut> where TCallable : AbstractCallable, ICallable
    {
        /// <summary>
        /// The entry point.
        /// </summary>
        private readonly IEntryPoint<TIn, TOut> entryPoint;

        /// <summary>
        /// The simulator option.
        /// </summary>
        private OptionInfo<string> SimulatorOption { get; }

        /// <summary>
        /// Creates a new driver for the entry point.
        /// </summary>
        /// <param name="entryPoint">The entry point.</param>
        public Driver(IEntryPoint<TIn, TOut> entryPoint)
        {
            this.entryPoint = entryPoint;
            SimulatorOption = new OptionInfo<string>(
                new[]
                {
                    "--" + CommandLineArguments.SimulatorOption.Item1,
                    "-" + CommandLineArguments.SimulatorOption.Item2
                },
                entryPoint.DefaultSimulator,
                "The name of the simulator to use.",
                suggestions: new[]
                {
                    AssemblyConstants.QuantumSimulator,
                    AssemblyConstants.ToffoliSimulator,
                    AssemblyConstants.ResourcesEstimator,
                    entryPoint.DefaultSimulator
                });
        }

        /// <summary>
        /// Runs the entry point using the command-line arguments.
        /// </summary>
        /// <param name="args">The command-line arguments.</param>
        /// <returns>The exit code.</returns>
        public async Task<int> Run(string[] args)
        {
            var simulate = new Command("simulate", "(default) Run the program using a local simulator.")
            {
                Handler = CommandHandler.Create<ParseResult, string>(Simulate)
            };
            AddOptionIfAvailable(simulate, SimulatorOption);

            var submit = new Command("submit", "Submit the program to Azure Quantum.")
            {
                IsHidden = true,
                Handler = CommandHandler.Create<ParseResult, AzureSettings>(Submit)
            };
            AddOptionIfAvailable(submit, TargetOption);
            AddOptionIfAvailable(submit, StorageOption);
            AddOptionIfAvailable(submit, SubscriptionOption);
            AddOptionIfAvailable(submit, ResourceGroupOption);
            AddOptionIfAvailable(submit, WorkspaceOption);
            AddOptionIfAvailable(submit, AadTokenOption);
            AddOptionIfAvailable(submit, BaseUriOption);
            AddOptionIfAvailable(submit, JobNameOption);
            AddOptionIfAvailable(submit, ShotsOption);
            AddOptionIfAvailable(submit, OutputOption);
            AddOptionIfAvailable(submit, DryRunOption);
            AddOptionIfAvailable(submit, VerboseOption);

            var root = new RootCommand(entryPoint.Summary) { simulate, submit };
            foreach (var option in entryPoint.Options)
            {
                root.AddGlobalOption(option);
            }

            // Set the simulate command as the default.
            foreach (var option in simulate.Options)
            {
                root.AddOption(option);
            }
            root.Handler = simulate.Handler;

            Console.OutputEncoding = Encoding.UTF8;
            return await new CommandLineBuilder(root)
                .UseDefaults()
                .UseHelpBuilder(context => new QsHelpBuilder(context.Console))
                .Build()
                .InvokeAsync(args);
        }

        /// <summary>
        /// Simulates the entry point.
        /// </summary>
        /// <param name="parseResult">The command-line parsing result.</param>
        /// <param name="simulator">The simulator to use.</param>
        /// <returns>The exit code.</returns>
        private async Task<int> Simulate(ParseResult parseResult, string simulator) =>
            await Simulation<TCallable, TIn, TOut>.Simulate(
                entryPoint, parseResult, DefaultIfShadowed(SimulatorOption, simulator));

        /// <summary>
        /// Submits the entry point to Azure Quantum.
        /// </summary>
        /// <param name="parseResult">The command-line parsing result.</param>
        /// <param name="settings">The submission settings.</param>
        private async Task<int> Submit(ParseResult parseResult, AzureSettings settings) =>
            await Azure.Submit(entryPoint, parseResult, new AzureSettings
            {
                Target = settings.Target,
                Storage = settings.Storage,
                Subscription = settings.Subscription,
                ResourceGroup = settings.ResourceGroup,
                Workspace = settings.Workspace,
                AadToken = DefaultIfShadowed(AadTokenOption, settings.AadToken),
                BaseUri = DefaultIfShadowed(BaseUriOption, settings.BaseUri),
                JobName = DefaultIfShadowed(JobNameOption, settings.JobName),
                Shots = DefaultIfShadowed(ShotsOption, settings.Shots),
                Output = DefaultIfShadowed(OutputOption, settings.Output),
                DryRun = DefaultIfShadowed(DryRunOption, settings.DryRun),
                Verbose = DefaultIfShadowed(VerboseOption, settings.Verbose)
            });

        /// <summary>
        /// Returns true if the alias is not already used by an entry point option.
        /// </summary>
        /// <param name="alias">The alias to check.</param>
        /// <returns>True if the alias is available for use by the driver.</returns>
        private bool IsAliasAvailable(string alias) =>
            !entryPoint.Options.SelectMany(option => option.RawAliases).Contains(alias);

        /// <summary>
        /// Returns the default value and displays a warning if the primary (first) alias is shadowed by an entry point
        /// option, and returns the original value otherwise.
        /// </summary>
        /// <typeparam name="T">The type of the option values.</typeparam>
        /// <param name="option">The option.</param>
        /// <param name="value">The value of the option given on the command line.</param>
        /// <returns>The default value or the original value.</returns>
        private T DefaultIfShadowed<T>(OptionInfo<T> option, T value)
        {
            if (IsAliasAvailable(option.Aliases.First()))
            {
                return value;
            }
            else
            {
                DisplayWithColor(ConsoleColor.Yellow, Console.Error,
                    $"Warning: Option {option.Aliases.First()} is overridden by an entry point parameter name. " +
                    $"Using default value {option.DefaultValue}.");
                return option.DefaultValue;
            }
        }

        /// <summary>
        /// Adds the option to the command using only the aliases that are available, and only if the primary (first)
        /// alias is available. If a required option is not available, the command is disabled.
        /// </summary>
        /// <param name="command">The command to add the option to.</param>
        /// <param name="option">The option to add.</param>
        /// <typeparam name="T">The type of the option's argument.</typeparam>
        private void AddOptionIfAvailable<T>(Command command, OptionInfo<T> option)
        {
            if (IsAliasAvailable(option.Aliases.First()))
            {
                command.AddOption(option.Create(option.Aliases.Where(IsAliasAvailable)));
            }
            else if (option.Required)
            {
                command.AddValidator(commandResult =>
                    $"The required option {option.Aliases.First()} conflicts with an entry point parameter name.");
            }
        }
    }

    /// <summary>
    /// Static members for <see cref="Driver{TCallable,TIn,TOut}"/>.
    /// </summary>
    internal static class Driver
    {
        // TODO: Define the aliases as constants.

        /// <summary>
        /// The target option.
        /// </summary>
        internal static readonly OptionInfo<string> TargetOption = new OptionInfo<string>(
            new[] { "--target" }, "The target device ID.");

        /// <summary>
        /// The storage option.
        /// </summary>
        internal static readonly OptionInfo<string> StorageOption = new OptionInfo<string>(
            new[] { "--storage" }, "The storage account connection string.");
        
        /// <summary>
        /// The subscription option.
        /// </summary>
        internal static readonly OptionInfo<string> SubscriptionOption = new OptionInfo<string>(
            new[] { "--subscription" }, "The subscription ID.");

        /// <summary>
        /// The resource group option.
        /// </summary>
        internal static readonly OptionInfo<string> ResourceGroupOption = new OptionInfo<string>(
            new[] { "--resource-group" }, "The resource group name.");

        /// <summary>
        /// The workspace option.
        /// </summary>
        internal static readonly OptionInfo<string> WorkspaceOption = new OptionInfo<string>(
            new[] { "--workspace" }, "The workspace name.");

        /// <summary>
        /// The AAD token option.
        /// </summary>
        internal static readonly OptionInfo<string?> AadTokenOption = new OptionInfo<string?>(
            new[] { "--aad-token" }, default, "The Azure Active Directory authentication token.");
        
        /// <summary>
        /// The base URI option.
        /// </summary>
        internal static readonly OptionInfo<Uri?> BaseUriOption = new OptionInfo<Uri?>(
            new[] { "--base-uri" }, default, "The base URI of the Azure Quantum endpoint.");

        /// <summary>
        /// The job name option.
        /// </summary>
        internal static readonly OptionInfo<string?> JobNameOption = new OptionInfo<string?>(
            new[] { "--job-name" }, default, "The name of the submitted job.");
        
        /// <summary>
        /// The shots option.
        /// </summary>
        internal static readonly OptionInfo<int> ShotsOption = new OptionInfo<int>(
            new[] { "--shots" },
            500,
            "The number of times the program is executed on the target machine.",
            validator: result =>
                int.TryParse(result.Tokens.SingleOrDefault()?.Value, out var value) && value <= 0
                    ? "The number of shots must be a positive number."
                    : default);

        /// <summary>
        /// The output option.
        /// </summary>
        internal static readonly OptionInfo<OutputFormat> OutputOption = new OptionInfo<OutputFormat>(
            new[] { "--output" },
            OutputFormat.FriendlyUri,
            "The information to show in the output after the job is submitted.");

        /// <summary>
        /// The dry run option.
        /// </summary>
        internal static readonly OptionInfo<bool> DryRunOption = new OptionInfo<bool>(
            new[] { "--dry-run" },
            false,
            "Validate the program and options, but do not submit to Azure Quantum.");

        /// <summary>
        /// The verbose option.
        /// </summary>
        internal static readonly OptionInfo<bool> VerboseOption = new OptionInfo<bool>(
            new[] { "--verbose" }, false, "Show additional information about the submission.");

        /// <summary>
        /// Displays a message to the console using the given color and text writer.
        /// </summary>
        /// <param name="color">The text color.</param>
        /// <param name="writer">The text writer for the console output stream.</param>
        /// <param name="message">The message to display.</param>
        internal static void DisplayWithColor(ConsoleColor color, TextWriter writer, string message)
        {
            var originalForeground = Console.ForegroundColor;
            Console.ForegroundColor = color;
            writer.WriteLine(message);
            Console.ForegroundColor = originalForeground;
        }
    }

    /// <summary>
    /// A modification of the command-line <see cref="HelpBuilder"/> class.
    /// </summary>
    internal sealed class QsHelpBuilder : HelpBuilder
    {
        /// <summary>
        /// Creates a new help builder using the given console.
        /// </summary>
        /// <param name="console">The console to use.</param>
        internal QsHelpBuilder(IConsole console) : base(console) { }

        protected override string ArgumentDescriptor(IArgument argument)
        {
            // Hide long argument descriptors.
            var descriptor = base.ArgumentDescriptor(argument);
            return descriptor.Length > 30 ? argument.Name : descriptor;
        }
    }
}
