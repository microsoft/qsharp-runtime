// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

using Azure.Core;
using Azure.Identity;

using Microsoft.Azure.Quantum;
using Microsoft.Azure.Quantum.Authentication;
using Microsoft.Azure.Quantum.Exceptions;
using Microsoft.Quantum.Runtime;
using Microsoft.Quantum.Simulation.Common.Exceptions;
using Microsoft.Quantum.Simulation.Core;
using static Microsoft.Quantum.EntryPointDriver.Driver;

namespace Microsoft.Quantum.EntryPointDriver
{
    /// <summary>
    /// Provides entry point submission to Azure Quantum.
    /// </summary>
    public static class Azure
    {
        /// <summary>
        /// Submits the entry point to Azure Quantum.
        /// </summary>
        /// <typeparam name="TIn">The entry point's argument type.</typeparam>
        /// <typeparam name="TOut">The entry point's return type.</typeparam>
        /// <param name="info">The information about the entry point.</param>
        /// <param name="input">The input argument tuple to the entry point.</param>
        /// <param name="settings">The submission settings.</param>
        /// <returns>The exit code.</returns>
        public static async Task<int> Submit<TIn, TOut>(EntryPointInfo<TIn, TOut> info, TIn input, AzureSettings settings)
        {
            if (settings.Verbose)
            {
                Console.WriteLine(settings);
                Console.WriteLine();
            }

            if ((settings.Location is null) && (settings.BaseUri is null))
            {
                DisplayWithColor(ConsoleColor.Red, Console.Error,
                    $"Either --location or --base-uri must be provided.");
                return 1;
            }

            var machine = CreateMachine(settings);
            if (machine is null)
            {
                DisplayWithColor(ConsoleColor.Red, Console.Error,
                    $"The target '{settings.Target}' was not recognized.");
                return 1;
            }

            return settings.DryRun
                ? Validate(machine, info, input)
                : await SubmitJob(machine, info, input, settings);
        }

        /// <summary>
        /// Submits a job to Azure Quantum.
        /// </summary>
        /// <typeparam name="TIn">The input type.</typeparam>
        /// <typeparam name="TOut">The output type.</typeparam>
        /// <param name="machine">The quantum machine target.</param>
        /// <param name="info">The information about the entry point.</param>
        /// <param name="input">The input argument tuple to the entry point.</param>
        /// <param name="settings">The submission settings.</param>
        /// <returns>The exit code.</returns>
        private static async Task<int> SubmitJob<TIn, TOut>(
            IQuantumMachine machine, EntryPointInfo<TIn, TOut> info, TIn input, AzureSettings settings)
        {
            try
            {
                var job = await machine.SubmitAsync(info, input, new SubmissionContext
                {
                    FriendlyName = settings.JobName,
                    Shots = settings.Shots
                });
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
        /// <typeparam name="TIn">The input type.</typeparam>
        /// <typeparam name="TOut">The output type.</typeparam>
        /// <param name="machine">The quantum machine target.</param>
        /// <param name="info">The information about the entry point.</param>
        /// <param name="input">The input argument tuple to the entry point.</param>
        /// <returns>The exit code.</returns>
        private static int Validate<TIn, TOut>(IQuantumMachine machine, EntryPointInfo<TIn, TOut> info, TIn input)
        {
            var (isValid, message) = machine.Validate(info, input);
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
                    try
                    {
                        Console.WriteLine(job.Uri);
                    }
                    catch (Exception ex)
                    {
                        DisplayWithColor(
                            ConsoleColor.Yellow,
                            Console.Error,
                            $"The friendly URI for viewing job results could not be obtained.{System.Environment.NewLine}" +
                            $"Error details: {ex.Message}" +
                            $"Showing the job ID instead.");

                        Console.WriteLine(job.Id);
                    }
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
        /// <exception cref="ArgumentNullException">Thrown if <paramref name="settings"/>.Target is null.</exception>
        /// <returns>A quantum machine.</returns>
        private static IQuantumMachine? CreateMachine(AzureSettings settings) => settings.Target switch
        {
            null => throw new ArgumentNullException(nameof(settings), "Target is null."),
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
    public enum OutputFormat
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
    public sealed class AzureSettings
    {
        private class AADTokenCredential : TokenCredential
        {
            AccessToken Token { get; }

            public AADTokenCredential(string token)
            {
                Token = new AccessToken(token, DateTime.Now.AddMinutes(5));
            }

            public override AccessToken GetToken(TokenRequestContext requestContext, CancellationToken cancellationToken) =>
                Token;

            public override ValueTask<AccessToken> GetTokenAsync(TokenRequestContext requestContext, CancellationToken cancellationToken) =>
                new ValueTask<AccessToken>(Token);
        }

        /// <summary>
        /// The subscription ID.
        /// </summary>
        public string? Subscription { get; set; }

        /// <summary>
        /// The Azure Quantum workspace's resource group name.
        /// </summary>
        public string? ResourceGroup { get; set; }

        /// <summary>
        /// The Azure Quantum workspace's name.
        /// </summary>
        public string? Workspace { get; set; }

        /// <summary>
        /// The target device ID.
        /// </summary>
        public string? Target { get; set; }

        /// <summary>
        /// The storage account connection string.
        /// </summary>
        public string? Storage { get; set; }

        /// <summary>
        /// The Azure Active Directory authentication token.
        /// </summary>
        public string? AadToken { get; set; }

        /// <summary>
        /// The type of Credentials to use to authenticate with Azure. For more information
        /// about authentication with Azure services see: https://docs.microsoft.com/dotnet/api/overview/azure/identity-readme
        /// NOTE: If both <see cref="AadToken"/> and <see cref="Credential"/> properties are specified, <see cref="AadToken"/> takes precedence.
        /// If none are provided, then it uses <see cref="CredentialType.Default"/>.
        /// </summary>
        public CredentialType? Credential { get; set; }

        /// <summary>
        /// The base URI of the Azure Quantum endpoint.
        /// NOTE: This parameter is deprected, please always use <see cref="Location"/>.
        /// If both <see cref="BaseUri"/> and <see cref="Location"/> properties are not null, <see cref="Location"/> takes precedence.
        /// </summary>
        public Uri? BaseUri { get; set; }

        /// <summary>
        /// The Azure Quantum Workspace's location (region).
        /// If both <see cref="BaseUri"/> and <see cref="Location"/> properties are not null, <see cref="Location"/> takes precedence.
        /// </summary>
        public string? Location { get; set; }

        /// <summary>
        /// The name of the submitted job.
        /// </summary>
        public string? JobName { get; set; }

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

        internal TokenCredential CreateCredentials()
        {
            if (!(AadToken is null))
            {
                return new AADTokenCredential(AadToken);
            }
            else
            {
                return CredentialFactory.CreateCredential(Credential ?? CredentialType.Default, Subscription);
            }
        }

        /// <summary>
        /// Creates a <see cref="Workspace"/> based on the settings.
        /// </summary>
        /// <returns>The <see cref="Workspace"/> based on the settings.</returns>
        internal Workspace CreateWorkspace()
        {
            var credentials = CreateCredentials();
            var location = NormalizeLocation(Location ?? ExtractLocation(BaseUri));

            return new Workspace(
                subscriptionId: Subscription, 
                resourceGroupName: ResourceGroup,
                workspaceName: Workspace, 
                location: location,
                credential: credentials);
        }

        public override string ToString() =>
            string.Join(System.Environment.NewLine,
                $"Subscription: {Subscription}",
                $"Resource Group: {ResourceGroup}",
                $"Workspace: {Workspace}",
                $"Target: {Target}",
                $"Storage: {Storage}",
                $"Base URI: {BaseUri}",
                $"Location: {Location ?? ExtractLocation(BaseUri)}",
                $"Credential: {Credential}",
                $"AadToken: {AadToken?.Substring(0, 5)}",
                $"Job Name: {JobName}",
                $"Shots: {Shots}",
                $"Output: {Output}",
                $"Dry Run: {DryRun}",
                $"Verbose: {Verbose}");

        internal static string ExtractLocation(Uri? baseUri)
        {
            if (baseUri is null || !baseUri.IsAbsoluteUri)
            {
                return "";
            }

            return baseUri.Host.Substring(0, baseUri.Host.IndexOf('.'));
        }

        internal static string NormalizeLocation(string location) =>
            string.Concat(location.Where(c => !char.IsWhiteSpace(c))).ToLower();
    }
}
