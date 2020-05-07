// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
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
            AddOptionIfAvailable(simulate, SimulatorOptions, entryPoint.DefaultSimulator, 
                "The name of the simulator to use.",
                new[]
                {
                    AssemblyConstants.QuantumSimulator,
                    AssemblyConstants.ToffoliSimulator,
                    AssemblyConstants.ResourcesEstimator,
                    entryPoint.DefaultSimulator
                });

            var submit = new Command("submit", "Submit the program to Azure Quantum.")
            {
                Handler = CommandHandler.Create<ParseResult, AzureSettings>(Submit)
            };
            // TODO: Define the aliases as constants.
            AddOptionIfAvailable<string>(submit, new[] { "--target" }, "The target device ID.");
            AddOptionIfAvailable<string>(submit, new[] { "--subscription" }, "The Azure subscription ID.");
            AddOptionIfAvailable<string>(submit, new[] { "--resource-group" }, "The Azure resource group name.");
            AddOptionIfAvailable<string>(submit, new[] { "--workspace" }, "The Azure workspace name.");
            AddOptionIfAvailable<string>(submit, new[] { "--storage" }, "The Azure storage account connection string.");
            // TODO: Validate that shots is non-negative.
            AddOptionIfAvailable(submit, new [] { "--shots" }, 500,
                "The number of times the program is executed on the target machine.");

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
        private async Task<int> Simulate(ParseResult parseResult, string simulator)
        {
            simulator = DefaultIfShadowed(SimulatorOptions.First(), simulator, entryPoint.DefaultSimulator);
            return await Simulation<TCallable, TIn, TOut>.Simulate(entryPoint, parseResult, simulator);
        }

        /// <summary>
        /// Submits the entry point to Azure Quantum.
        /// </summary>
        /// <param name="parseResult">The command-line parsing result.</param>
        /// <param name="settings">The submission settings.</param>
        private async Task<int> Submit(ParseResult parseResult, AzureSettings settings) =>
            // TODO: DefaultIfShadowed
            await Azure.Submit(entryPoint, parseResult, settings);
        
        /// <summary>
        /// Returns true if the alias is not already used by an entry point option.
        /// </summary>
        /// <param name="alias">The alias to check.</param>
        /// <returns>True if the alias is available for use by the driver.</returns>
        private bool IsAliasAvailable(string alias) =>
            !entryPoint.Options.SelectMany(option => option.RawAliases).Contains(alias);

        /// <summary>
        /// Returns the default value and displays a warning if the alias is shadowed by an entry point option, and
        /// returns the original value otherwise.
        /// </summary>
        /// <typeparam name="T">The type of the option values.</typeparam>
        /// <param name="alias">The primary option alias corresponding to the value.</param>
        /// <param name="value">The value of the option given on the command line.</param>
        /// <param name="defaultValue">The default value for the option.</param>
        /// <returns>The default value or the original value.</returns>
        private T DefaultIfShadowed<T>(string alias, T value, T defaultValue)
        {
            if (IsAliasAvailable(alias))
            {
                return value;
            }
            else
            {
                var originalForeground = Console.ForegroundColor;
                Console.ForegroundColor = ConsoleColor.Yellow;
                Console.Error.WriteLine(
                    $"Warning: Option {alias} is overridden by an entry point parameter name. " +
                    $"Using default value {defaultValue}.");
                Console.ForegroundColor = originalForeground;
                return defaultValue;
            }
        }

        /// <summary>
        /// Evaluates the given function on the collection of available aliases if the primary (first) alias is
        /// available.
        /// </summary>
        /// <param name="aliases">The aliases to check for availability.</param>
        /// <param name="func">The function to evaluate on the available aliases.</param>
        /// <typeparam name="T">The given function's return type.</typeparam>
        /// <returns>The return value of the given function or a failure if the first alias is not available.</returns>
        private Validation<T> TryWithAvailableAliases<T>(
                IReadOnlyCollection<string> aliases, Func<IReadOnlyCollection<string>, T> func) =>
            IsAliasAvailable(aliases.First())
                ? Validation<T>.Success(func(aliases.Where(IsAliasAvailable).ToArray()))
                : Validation<T>.Failure();

        /// <summary>
        /// Adds the required option to the command using only the aliases that are available, and only if the primary
        /// (first) alias is available.
        /// </summary>
        /// <param name="command">The command to add the option to.</param>
        /// <param name="aliases">The collection of option aliases.</param>
        /// <param name="description">The option description.</param>
        /// <typeparam name="T">The type of the option values.</typeparam>
        private void AddOptionIfAvailable<T>(
                Command command, IReadOnlyCollection<string> aliases, string? description = default) =>
            TryWithAvailableAliases(aliases, validAliases =>
                new Option<T>(validAliases.ToArray(), description) { Required = true }).Then(command.AddOption);

        /// <summary>
        /// Adds the option to the command using only the aliases that are available, and only if the primary (first)
        /// alias is available.
        /// </summary>
        /// <param name="command">The command to add the option to.</param>
        /// <param name="aliases">The collection of option aliases.</param>
        /// <param name="defaultValue">The default value of the option.</param>
        /// <param name="description">The option description.</param>
        /// <param name="suggestions">The suggestions for the option's values.</param>
        /// <typeparam name="T">The type of the option values.</typeparam>
        private void AddOptionIfAvailable<T>(
                Command command,
                IReadOnlyCollection<string> aliases,
                T defaultValue,
                string? description = default,
                string[]? suggestions = default) =>
            TryWithAvailableAliases(aliases, validAliases =>
                new Option<T>(validAliases.ToArray(), () => defaultValue, description)).Then(option =>
                command.AddOption(suggestions is null || !suggestions.Any()
                    ? option
                    : option.WithSuggestions(suggestions)));
    }

    /// <summary>
    /// Static members for <see cref="Driver{TCallable,TIn,TOut}"/> that do not depend on its type parameters.
    /// </summary>
    internal static class Driver
    {
        /// <summary>
        /// The option aliases for the simulator option.
        /// </summary>
        internal static readonly IReadOnlyCollection<string> SimulatorOptions = Array.AsReadOnly(new[]
        {
            "--" + CommandLineArguments.SimulatorOption.Item1,
            "-" + CommandLineArguments.SimulatorOption.Item2
        });
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
