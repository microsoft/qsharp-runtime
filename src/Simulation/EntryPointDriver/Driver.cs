// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Immutable;
using System.CommandLine;
using System.CommandLine.Builder;
using System.CommandLine.Help;
using System.CommandLine.Invocation;
using System.CommandLine.Parsing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
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
        /// The driver settings.
        /// </summary>
        private readonly DriverSettings settings;

        /// <summary>
        /// The entry point.
        /// </summary>
        private readonly IEntryPoint<TIn, TOut> entryPoint;

        /// <summary>
        /// The simulator option.
        /// </summary>
        private OptionInfo<string> SimulatorOption { get; }

        /// <summary>
        /// The target option.
        /// </summary>
        private OptionInfo<string?> TargetOption { get; }

        /// <summary>
        /// Creates a new driver for the entry point.
        /// </summary>
        /// <param name="settings">The driver settings.</param>
        /// <param name="entryPoint">The entry point.</param>
        public Driver(DriverSettings settings, IEntryPoint<TIn, TOut> entryPoint)
        {
            this.settings = settings;
            this.entryPoint = entryPoint;

            SimulatorOption = new OptionInfo<string>(
                settings.SimulatorOptionAliases,
                entryPoint.DefaultSimulatorName,
                "The name of the simulator to use.",
                suggestions: new[]
                {
                    settings.QuantumSimulatorName,
                    settings.ToffoliSimulatorName,
                    settings.ResourcesEstimatorName,
                    entryPoint.DefaultSimulatorName
                });

            var targetAliases = ImmutableList.Create("--target");
            const string targetDescription = "The target device ID.";
            TargetOption = string.IsNullOrWhiteSpace(entryPoint.DefaultExecutionTarget)
                ? new OptionInfo<string?>(targetAliases, targetDescription)
                : new OptionInfo<string?>(targetAliases, entryPoint.DefaultExecutionTarget, targetDescription);
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
            AddOptionIfAvailable(submit, SubscriptionOption);
            AddOptionIfAvailable(submit, ResourceGroupOption);
            AddOptionIfAvailable(submit, WorkspaceOption);
            AddOptionIfAvailable(submit, TargetOption);
            AddOptionIfAvailable(submit, StorageOption);
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
                settings, entryPoint, parseResult, DefaultIfShadowed(SimulatorOption, simulator));

        /// <summary>
        /// Submits the entry point to Azure Quantum.
        /// </summary>
        /// <param name="parseResult">The command-line parsing result.</param>
        /// <param name="azureSettings">The Azure submission settings.</param>
        private async Task<int> Submit(ParseResult parseResult, AzureSettings azureSettings) =>
            await Azure.Submit(entryPoint, parseResult, new AzureSettings
            {
                Subscription = azureSettings.Subscription,
                ResourceGroup = azureSettings.ResourceGroup,
                Workspace = azureSettings.Workspace,
                Target = DefaultIfShadowed(TargetOption, azureSettings.Target),
                Storage = DefaultIfShadowed(StorageOption, azureSettings.Storage),
                AadToken = DefaultIfShadowed(AadTokenOption, azureSettings.AadToken),
                BaseUri = DefaultIfShadowed(BaseUriOption, azureSettings.BaseUri),
                JobName = DefaultIfShadowed(JobNameOption, azureSettings.JobName),
                Shots = DefaultIfShadowed(ShotsOption, azureSettings.Shots),
                Output = DefaultIfShadowed(OutputOption, azureSettings.Output),
                DryRun = DefaultIfShadowed(DryRunOption, azureSettings.DryRun),
                Verbose = DefaultIfShadowed(VerboseOption, azureSettings.Verbose)
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
        /// The subscription option.
        /// </summary>
        internal static readonly OptionInfo<string> SubscriptionOption = new OptionInfo<string>(
            ImmutableList.Create("--subscription"), "The subscription ID.");

        /// <summary>
        /// The resource group option.
        /// </summary>
        internal static readonly OptionInfo<string> ResourceGroupOption = new OptionInfo<string>(
            ImmutableList.Create("--resource-group"), "The resource group name.");

        /// <summary>
        /// The workspace option.
        /// </summary>
        internal static readonly OptionInfo<string> WorkspaceOption = new OptionInfo<string>(
            ImmutableList.Create("--workspace"), "The workspace name.");

        /// <summary>
        /// The storage option.
        /// </summary>
        internal static readonly OptionInfo<string?> StorageOption = new OptionInfo<string?>(
            ImmutableList.Create("--storage"), default, "The storage account connection string.");

        /// <summary>
        /// The AAD token option.
        /// </summary>
        internal static readonly OptionInfo<string?> AadTokenOption = new OptionInfo<string?>(
            ImmutableList.Create("--aad-token"), default, "The Azure Active Directory authentication token.");

        /// <summary>
        /// The base URI option.
        /// </summary>
        internal static readonly OptionInfo<Uri?> BaseUriOption = new OptionInfo<Uri?>(
            ImmutableList.Create("--base-uri"), default, "The base URI of the Azure Quantum endpoint.");

        /// <summary>
        /// The base URI option.
        /// </summary>
        internal static readonly OptionInfo<string?> LocationOption = new OptionInfo<string?>(
            ImmutableList.Create("--location"), default, "The base URI of the Azure Quantum endpoint.");

        /// <summary>
        /// The job name option.
        /// </summary>
        internal static readonly OptionInfo<string?> JobNameOption = new OptionInfo<string?>(
            ImmutableList.Create("--job-name"), default, "The name of the submitted job.");

        /// <summary>
        /// The shots option.
        /// </summary>
        internal static readonly OptionInfo<int> ShotsOption = new OptionInfo<int>(
            ImmutableList.Create("--shots"),
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
            ImmutableList.Create("--output"),
            OutputFormat.FriendlyUri,
            "The information to show in the output after the job is submitted.");

        /// <summary>
        /// The dry run option.
        /// </summary>
        internal static readonly OptionInfo<bool> DryRunOption = new OptionInfo<bool>(
            ImmutableList.Create("--dry-run"),
            false,
            "Validate the program and options, but do not submit to Azure Quantum.");

        /// <summary>
        /// The verbose option.
        /// </summary>
        internal static readonly OptionInfo<bool> VerboseOption = new OptionInfo<bool>(
            ImmutableList.Create("--verbose"), false, "Show additional information about the submission.");

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
}
