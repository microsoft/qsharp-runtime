﻿// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using static Microsoft.Quantum.EntryPointDriver.Driver;

namespace Microsoft.Quantum.EntryPointDriver
{
    /// <summary>
    /// Provides entry point simulation.
    /// </summary>
    /// <typeparam name="TCallable">The entry point's callable type.</typeparam>
    /// <typeparam name="TIn">The entry point's argument type.</typeparam>
    /// <typeparam name="TOut">The entry point's return type.</typeparam>
    public static class Simulation<TCallable, TIn, TOut> where TCallable : AbstractCallable, ICallable
    {
        /// <summary>
        /// Simulates the entry point.
        /// </summary>
        /// <param name="entryPoint">The entry point.</param>
        /// <param name="input">The input argument tuple to the entry point.</param>
        /// <param name="settings">The driver settings.</param>
        /// <param name="simulator">The simulator to use.</param>
        /// <returns>The exit code.</returns>
        public static async Task<int> Simulate(
            IEntryPoint entryPoint, TIn input, DriverSettings settings, string simulator)
        {
            if (simulator == settings.ResourcesEstimatorName)
            {
                // Force the explicit load of the QSharp.Core assembly so that the ResourcesEstimator
                // can discover it dynamically at runtime and override the defined callables.
                var coreAssemblyName = 
                    (from aName in entryPoint.GetType().Assembly.GetReferencedAssemblies()
                    where aName.Name == "Microsoft.Quantum.QSharp.Core"
                    select aName).FirstOrDefault();
                var coreAssembly = coreAssemblyName != null ? 
                    Assembly.Load(coreAssemblyName.FullName) :
                    null;

                var resourcesEstimator = new ResourcesEstimator(coreAssembly);
                await resourcesEstimator.Run<TCallable, TIn, TOut>(input);
                Console.WriteLine(resourcesEstimator.ToTSV());
            }
            else
            {
                var (isCustom, createSimulator) =
                    simulator == settings.QuantumSimulatorName
                        ? (false, () => new QuantumSimulator())
                        : simulator == settings.ToffoliSimulatorName
                        ? (false, new Func<IOperationFactory>(() => new ToffoliSimulator()))
                        : (true, settings.CreateDefaultCustomSimulator);
                if (isCustom && simulator != settings.DefaultSimulatorName)
                {
                    DisplayCustomSimulatorError(simulator);
                    return 1;
                }
                await RunSimulator(input, createSimulator);
            }

            return 0;
        }

        /// <summary>
        /// Runs the entry point on a simulator and displays its return value.
        /// </summary>
        /// <param name="input">The input argument tuple to the entry point.</param>
        /// <param name="createSimulator">A function that creates an instance of the simulator to use.</param>
        private static async Task RunSimulator(TIn input, Func<IOperationFactory> createSimulator)
        {
            var simulator = createSimulator();
            try
            {
                var value = await simulator.Run<TCallable, TIn, TOut>(input);
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
            DisplayWithColor(ConsoleColor.Red, Console.Error, $"The simulator '{name}' could not be found.");
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
