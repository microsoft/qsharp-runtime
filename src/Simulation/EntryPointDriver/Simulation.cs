// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.CommandLine.Parsing;
using System.Threading.Tasks;
using Microsoft.Quantum.QsCompiler.ReservedKeywords;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver
{
    /// <summary>
    /// Provides entry point simulation.
    /// </summary>
    /// <typeparam name="TCallable">The entry point's callable type.</typeparam>
    /// <typeparam name="TIn">The entry point's argument type.</typeparam>
    /// <typeparam name="TOut">The entry point's return type.</typeparam>
    internal static class Simulation<TCallable, TIn, TOut> where TCallable : AbstractCallable, ICallable
    {
        /// <summary>
        /// Simulates the entry point.
        /// </summary>
        /// <param name="entryPoint">The entry point.</param>
        /// <param name="parseResult">The command-line parsing result.</param>
        /// <param name="simulator">The simulator to use.</param>
        /// <returns>The exit code.</returns>
        internal static async Task<int> Simulate(
            IEntryPoint<TIn, TOut> entryPoint, ParseResult parseResult, string simulator)
        {
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
                await RunSimulator(entryPoint, parseResult, createSimulator);
            }
            return 0;
        }
        
        /// <summary>
        /// Runs the entry point on a simulator and displays its return value.
        /// </summary>
        /// <param name="entryPoint">The entry point.</param>
        /// <param name="parseResult">The command-line parsing result.</param>
        /// <param name="createSimulator">A function that creates an instance of the simulator to use.</param>
        private static async Task RunSimulator(
            IEntryPoint<TIn, TOut> entryPoint, ParseResult parseResult, Func<IOperationFactory> createSimulator)
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
}
