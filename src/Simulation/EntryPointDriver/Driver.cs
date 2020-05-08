// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.CommandLine;
using System.CommandLine.Builder;
using System.CommandLine.Help;
using System.CommandLine.Invocation;
using System.CommandLine.Parsing;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Quantum.QsCompiler.ReservedKeywords;
using Microsoft.Quantum.Simulation.Core;
using static Microsoft.Quantum.CsharpGeneration.EntryPointDriver.Driver;

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver
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
        private Option<string> SimulatorOption => new Option<string>(
                new[]
                {
                    "--" + CommandLineArguments.SimulatorOption.Item1,
                    "-" + CommandLineArguments.SimulatorOption.Item2
                },
                () => entryPoint.DefaultSimulator,
                "The name of the simulator to use.")
            {
                Required = true
            }
            .WithSuggestions(
                AssemblyConstants.QuantumSimulator,
                AssemblyConstants.ToffoliSimulator,
                AssemblyConstants.ResourcesEstimator,
                entryPoint.DefaultSimulator);
        
        /// <summary>
        /// Creates a new driver for the entry point.
        /// </summary>
        /// <param name="entryPoint">The entry point.</param>
        public Driver(IEntryPoint<TIn, TOut> entryPoint) => this.entryPoint = entryPoint;

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
                Handler = CommandHandler.Create<ParseResult, AzureSettings>(Submit)
            };
            AddOptionsIfAvailable(submit,
                TargetOption, SubscriptionOption, ResourceGroupOption, WorkspaceOption, StorageOption);
            AddOptionIfAvailable(submit, HistogramOption);
            AddOptionIfAvailable(submit, ShotsOption,
                result => int.TryParse(result.Tokens.SingleOrDefault()?.Value, out var value) && value <= 0
                    ? $"The number of shots is {value}, but it must be a positive number."
                    : default);

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
                Subscription = settings.Subscription,
                ResourceGroup = settings.ResourceGroup,
                Workspace = settings.Workspace,
                Storage = settings.Storage,
                Shots = DefaultIfShadowed(ShotsOption, settings.Shots),
                Histogram = DefaultIfShadowed(HistogramOption, settings.Histogram)
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
        private T DefaultIfShadowed<T>(Option option, T value)
        {
            if (IsAliasAvailable(option.RawAliases.First()))
            {
                return value;
            }
            else
            {
                var originalForeground = Console.ForegroundColor;
                Console.ForegroundColor = ConsoleColor.Yellow;
                Console.Error.WriteLine(
                    $"Warning: Option {option.Aliases.First()} is overridden by an entry point parameter name. " +
                    $"Using default value {option.Argument.GetDefaultValue()}.");
                Console.ForegroundColor = originalForeground;
                return (T)option.Argument.GetDefaultValue();
            }
        }

        /// <summary>
        /// Adds the option to the command using only the aliases that are available, and only if the primary (first)
        /// alias is available. If a required option is not available, the command is disabled.
        /// </summary>
        /// <param name="command">The command to add the option to.</param>
        /// <param name="option">The option to add.</param>
        /// <param name="validator">A validator for the option.</param>
        /// <typeparam name="T">The type of the option's argument.</typeparam>
        private void AddOptionIfAvailable<T>(
            Command command, Option<T> option, ValidateSymbol<OptionResult>? validator = default)
        {
            if (IsAliasAvailable(option.RawAliases.First()))
            {
                var validAliases = option.RawAliases.Where(IsAliasAvailable).ToArray();
                var validOption = option.Argument.HasDefaultValue
                    ? new Option<T>(validAliases, () => (T)option.Argument.GetDefaultValue(), option.Description)
                    : new Option<T>(validAliases, option.Description);
                if (!(validator is null))
                {
                    validOption.AddValidator(validator);
                }
                command.AddOption(validOption.WithSuggestions(option.GetSuggestions().ToArray()));
            }
            else if (option.Required)
            {
                command.AddValidator(commandResult =>
                    $"The required option {option.RawAliases.First()} conflicts with an entry point parameter name.");
            }
        }

        /// <summary>
        /// Adds the option to the command using only the aliases that are available, and only if the primary (first)
        /// alias is available.
        /// </summary>
        /// <param name="command">The command to add the option to.</param>
        /// <param name="options">The options to add.</param>
        /// <typeparam name="T">The type of the option's argument.</typeparam>
        private void AddOptionsIfAvailable<T>(Command command, params Option<T>[] options)
        {
            foreach (var option in options)
            {
                AddOptionIfAvailable(command, option);
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
        internal static Option<string> TargetOption => new Option<string>(
            "--target", "The target device ID.") { Required = true };

        /// <summary>
        /// The subscription option.
        /// </summary>
        internal static Option<string> SubscriptionOption => new Option<string>(
            "--subscription", "The Azure subscription ID.") { Required = true };

        /// <summary>
        /// The resource group option.
        /// </summary>
        internal static Option<string> ResourceGroupOption => new Option<string>(
            "--resource-group", "The Azure resource group name.") { Required = true };

        /// <summary>
        /// The workspace option.
        /// </summary>
        internal static Option<string> WorkspaceOption => new Option<string>(
            "--workspace", "The Azure workspace name.") { Required = true };

        /// <summary>
        /// The storage option.
        /// </summary>
        internal static Option<string> StorageOption => new Option<string>(
            "--storage", "The Azure storage account connection string.") { Required = true };

        /// <summary>
        /// The shots option.
        /// </summary>
        internal static Option<int> ShotsOption => new Option<int>(
            "--shots", () => 500, "The number of times the program is executed on the target machine.");
        
        /// <summary>
        /// The histogram option.
        /// </summary>
        internal static Option<bool> HistogramOption => new Option<bool>(
            "--histogram", () => false, "Show a histogram of all outputs instead of the most frequent output.");
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
