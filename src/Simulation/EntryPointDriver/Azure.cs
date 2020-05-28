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
        /// <returns>The exit code.</returns>
        internal static async Task<int> Submit<TIn, TOut>(
            IEntryPoint<TIn, TOut> entryPoint, ParseResult parseResult, AzureSettings settings)
        {
            if (settings.Verbose)
            {
                Console.WriteLine(settings);
                Console.WriteLine();
            }

            var machine = CreateMachine(settings);
            if (machine is null)
            {
                DisplayWithColor(ConsoleColor.Red, Console.Error,
                    $"The target '{settings.Target}' was not recognized.");
                return 1;
            }

            var input = entryPoint.CreateArgument(parseResult);
            return settings.DryRun
                ? Validate(machine, entryPoint, input)
                : await SubmitJob(machine, entryPoint, input, settings);
        }

        /// <summary>
        /// Submits a job to Azure Quantum.
        /// </summary>
        /// <param name="machine">The quantum machine target.</param>
        /// <param name="entryPoint">The program entry point.</param>
        /// <param name="input">The program input.</param>
        /// <param name="settings">The submission settings.</param>
        /// <typeparam name="TIn">The input type.</typeparam>
        /// <typeparam name="TOut">The output type.</typeparam>
        /// <returns>The exit code.</returns>
        private static async Task<int> SubmitJob<TIn, TOut>(
            IQuantumMachine machine, IEntryPoint<TIn, TOut> entryPoint, TIn input, AzureSettings settings)
        {
            try
            {
                var job = await machine.SubmitAsync(
                    entryPoint.Info, input, new SubmissionContext { Shots = settings.Shots });
                DisplayJob(job, settings.Output);
                return 0;
            }
            catch (AzureQuantumException ex)
            {
                DisplayError(
                    "Something went wrong when submitting the program to the Azure Quantum service.", 
                    ex.Message);
                return 1;
            }
            catch (QuantumProcessorTranslationException ex)
            {
                DisplayError(
                    "Something went wrong when performing translation to the intermediate representation used by the " +
                    "target quantum machine.",
                    ex.Message);
                return 1;
            }
        }

        /// <summary>
        /// Validates the program for the quantum machine target.
        /// </summary>
        /// <param name="machine">The quantum machine target.</param>
        /// <param name="entryPoint">The program entry point.</param>
        /// <param name="input">The program input.</param>
        /// <typeparam name="TIn">The input type.</typeparam>
        /// <typeparam name="TOut">The output type.</typeparam>
        /// <returns>The exit code.</returns>
        private static int Validate<TIn, TOut>(IQuantumMachine machine, IEntryPoint<TIn, TOut> entryPoint, TIn input)
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
        /// Displays an error to the console.
        /// </summary>
        /// <param name="summary">A summary of the error.</param>
        /// <param name="message">The full error message.</param>
        private static void DisplayError(string summary, string message)
        {
            DisplayWithColor(ConsoleColor.Red, Console.Error, summary);
            Console.Error.WriteLine();
            Console.Error.WriteLine(message);
        }

        /// <summary>
        /// Creates a quantum machine based on the Azure Quantum submission settings.
        /// </summary>
        /// <param name="settings">The Azure Quantum submission settings.</param>
        /// <returns>A quantum machine.</returns>
        private static IQuantumMachine? CreateMachine(AzureSettings settings) => settings.Target switch
        {
            NothingMachine.TargetId => new NothingMachine(),
            ErrorMachine.TargetId => new ErrorMachine(),
            _ => QuantumMachineFactory.CreateMachine(settings.CreateWorkspace(), settings.Target, settings.Storage)
        };

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
        /// Show additional information about the submission.
        /// </summary>
        public bool Verbose { get; set; }

        /// <summary>
        /// Creates a <see cref="Workspace"/> based on the settings.
        /// </summary>
        /// <returns>The <see cref="Workspace"/> based on the settings.</returns>
        internal Workspace CreateWorkspace() =>
            AadToken is null
                ? new Workspace(Subscription, ResourceGroup, Workspace, baseUri: BaseUri)
                : new Workspace(Subscription, ResourceGroup, Workspace, AadToken, BaseUri);

        public override string ToString() =>
            string.Join(System.Environment.NewLine,
                $"Target: {Target}",
                $"Storage: {Storage}",
                $"Subscription: {Subscription}",
                $"Resource Group: {ResourceGroup}",
                $"Workspace: {Workspace}",
                $"AAD Token: {AadToken}",
                $"Base URI: {BaseUri}",
                $"Shots: {Shots}",
                $"Output: {Output}",
                $"Dry Run: {DryRun}",
                $"Verbose: {Verbose}");
    }
}
