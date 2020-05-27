// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.CommandLine.Parsing;
using System.Threading.Tasks;
using Microsoft.Azure.Quantum;
using Microsoft.Azure.Quantum.Exceptions;
using Microsoft.Quantum.Runtime;
using Microsoft.Quantum.Simulation.Common.Exceptions;
using static Microsoft.Quantum.CsharpGeneration.EntryPointDriver.Driver;

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver
{
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
                DisplayWithColor(ConsoleColor.Red, Console.Error,
                    $"The target '{settings.Target}' was not recognized.");
                return 1;
            }

            var input = entryPoint.CreateArgument(parseResult);
            if (settings.DryRun)
            {
                var (isValid, message) = machine.Validate(entryPoint.Info, input);
                Console.WriteLine(isValid ? "✔️  The program is valid!" : "❌  The program is invalid.");
                if (!string.IsNullOrWhiteSpace(message))
                {
                    Console.WriteLine();
                    Console.WriteLine(message);
                }
                return isValid ? 0 : 1;
            }
            else
            {
                try
                {
                    var job = await machine.SubmitAsync(
                    entryPoint.Info, input, new SubmissionContext { Shots = settings.Shots });
                    DisplayJob(job, settings.Output);
                }
                catch (AzureQuantumException azureQuantumEx)
                {
                    DisplayWithColor(
                        ConsoleColor.Red,
                        Console.Error,
                        "Something went wrong related to Azure quantum.");

                    Console.WriteLine();
                    Console.WriteLine(azureQuantumEx.Message);
                    return 1;
                }
                catch (QuantumProcessorTranslationException translationEx)
                {
                    DisplayWithColor(
                        ConsoleColor.Red,
                        Console.Error,
                        "Something went wrong when performing translation to the intermediate representation used for the target quantum machine.");

                    Console.WriteLine();
                    Console.WriteLine(translationEx.Message);
                    return 1;
                }

                return 0;
            }
        }

        /// <summary>
        /// Displays the job using the output format.
        /// </summary>
        /// <param name="job">The job.</param>
        /// <param name="format">The output format.</param>
        /// <exception cref="ArgumentOutOfRangeException">Thrown if the output format is invalid.</exception>
        private static void DisplayJob(IQuantumMachineJob job, OutputFormat format)
        {
            switch (format)
            {
                case OutputFormat.FriendlyUri:
                    // TODO:
                    DisplayWithColor(ConsoleColor.Yellow, Console.Error,
                        "The friendly URI for viewing job results is not available yet. Showing the job ID instead.");
                    Console.WriteLine(job.Id);
                    break;
                case OutputFormat.Id:
                    Console.WriteLine(job.Id);
                    break;
                default:
                    throw new ArgumentOutOfRangeException($"Invalid output format '{format}'.");
            }
        }

        /// <summary>
        /// Creates a quantum machine based on the Azure Quantum submission settings.
        /// </summary>
        /// <param name="settings">The Azure Quantum submission settings.</param>
        /// <returns>A quantum machine.</returns>
        private static IQuantumMachine? CreateMachine(AzureSettings settings) =>
            settings.Target == "nothing"
                ? new NothingMachine()
                : QuantumMachineFactory.CreateMachine(settings.CreateWorkspace(), settings.Target, settings.Storage);

        /// <summary>
        /// The quantum machine submission context.
        /// </summary>
        private sealed class SubmissionContext : IQuantumMachineSubmissionContext
        {
            public string? FriendlyName { get; set; }

            public int Shots { get; set; }
        }
    }

    /// <summary>
    /// The information to show in the output after the job is submitted.
    /// </summary>
    internal enum OutputFormat
    {
        /// <summary>
        /// Show a friendly message with a URI that can be used to see the job results.
        /// </summary>
        FriendlyUri,
        
        /// <summary>
        /// Show only the job ID.
        /// </summary>
        Id
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
        /// The storage account connection string.
        /// </summary>
        public string? Storage { get; set; }
        
        /// <summary>
        /// The subscription ID.
        /// </summary>
        public string? Subscription { get; set; }
        
        /// <summary>
        /// The resource group name.
        /// </summary>
        public string? ResourceGroup { get; set; }
        
        /// <summary>
        /// The workspace name.
        /// </summary>
        public string? Workspace { get; set; }
        
        /// <summary>
        /// The Azure Active Directory authentication token.
        /// </summary>
        public string? AadToken { get; set; }
        
        /// <summary>
        /// The base URI of the Azure Quantum endpoint.
        /// </summary>
        public Uri? BaseUri { get; set; }
        
        /// <summary>
        /// The number of times the program is executed on the target machine.
        /// </summary>
        public int Shots { get; set; }

        /// <summary>
        /// The information to show in the output after the job is submitted.
        /// </summary>
        public OutputFormat Output { get; set; }

        /// <summary>
        /// Validate the program and options, but do not submit to Azure Quantum.
        /// </summary>
        public bool DryRun { get; set; }

        /// <summary>
        /// Creates a <see cref="Workspace"/> based on the settings.
        /// </summary>
        /// <returns>The <see cref="Workspace"/> based on the settings.</returns>
        internal Workspace CreateWorkspace() =>
            AadToken is null
                ? new Workspace(Subscription, ResourceGroup, Workspace, baseUri: BaseUri)
                : new Workspace(Subscription, ResourceGroup, Workspace, AadToken, BaseUri);
    }
}
