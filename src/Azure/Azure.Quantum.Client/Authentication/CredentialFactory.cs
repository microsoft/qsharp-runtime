// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#nullable enable

namespace Microsoft.Azure.Quantum.Authentication
{
    using System;

    using global::Azure.Core;
    using global::Azure.Identity;

    /// <summary>
    /// The enumeration of supported Credential Classes supported out of the box for
    /// authentication in Azure Quantum.
    /// NOTE: For more information
    /// about authentication with Azure services and the different Credential types see
    /// https://docs.microsoft.com/en-us/dotnet/api/overview/azure/identity-readme.
    /// </summary>
    public enum CredentialType
    {
        /// <summary>
        /// Provides a simplified authentication experience to quickly start developing applications run in the Azure cloud.
        /// See: https://docs.microsoft.com/en-us/dotnet/api/azure.identity.defaultazurecredential
        /// </summary>
        Default,

        /// <summary>
        /// Authenticates a service principal or user via credential information specified in environment variables.
        /// See: https://docs.microsoft.com/en-us/dotnet/api/azure.identity.environmentcredential
        /// </summary>
        Environment,

        /// <summary>
        /// Authenticates the managed identity of an azure resource.
        /// See: https://docs.microsoft.com/en-us/dotnet/api/azure.identity.managedidentitycredential
        /// </summary>
        ManagedIdentity,

        /// <summary>
        /// Authenticate in a development environment with the Azure CLI.
        /// See https://docs.microsoft.com/en-us/dotnet/api/azure.identity.azureclicredential
        /// </summary>
        CLI,

        /// <summary>
        /// Authenticate using tokens in the local cache shared between Microsoft applications.
        /// See: https://docs.microsoft.com/en-us/dotnet/api/azure.identity.sharedtokencachecredential
        /// </summary>
        SharedToken,

        /// <summary>
        /// Authenticate using data from Visual Studio.
        /// See: https://docs.microsoft.com/en-us/dotnet/api/azure.identity.visualstudiocredential
        /// </summary>
        VisualStudio,

        /// <summary>
        /// Authenticate in a development environment with Visual Studio Code.
        /// See: https://docs.microsoft.com/en-us/dotnet/api/azure.identity.visualstudiocodecredential
        /// </summary>
        VisualStudioCode,

        /// <summary>
        /// A TokenCredential implementation which launches the system default browser to interactively authenticate a user,
        /// and obtain an access token. The browser will only be launched to authenticate the user once,
        /// then will silently acquire access tokens through the users refresh token as long as it's valid.
        /// See: https://docs.microsoft.com/en-us/dotnet/api/azure.identity.interactivebrowsercredential
        /// </summary>
        Interactive,
    }

    public static class CredentialFactory
    {
        /// <summary>
        /// Creates an instance of TokenCredential that corresponds to the given <see cref="CredentialType"/>.
        /// It creates an instance of the Credential Class with default parameters.
        /// </summary>
        /// <param name="credentialType">The type of Credential Class to create.</param>
        /// <returns>An instance of TokenCredential for the corresponding value.</returns>
        public static TokenCredential CreateCredential(CredentialType credentialType) => credentialType switch
        {
            CredentialType.Environment => new EnvironmentCredential(),
            CredentialType.ManagedIdentity => new ManagedIdentityCredential(),
            CredentialType.SharedToken => new SharedTokenCacheCredential(),
            CredentialType.VisualStudio => new VisualStudioCredential(),
            CredentialType.VisualStudioCode => new VisualStudioCodeCredential(),
            CredentialType.CLI => new AzureCliCredential(),
            CredentialType.Interactive => new InteractiveBrowserCredential(),
            CredentialType.Default => new DefaultAzureCredential(includeInteractiveCredentials: true),
            _ => throw new ArgumentException($"Credentials of type {credentialType} are not supported.")
        };
    }
}