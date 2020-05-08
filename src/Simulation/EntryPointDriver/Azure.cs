// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System.Collections.Generic;
using System.CommandLine.Parsing;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Quantum.Runtime;

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver
{
    using System;
    
    /// <summary>
    /// Provides entry point submission to Azure Quantum.
    /// </summary>
    internal static class Azure
    {
        /// <summary>
        /// Submits the entry point to Azure Quantum.
        /// </summary>
        /// <param name="entryPoint">The entry point.</param>
        /// <param name="parseResult">The command-line parsing result.</param>
        /// <param name="settings">The submission settings.</param>
        /// <typeparam name="TIn">The entry point's argument type.</typeparam>
        /// <typeparam name="TOut">The entry point's return type.</typeparam>
        internal static async Task<int> Submit<TIn, TOut>(
            IEntryPoint<TIn, TOut> entryPoint, ParseResult parseResult, AzureSettings settings)
        {
            var machine = CreateMachine(settings);
            if (machine is null)
            {
                DisplayUnknownTargetError(settings.Target);
                return 1;
            }
            
            var output = await machine.ExecuteAsync(entryPoint.Info, entryPoint.CreateArgument(parseResult));
            if (settings.Histogram)
            {
                DisplayHistogram(output.Histogram);
            }
            else
            {
                Console.WriteLine(MostFrequentOutput(output.Histogram));
            }
            return 0;
        }

        /// <summary>
        /// Creates a quantum machine based on the Azure Quantum submission settings.
        /// </summary>
        /// <param name="settings">The Azure Quantum submission settings.</param>
        /// <returns>A quantum machine.</returns>
        private static IQuantumMachine? CreateMachine(AzureSettings settings)
        {
            if (settings.Target == "quantum.simulator")
            {
                return new SimulatorMachine(settings.Shots);
            }
            else if (!(settings.Target is null) && settings.Target.StartsWith("ionq."))
            {
                // TODO: Number of shots?
                var ionQType = Type.GetType(
                    "Microsoft.Quantum.Providers.IonQ.Targets.IonQQuantumMachine, Microsoft.Quantum.Providers.IonQ",
                    throwOnError: true);
                return (IQuantumMachine)Activator.CreateInstance(
                    ionQType, settings.Target, settings.Storage, settings.ToWorkspace());
            }
            else
            {
                return null;
            }
        }

        /// <summary>
        /// Returns the most frequent output in the histogram.
        /// </summary>
        /// <param name="histogram">The histogram.</param>
        /// <typeparam name="T">The output type.</typeparam>
        /// <returns>The most frequent output in the histogram.</returns>
        private static T MostFrequentOutput<T>(IReadOnlyDictionary<T, double> histogram) => histogram
            .Aggregate((a, b) => a.Value > b.Value ? a : b)
            .Key;

        /// <summary>
        /// Displays the histogram.
        /// </summary>
        /// <param name="histogram">The histogram.</param>
        /// <typeparam name="T">The type of the results in the histogram.</typeparam>
        private static void DisplayHistogram<T>(IReadOnlyDictionary<T, double> histogram)
        {
            const int barWidth = 20;
            var maxFrequency = histogram.Values.Max();

            string Bar(double frequency) =>
                new string('█', Convert.ToInt32(Math.Round(frequency / maxFrequency * barWidth)));

            var results = CreateTableColumn("Result", histogram.Keys);
            var bars = CreateTableColumn("Frequency", histogram.Values.Select(Bar));
            var numbers = CreateTableColumn("", histogram.Values);
            DisplayTable(results, bars, numbers);
        }

        /// <summary>
        /// Creates a table column.
        /// </summary>
        /// <param name="name">The name of the column.</param>
        /// <param name="items">The items in the column.</param>
        /// <typeparam name="T">The type of the items.</typeparam>
        /// <returns>A table column.</returns>
        private static IReadOnlyList<string> CreateTableColumn<T>(string name, IEnumerable<T> items)
        {
            var divider = new string('-', name.Length);
            var column = new[] { name, divider }
                .Concat(items.Select(item => item?.ToString() ?? ""))
                .ToList();
            var width = column.Max(item => item.Length);
            return column.Select(row => row.PadRight(width)).ToList();
        }

        /// <summary>
        /// Displays the table.
        /// </summary>
        /// <param name="columns">The columns in the table.</param>
        private static void DisplayTable(params IReadOnlyList<string>[] columns)
        {
            var height = columns.Max(column => column.Count);
            foreach (var row in Enumerable.Range(0, height))
            {
                Console.WriteLine(string.Join(
                    "  ",
                    columns.Select(column => column.ElementAtOrDefault(row) ?? "")));
            }
        }

        /// <summary>
        /// Displays an error message for attempting to use an unknown target machine.
        /// </summary>
        /// <param name="target">The target machine.</param>
        private static void DisplayUnknownTargetError(string? target)
        {
            var originalForeground = Console.ForegroundColor;
            Console.ForegroundColor = ConsoleColor.Red;
            Console.Error.WriteLine($"The target '{target}' was not recognized.");
            Console.ForegroundColor = originalForeground;
        }
    }
    
    /// <summary>
    /// Settings for a submission to Azure Quantum.
    /// </summary>
    internal sealed class AzureSettings
    {
        /// <summary>
        /// The target device ID.
        /// </summary>
        public string? Target { get; set; }
        
        /// <summary>
        /// The Azure subscription ID.
        /// </summary>
        public string? Subscription { get; set; }
        
        /// <summary>
        /// The Azure resource group name.
        /// </summary>
        public string? ResourceGroup { get; set; }
        
        /// <summary>
        /// The Azure workspace name.
        /// </summary>
        public string? Workspace { get; set; }
        
        /// <summary>
        /// The Azure storage account connection string.
        /// </summary>
        public string? Storage { get; set; }
        
        /// <summary>
        /// The number of times the program is executed on the target machine.
        /// </summary>
        public int Shots { get; set; }
        
        /// <summary>
        /// Show a histogram of all outputs instead of the most frequent output.
        /// </summary>
        public bool Histogram { get; set; }

        /// <summary>
        /// Converts these settings into a Microsoft.Azure.Quantum.Workspace object.
        /// </summary>
        /// <returns>The workspace object corresponding to these settings.</returns>
        internal object ToWorkspace()
        {
            var workspaceType = Type.GetType(
                "Microsoft.Azure.Quantum.Workspace, Microsoft.Azure.Quantum.Client", throwOnError: true);
            var tokenCredentialType = Type.GetType("Azure.Core.TokenCredential, Azure.Core", throwOnError: true);
            var constructor = workspaceType.GetConstructor(new[]
                { typeof(string), typeof(string), typeof(string), tokenCredentialType, typeof(Uri) });
            return constructor.Invoke(new object?[] { Subscription, ResourceGroup, Workspace, null, null });
        }
    }
}
