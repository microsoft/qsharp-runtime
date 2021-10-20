// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Azure.Core;
using Azure.Quantum;

using Microsoft.Azure.Quantum;
using Microsoft.Azure.Quantum.Authentication;
using Microsoft.Quantum.Runtime.Submitters;
using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Microsoft.Quantum.EntryPointDriver
{
    using Environment = System.Environment;

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
        /// A string to identify this application when making requests to Azure Quantum.
        /// </summary>
        public string? UserAgent { get; set; }

        /// <summary>
        /// The name of the submitted job.
        /// </summary>
        public string JobName { get; set; } = "";

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

        internal QuantumJobClientOptions CreateClientOptions()
        {
            var options = new QuantumJobClientOptions();

            // This value will be added as a prefix in the UserAgent when
            // calling the Azure Quantum API
            options.Diagnostics.ApplicationId = string.Join(' ', "Q#Runtime", UserAgent);
            return options;
        }

        /// <summary>
        /// The submission options corresponding to these settings.
        /// </summary>
        internal SubmissionOptions SubmissionOptions => SubmissionOptions.Default.With(JobName, Shots);

        /// <summary>
        /// Creates a <see cref="Workspace"/> based on the settings.
        /// </summary>
        /// <returns>The <see cref="Workspace"/> based on the settings.</returns>
        internal Workspace CreateWorkspace()
        {
            var credentials = CreateCredentials();
            var clientOptions = CreateClientOptions();
            var location = NormalizeLocation(Location ?? ExtractLocation(BaseUri));

            return new Workspace(
                subscriptionId: Subscription,
                resourceGroupName: ResourceGroup,
                workspaceName: Workspace,
                location: location,
                credential: credentials,
                options: clientOptions);
        }

        public override string ToString() => string.Join(
            Environment.NewLine,
            $"Subscription: {Subscription}",
            $"Resource Group: {ResourceGroup}",
            $"Workspace: {Workspace}",
            $"Target: {Target}",
            $"Storage: {Storage}",
            $"Base URI: {BaseUri}",
            $"Location: {Location ?? ExtractLocation(BaseUri)}",
            $"Credential: {Credential}",
            $"AadToken: {AadToken?.Substring(0, 5)}",
            $"UserAgent: {UserAgent}",
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

        /// <summary>
        /// Normalizes an Azure location string.
        /// </summary>
        /// <param name="location">The location string.</param>
        /// <returns>The normalized location string.</returns>
        internal static string NormalizeLocation(string location) =>
            string.Concat(location.Where(c => !char.IsWhiteSpace(c))).ToLower();
    }
}
