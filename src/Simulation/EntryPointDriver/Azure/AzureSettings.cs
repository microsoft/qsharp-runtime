// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Microsoft.Azure.Quantum;
using Microsoft.Quantum.Runtime.Submitters;
using System;
using System.Linq;

namespace Microsoft.Quantum.EntryPointDriver.Azure
{
    using Environment = System.Environment;

    /// <summary>
    /// Settings for a submission to Azure Quantum.
    /// </summary>
    public sealed class AzureSettings
    {
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
        /// The base URI of the Azure Quantum endpoint. If both <see cref="BaseUri"/> and <see cref="Location"/>
        /// properties are not null, <see cref="BaseUri"/> takes precedence.
        /// </summary>
        public Uri? BaseUri { get; set; }

        /// <summary>
        /// The location to use with the default Azure Quantum endpoint. If both <see cref="BaseUri"/> and
        /// <see cref="Location"/> properties are not null, <see cref="BaseUri"/> takes precedence.
        /// </summary>
        public string? Location { get; set; }

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
            if (!(BaseUri is null))
            {
                return AadToken is null
                    ? new Workspace(Subscription, ResourceGroup, Workspace, baseUri: BaseUri)
                    : new Workspace(Subscription, ResourceGroup, Workspace, AadToken, BaseUri);
            }

            if (!(Location is null))
            {
                return AadToken is null
                    ? new Workspace(Subscription, ResourceGroup, Workspace, location: NormalizeLocation(Location))
                    : new Workspace(Subscription, ResourceGroup, Workspace, AadToken, NormalizeLocation(Location));
            }

            return AadToken is null
                ? new Workspace(Subscription, ResourceGroup, Workspace, baseUri: null)
                : new Workspace(Subscription, ResourceGroup, Workspace, AadToken, baseUri: null);
        }

        public override string ToString() => string.Join(
            Environment.NewLine,
            $"Subscription: {Subscription}",
            $"Resource Group: {ResourceGroup}",
            $"Workspace: {Workspace}",
            $"Target: {Target}",
            $"Storage: {Storage}",
            $"AAD Token: {AadToken}",
            $"Base URI: {BaseUri}",
            $"Location: {Location}",
            $"Job Name: {JobName}",
            $"Shots: {Shots}",
            $"Output: {Output}",
            $"Dry Run: {DryRun}",
            $"Verbose: {Verbose}");

        /// <summary>
        /// Normalizes an Azure location string.
        /// </summary>
        /// <param name="location">The location string.</param>
        /// <returns>The normalized location string.</returns>
        internal static string NormalizeLocation(string location) =>
            string.Concat(location.Where(c => !char.IsWhiteSpace(c))).ToLower();
    }
}
