// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System.Linq;
using System.Net.Http;
using System.Security.Authentication;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Azure.Quantum.Utility;
using Microsoft.Identity.Client;
using Microsoft.Identity.Client.Extensions.Msal;

namespace Microsoft.Azure.Quantum.Authentication
{
    /// <summary>
    /// This class manually uses MSAL to get an access token.
    /// It first tries to get silently, if that doesn't work, it tries to get interactively.
    /// </summary>
    /// <seealso cref="Microsoft.Azure.Quantum.Client.Security.IAccessTokenProvider" />
    internal class CustomAccessTokenProvider : IAccessTokenProvider
    {
        private readonly LazyAsync<IPublicClientApplication> applicationLazy;
        private readonly string[] scopes;
        private readonly string subscriptionId;

        /// <summary>
        /// Initializes a new instance of the <see cref="CustomAccessTokenProvider"/> class.
        /// </summary>
        /// <param name="subscriptionId">The Subscription Id of the account in use.</param>
        public CustomAccessTokenProvider(string subscriptionId)
        {
            static async Task<string> GetSubscriptionTenantUri(string subscriptionId)
            {
                var uri = $"https://management.azure.com/subscriptions/{subscriptionId}?api-version=2018-01-01";
                try
                {
                    static string GetTenantUriFromHeader(System.Net.Http.Headers.AuthenticationHeaderValue header) =>
                        header
                            .Parameter
                            .Replace("Bearer ", string.Empty)
                            .Split(",")
                            .Select(part => part.Split("="))
                            .ToDictionary(rg => rg[0], rg => rg[1])["authorization_uri"]
                            .Trim('\'', '"');

                    using var client = new HttpClient();
                    var httpResult = await client.GetAsync(uri);

                    return httpResult
                        .Headers
                        .WwwAuthenticate
                        .Select(GetTenantUriFromHeader)
                        .Single();
                }
                catch (System.Exception ex)
                {
                    throw new AuthenticationException("Unable to extract tenantUri!", ex);
                }
            }

            this.scopes = new string[] { Constants.Aad.Audience };
            this.subscriptionId = subscriptionId;
            this.applicationLazy =
                new LazyAsync<IPublicClientApplication>(async () =>
                {
                    var application = PublicClientApplicationBuilder
                        .Create(Constants.Aad.ApplicationId)
                        .WithDefaultRedirectUri()
                        .WithAuthority(await GetSubscriptionTenantUri(subscriptionId))
                        .Build();
                    var cacheHelper = await CreateCacheHelperAsync();
                    cacheHelper.RegisterCache(application.UserTokenCache);
                    return application;
                });
        }

        /// <summary>
        /// Tries to get access token silently, if didn't work, tries to get it interactively.
        /// </summary>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>A <see cref="Task"/> encapsulating the access token.</returns>
        public async Task<string> GetAccessTokenAsync(CancellationToken cancellationToken)
        {
            var application = applicationLazy.Value;

            try
            {
                var accounts = await application.GetAccountsAsync();

                // Try silently first
                var result = await application
                    .AcquireTokenSilent(scopes, accounts.FirstOrDefault())
                    .ExecuteAsync();

                return result.AccessToken;
            }
            catch (MsalUiRequiredException)
            {
                // Didn't work, perform interactive logging
                var result = await application
                    .AcquireTokenInteractive(scopes)
                    .ExecuteAsync();

                return result.AccessToken;
            }
        }

        private static async Task<MsalCacheHelper> CreateCacheHelperAsync()
        {
            StorageCreationProperties storageProperties;

            storageProperties = new StorageCreationPropertiesBuilder(
                Constants.Aad.CacheFileName,
                MsalCacheHelper.UserRootDirectory,
                Constants.Aad.ApplicationId)
            .WithMacKeyChain(
                Constants.Aad.KeyChainServiceName,
                Constants.Aad.KeyChainAccountName)
            .Build();

            var cacheHelper = await MsalCacheHelper.CreateAsync(storageProperties).ConfigureAwait(false);

            cacheHelper.VerifyPersistence();
            return cacheHelper;
        }
    }
}