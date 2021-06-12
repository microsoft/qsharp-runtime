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
        // Used to fetch the tenantId automatically from ARM
        private static readonly HttpClient Client = new HttpClient();

        // Used to catch all the TenantIds:
        private static readonly Dictionary<string, string?> TenantIds = new Dictionary<string, string?>();

        public static TokenCredential CreateCredential(CredentialType credentialType, string? subscriptionId = null) => credentialType switch
        {
            CredentialType.SharedToken => CreateCredential(credentialType, () => SharedTokenOptions(subscriptionId)),
            CredentialType.VisualStudio => CreateCredential(credentialType, () => VisualStudioOptions(subscriptionId)),
            CredentialType.VisualStudioCode => CreateCredential(credentialType, () => VisualStudioCodeOptions(subscriptionId)),
            CredentialType.Interactive => CreateCredential(credentialType, () => InteractiveOptions(subscriptionId)),
            CredentialType.Default => CreateCredential(credentialType, () => DefaultOptions(subscriptionId)),
            _ => CreateCredential(credentialType, () => DefaultOptions(subscriptionId)),
        };

        /// <summary>
        /// Creates an instance of TokenCredential that corresponds to the given <see cref="CredentialType"/>.
        /// It creates an instance of the Credential Class with default parameters.
        /// </summary>
        /// <param name="credentialType">The type of Credential Class to create.</param>
        /// <param name="options">A configuration method for the corresponding credential options (not used for Environment, ManagedIdentity or CLI credentials).</param>
        /// <returns>An instance of TokenCredential for the corresponding value.</returns>
        public static TokenCredential CreateCredential(CredentialType credentialType, Func<TokenCredentialOptions> options) => credentialType switch
        {
            CredentialType.Environment => new EnvironmentCredential(),
            CredentialType.ManagedIdentity => new ManagedIdentityCredential(),
            CredentialType.CLI => new AzureCliCredential(),
            CredentialType.SharedToken => new SharedTokenCacheCredential(options: options?.Invoke() as SharedTokenCacheCredentialOptions),
            CredentialType.VisualStudio => new VisualStudioCredential(options: options?.Invoke() as VisualStudioCredentialOptions),
            CredentialType.VisualStudioCode => new VisualStudioCodeCredential(options: options?.Invoke() as VisualStudioCodeCredentialOptions),
            CredentialType.Interactive => new InteractiveBrowserCredential(options: options?.Invoke() as InteractiveBrowserCredentialOptions),
            CredentialType.Default => new DefaultAzureCredential(options: options?.Invoke() as DefaultAzureCredentialOptions),
            _ => throw new ArgumentException($"Credentials of type {credentialType} are not supported.")
        };

        /// <summary>
        /// Returns an DefaultAzureCredentialOptions, populated with the TenantId for the given subscription.
        /// We als disabilitate VisualStudio credentials, since they don't currently work with Azure Quantum.
        /// </summary>
        /// <param name="subscriptionid">An subscription Id.</param>
        /// <returns>A new instance of InteractiveBrowserCredentialOptions with the TenantId populated</returns>
        public static DefaultAzureCredentialOptions DefaultOptions(string? subscriptionid)
        {
            string? tenantId = GetTenantId(subscriptionid);

            return new DefaultAzureCredentialOptions
            {
                // Disable VS credentials until https://devdiv.visualstudio.com/DevDiv/_workitems/edit/1332071 is fixed:
                ExcludeVisualStudioCredential = true,
                ExcludeInteractiveBrowserCredential = false,

                InteractiveBrowserTenantId = tenantId,
                SharedTokenCacheTenantId = tenantId,
                VisualStudioCodeTenantId = tenantId,
                VisualStudioTenantId = tenantId,
            };
        }

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
    }
}
