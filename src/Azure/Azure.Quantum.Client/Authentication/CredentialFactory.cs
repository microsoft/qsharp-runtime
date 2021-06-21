// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#nullable enable

namespace Microsoft.Azure.Quantum.Authentication
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Net.Http;

    using global::Azure.Core;
    using global::Azure.Identity;

    /// <summary>
    /// The enumeration of supported Credential Classes supported out of the box for
    /// authentication in Azure Quantum.
    /// NOTE: For more information
    /// about authentication with Azure services and the different Credential types see
    /// https://docs.microsoft.com/dotnet/api/overview/azure/identity-readme.
    /// </summary>
    public enum CredentialType
    {
        /// <summary>
        /// Provides a simplified authentication experience to quickly start developing applications run in the Azure cloud.
        /// See: https://docs.microsoft.com/dotnet/api/azure.identity.defaultazurecredential
        /// </summary>
        Default,

        /// <summary>
        /// Authenticates a service principal or user via credential information specified in environment variables.
        /// See: https://docs.microsoft.com/dotnet/api/azure.identity.environmentcredential
        /// </summary>
        Environment,

        /// <summary>
        /// Authenticates the managed identity of an azure resource.
        /// See: https://docs.microsoft.com/dotnet/api/azure.identity.managedidentitycredential
        /// </summary>
        ManagedIdentity,

        /// <summary>
        /// Authenticate in a development environment with the Azure CLI.
        /// See https://docs.microsoft.com/dotnet/api/azure.identity.azureclicredential
        /// </summary>
        CLI,

        /// <summary>
        /// Authenticate using tokens in the local cache shared between Microsoft applications.
        /// See: https://docs.microsoft.com/dotnet/api/azure.identity.sharedtokencachecredential
        /// </summary>
        SharedToken,

        /// <summary>
        /// Authenticate using data from Visual Studio.
        /// See: https://docs.microsoft.com/dotnet/api/azure.identity.visualstudiocredential
        /// </summary>
        VisualStudio,

        /// <summary>
        /// Authenticate in a development environment with Visual Studio Code.
        /// See: https://docs.microsoft.com/dotnet/api/azure.identity.visualstudiocodecredential
        /// </summary>
        VisualStudioCode,

        /// <summary>
        /// A TokenCredential implementation which launches the system default browser to interactively authenticate a user,
        /// and obtain an access token. The browser will only be launched to authenticate the user once,
        /// then will silently acquire access tokens through the users refresh token as long as it's valid.
        /// See: https://docs.microsoft.com/dotnet/api/azure.identity.interactivebrowsercredential
        /// </summary>
        Interactive,

        /// <summary>
        /// A TokenCredential implementation which authenticates a user using the device code flow,
        /// and provides access tokens for that user account. 
        /// See: https://docs.microsoft.com/dotnet/api/azure.identity.devicecodecredential
        /// </summary>
        DeviceCode,
    }

    public static class CredentialFactory
    {
        // Used to fetch the tenantId automatically from ARM
        private static readonly HttpClient Client = new HttpClient();

        // Used to catch all the TenantIds:
        private static readonly Dictionary<string, string?> TenantIds = new Dictionary<string, string?>();

        public static TokenCredential CreateCredential(CredentialType credentialType, string? subscriptionId = null) => credentialType switch
        {
            CredentialType.Default => CreateDefaultCredential(),
            CredentialType.Environment => new EnvironmentCredential(),
            CredentialType.ManagedIdentity => new ManagedIdentityCredential(),
            CredentialType.CLI => new AzureCliCredential(),
            CredentialType.DeviceCode => new DeviceCodeCredential(options: DeviceCodeOptions(subscriptionId)),
            CredentialType.SharedToken => new SharedTokenCacheCredential(options: SharedTokenOptions(subscriptionId)),
            CredentialType.VisualStudio => new VisualStudioCredential(options: VisualStudioOptions(subscriptionId)),
            CredentialType.VisualStudioCode => new VisualStudioCodeCredential(options: VisualStudioCodeOptions(subscriptionId)),
            CredentialType.Interactive => new InteractiveBrowserCredential(options: InteractiveOptions(subscriptionId)),
            _ => throw new ArgumentException($"Credentials of type {credentialType} are not supported.")
        };

        /// <summary>
        /// Returns an InteractiveBrowserCredentialOptions, populated with the TenantId for the given subscription.
        /// </summary>
        /// <param name="subscriptionid">An subscription Id.</param>
        /// <returns>A new instance of InteractiveBrowserCredentialOptions with the TenantId populated</returns>
        public static InteractiveBrowserCredentialOptions InteractiveOptions(string? subscriptionid) =>
            new InteractiveBrowserCredentialOptions
            {
                TenantId = GetTenantId(subscriptionid),
            };

        /// <summary>
        /// Returns an VisualStudioCodeCredentialOptions, populated with the TenantId for the given subscription.
        /// </summary>
        /// <param name="subscriptionid">An subscription Id.</param>
        /// <returns>A new instance of InteractiveBrowserCredentialOptions with the TenantId populated</returns>
        public static VisualStudioCodeCredentialOptions VisualStudioCodeOptions(string? subscriptionid) =>
            new VisualStudioCodeCredentialOptions
            {
                TenantId = GetTenantId(subscriptionid),
            };

        /// <summary>
        /// Returns an VisualStudioCredentialOptions, populated with the TenantId for the given subscription.
        /// </summary>
        /// <param name="subscriptionid">An subscription Id.</param>
        /// <returns>A new instance of InteractiveBrowserCredentialOptions with the TenantId populated</returns>
        public static VisualStudioCredentialOptions VisualStudioOptions(string? subscriptionid) =>
            new VisualStudioCredentialOptions
            {
                TenantId = GetTenantId(subscriptionid),
            };

        /// <summary>
        /// Returns an SharedTokenCacheCredentialOptions, populated with the TenantId for the given subscription.
        /// </summary>
        /// <param name="subscriptionid">An subscription Id.</param>
        /// <returns>A new instance of InteractiveBrowserCredentialOptions with the TenantId populated</returns>
        public static SharedTokenCacheCredentialOptions SharedTokenOptions(string? subscriptionid) =>
            new SharedTokenCacheCredentialOptions
            {
                TenantId = GetTenantId(subscriptionid),
            };

        /// <summary>
        /// Returns an VisualStudioCodeCredentialOptions, populated with the TenantId for the given subscription.
        /// </summary>
        /// <param name="subscriptionid">An subscription Id.</param>
        /// <returns>A new instance of InteractiveBrowserCredentialOptions with the TenantId populated</returns>
        public static DeviceCodeCredentialOptions DeviceCodeOptions(string? subscriptionid) =>
            new DeviceCodeCredentialOptions
            {
                TenantId = GetTenantId(subscriptionid),
            };

        /// <summary>
        /// This gnarly piece of code is how we get the guest tenant
        /// authority associated with the subscription.
        /// We make a unauthenticated request to ARM and extract the tenant
        /// authority from the WWW-Authenticate header in the response.
        /// </summary>
        /// <param name="subscriptionId">The subscriptionId.</param>
        /// <returns>The tenantId for the given subscription; null if it can be found or for a null subscription.</returns>
        public static string? GetTenantId(string? subscriptionId)
        {
            if (subscriptionId == null)
            {
                return null;
            }

            if (TenantIds.TryGetValue(subscriptionId, out string? tenantId))
            {
                return tenantId;
            }

            try
            {
                string url = $"https://management.azure.com/subscriptions/{subscriptionId}?api-version=2020-01-01";
                HttpResponseMessage response = Client.GetAsync(url).Result;
                var header = response
                    .Headers
                    .WwwAuthenticate
                    .FirstOrDefault(v => v.Scheme == "Bearer")
                    ?.Parameter;

                tenantId = ExtractTenantIdFromBearer(header);
                TenantIds[subscriptionId] = tenantId;

                return tenantId;
            }
            catch
            {
                return null;
            }
        }

        /// <summary>
        /// Here we parse WWW-Authenticate header in the response to match the tenant id.
        /// The header is of the form:
        /// <code>Bearer authorization_uri="https://login.microsoftonline.com/tenantId",key1=value1s,etc...</code>
        /// </summary>
        /// <param name="bearer">The value of the Bearer in the WWWAuthenticate header</param>
        /// <returns>The tenant-id, or null if it can't find it.</returns>
        public static string? ExtractTenantIdFromBearer(string? bearer)
        {
            if (bearer == null)
            {
                return null;
            }

            // Split the key=value comma seperated list and look for the "authorization_uri" key:
            var auth_uri = bearer
                .Split(',')
                .Select(kv => kv.Split('=', 2))
                .FirstOrDefault(pair => pair[0] == "authorization_uri")?[1];

            // If found an authorization_uri, find the tenant id from a URL surrounded by quotes, i.e.:
            // "https://login.microsoftonline.com/tenantId"
            if (auth_uri != null && auth_uri.StartsWith('"') && auth_uri.EndsWith('"'))
            {
                var id = auth_uri
                    [1 .. ^1]
                    [auth_uri.LastIndexOf('/') .. ];

                return id;
            }
            else
            {
                return null;
            }
        }

        /// <summary>
        /// Generates the credential to use by default. It checks
        /// </summary>
        /// <param name="subscriptionId">Th</param>
        /// <returns>A ChainedTokenCredential with all the default credential types to use.</returns>
        public static TokenCredential CreateDefaultCredential(string? subscriptionId = null)
        {
            var sources = new List<TokenCredential>
            {
                CreateCredential(CredentialType.Environment, subscriptionId),
                CreateCredential(CredentialType.ManagedIdentity, subscriptionId),
                CreateCredential(CredentialType.CLI, subscriptionId),
                CreateCredential(CredentialType.SharedToken, subscriptionId),
                CreateCredential(CredentialType.VisualStudio, subscriptionId),
                CreateCredential(CredentialType.VisualStudioCode, subscriptionId),
                CreateCredential(CredentialType.Interactive, subscriptionId),
                CreateCredential(CredentialType.DeviceCode, subscriptionId),
            };

            return new ChainedTokenCredential(sources.ToArray());
        }
    }
}
