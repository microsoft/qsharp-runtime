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
using Microsoft.Quantum.Simulation.Simulators;
using static Microsoft.Quantum.CsharpGeneration.EntryPointDriver.Driver;

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver
{
    /// <summary>
    /// The entry point driver is the entry point for the C# application that executes the Q# entry point.
    /// </summary>
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
            TryCreateOption(
                    SimulatorOptions,
                    () => entryPoint.DefaultSimulator,
                    "The name of the simulator to use.")
                .Then(simulator => simulate.AddOption(simulator.WithSuggestions(
                    AssemblyConstants.QuantumSimulator,
                    AssemblyConstants.ToffoliSimulator,
                    AssemblyConstants.ResourcesEstimator,
                    entryPoint.DefaultSimulator)));

            var submit = new Command("submit", "Submit the program to Azure Quantum.")
            {
                Handler = CommandHandler.Create<ParseResult>(Submit)
            };

            var root = new RootCommand(entryPoint.Summary) { simulate, submit };
            foreach (var option in entryPoint.Options) { root.AddGlobalOption(option); }

            // Set the simulate command as the default.
            foreach (var option in simulate.Options) { root.AddOption(option); }
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
            if (simulator == AssemblyConstants.ResourcesEstimator)
            {
                var resourcesEstimator = new ResourcesEstimator();
                await resourcesEstimator.Run<TCallable, TIn, TOut>(entryPoint.CreateArgument(parseResult));
                Console.WriteLine(resourcesEstimator.ToTSV());
            }
            else
            {
                var (isCustom, createSimulator) =
                    simulator == AssemblyConstants.QuantumSimulator
                    ? (false, () => new QuantumSimulator())
                    : simulator == AssemblyConstants.ToffoliSimulator
                    ? (false, new Func<IOperationFactory>(() => new ToffoliSimulator()))
                    : (true, entryPoint.CreateDefaultCustomSimulator);
                if (isCustom && simulator != entryPoint.DefaultSimulator)
                {
                    DisplayCustomSimulatorError(simulator);
                    return 1;
                }
                await RunSimulator(parseResult, createSimulator);
            }
            return 0;
        }

        /// <summary>
        /// Submits the entry point to Azure Quantum.
        /// </summary>
        /// <param name="parseResult">The command-line parsing result.</param>
        private async Task Submit(ParseResult parseResult)
        {
            // TODO: Use an actual quantum machine.
            var machine = new SimulatorMachine();
            var output = await machine.ExecuteAsync(entryPoint.Info, entryPoint.CreateArgument(parseResult));
            foreach (var (result, frequency) in output.Histogram)
            {
                Console.WriteLine($"{result} (frequency = {frequency})");
            }
        }

        /// <summary>
        /// Runs the entry point on a simulator and displays its return value.
        /// </summary>
        /// <param name="parseResult">The command-line parsing result.</param>
        /// <param name="createSimulator">A function that creates an instance of the simulator to use.</param>
        private async Task RunSimulator(ParseResult parseResult, Func<IOperationFactory> createSimulator)
        {
            var simulator = createSimulator();
            try
            {
                var value = await simulator.Run<TCallable, TIn, TOut>(entryPoint.CreateArgument(parseResult));
                if (!(value is QVoid))
                {
                    Console.WriteLine(value);
                }
            }
            finally
            {
                if (simulator is IDisposable disposable)
                {
                    disposable.Dispose();
                }
            }
        }

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
        /// Tries to create an option by removing aliases that are already in use by the entry point. If the first
        /// alias, which is considered the primary alias, is in use, then the option is not created.
        /// </summary>
        /// <typeparam name="T">The type of the option's argument.</typeparam>
        /// <param name="aliases">The option's aliases.</param>
        /// <param name="getDefaultValue">A function that returns the option's default value.</param>
        /// <param name="description">The option's description.</param>
        /// <returns>A validation of the option.</returns>
        private Validation<Option<T>> TryCreateOption<T>(
                IReadOnlyCollection<string> aliases, Func<T> getDefaultValue, string? description = null) =>
            IsAliasAvailable(aliases.First())
            ? Validation<Option<T>>.Success(
                new Option<T>(
                    aliases.Where(IsAliasAvailable).ToArray(),
                    getDefaultValue,
                    description))
            : Validation<Option<T>>.Failure();

        /// <summary>
        /// Displays an error message for using a non-default custom simulator.
        /// </summary>
        /// <param name="name">The name of the custom simulator.</param>
        private static void DisplayCustomSimulatorError(string name)
        {
            var originalForeground = Console.ForegroundColor;
            Console.ForegroundColor = ConsoleColor.Red;
            Console.Error.WriteLine($"The simulator '{name}' could not be found.");
            Console.ForegroundColor = originalForeground;
            Console.Error.WriteLine();
            Console.Error.WriteLine(
                $"If '{name}' is a custom simulator, it must be set in the DefaultSimulator project property:");
            Console.Error.WriteLine();
            Console.Error.WriteLine("<PropertyGroup>");
            Console.Error.WriteLine($"  <DefaultSimulator>{name}</DefaultSimulator>");
            Console.Error.WriteLine("</PropertyGroup>");
        }
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
