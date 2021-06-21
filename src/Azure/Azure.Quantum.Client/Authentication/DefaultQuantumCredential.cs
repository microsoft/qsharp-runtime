// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#nullable enable

namespace Microsoft.Azure.Quantum.Authentication
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Threading;
    using System.Threading.Tasks;

    using global::Azure.Core;
    using global::Azure.Core.Pipeline;
    using global::Azure.Identity;

    /// <summary>
    /// Provides a <see cref="TokenCredential"/> implementation which chains multiple <see cref="TokenCredential"/> implementations to be tried in order
    /// until one of the getToken methods returns a non-default <see cref="AccessToken"/>.
    /// </summary>
    /// <example>
    /// <para>
    /// The ChainedTokenCredential class provides the ability to link together multiple credential instances to be tried sequentially when authenticating.
    /// The following example demonstrates creating a credential which will attempt to authenticate using managed identity, and fall back to Azure CLI for authentication
    /// if a managed identity is unavailable in the current environment.
    /// </para>
    /// <code snippet="Snippet:CustomChainedTokenCredential">
    /// // Authenticate using managed identity if it is available; otherwise use the Azure CLI to authenticate.
    ///
    /// var credential = new ChainedTokenCredential(new ManagedIdentityCredential(), new AzureCliCredential());
    ///
    /// var eventHubProducerClient = new EventHubProducerClient(&quot;myeventhub.eventhubs.windows.net&quot;, &quot;myhubpath&quot;, credential);
    /// </code>
    /// </example>
    public class DefaultQuantumCredential : TokenCredential
    {
        private const string AggregateAllUnavailableErrorMessage = "Failed to retrieve a token from the included credentials.";

        private const string AuthenticationFailedErrorMessage = "The ChainedTokenCredential failed due to an unhandled exception: ";

        /// <summary>
        /// Initializes a new instance of the <see cref="DefaultQuantumCredential"/> class.
        /// </summary>
        public DefaultQuantumCredential(string? subscriptionId = null)
        {
            this.SubscriptionId = subscriptionId;
        }

        public string? SubscriptionId { get; }

        /// <summary>
        /// Generates the credential to use by default. It checks
        /// </summary>
        /// <param name="subscriptionId">Th</param>
        /// <returns>A ChainedTokenCredential with all the default credential types to use.</returns>
        public IEnumerable<TokenCredential> Sources
        {
            get
            {
                yield return CredentialFactory.CreateCredential(CredentialType.Environment, SubscriptionId);
                yield return CredentialFactory.CreateCredential(CredentialType.ManagedIdentity, SubscriptionId);
                yield return CredentialFactory.CreateCredential(CredentialType.CLI, SubscriptionId);
                yield return CredentialFactory.CreateCredential(CredentialType.SharedToken, SubscriptionId);
                yield return CredentialFactory.CreateCredential(CredentialType.VisualStudio, SubscriptionId);
                yield return CredentialFactory.CreateCredential(CredentialType.VisualStudioCode, SubscriptionId);
                yield return CredentialFactory.CreateCredential(CredentialType.Interactive, SubscriptionId);
                yield return CredentialFactory.CreateCredential(CredentialType.DeviceCode, SubscriptionId);
            }
        }

        /// <summary>
        /// Sequentially calls <see cref="TokenCredential.GetToken"/> on all the specified sources, returning the first successfully obtained <see cref="AccessToken"/>. This method is called automatically by Azure SDK client libraries. You may call this method directly, but you must also handle token caching and token refreshing.
        /// </summary>
        /// <param name="requestContext">The details of the authentication request.</param>
        /// <param name="cancellationToken">A <see cref="CancellationToken"/> controlling the request lifetime.</param>
        /// <returns>The first <see cref="AccessToken"/> returned by the specified sources. Any credential which raises a <see cref="CredentialUnavailableException"/> will be skipped.</returns>
        public override AccessToken GetToken(TokenRequestContext requestContext, CancellationToken cancellationToken = default)
                => GetTokenImplAsync(false, requestContext, cancellationToken).GetAwaiter().GetResult();

        /// <summary>
        /// Sequentially calls <see cref="TokenCredential.GetToken"/> on all the specified sources, returning the first successfully obtained <see cref="AccessToken"/>. This method is called automatically by Azure SDK client libraries. You may call this method directly, but you must also handle token caching and token refreshing.
        /// </summary>
        /// <param name="requestContext">The details of the authentication request.</param>
        /// <param name="cancellationToken">A <see cref="CancellationToken"/> controlling the request lifetime.</param>
        /// <returns>The first <see cref="AccessToken"/> returned by the specified sources. Any credential which raises a <see cref="CredentialUnavailableException"/> will be skipped.</returns>
        public override async ValueTask<AccessToken> GetTokenAsync(TokenRequestContext requestContext, CancellationToken cancellationToken = default)
            => await GetTokenImplAsync(true, requestContext, cancellationToken).ConfigureAwait(false);

        private async ValueTask<AccessToken> GetTokenImplAsync(bool async, TokenRequestContext requestContext, CancellationToken cancellationToken)
        {
            List<Exception> exceptions = new List<Exception>();
            foreach (TokenCredential source in Sources)
            {
                try
                {
                    AccessToken token = async
                        ? await source.GetTokenAsync(requestContext, cancellationToken).ConfigureAwait(false)
                        : source.GetToken(requestContext, cancellationToken);
                    return token;
                }
                catch (Exception e) when (cancellationToken.IsCancellationRequested)
                {
                    throw e;
                }
                catch (Exception e)
                {
                    var msg = $"{source.GetType().Name}: {e.Message}";
                    exceptions.Add(new CredentialUnavailableException(msg, e));
                }
            }

            var reasons = string.Join('\n', exceptions.Select(e => e.Message));

            throw new CredentialUnavailableException(
                $"Unable to authenticate. Failed to acquire a token from the different credentials sources for the following reasons:\n{reasons}",
                new AggregateException(exceptions));
        }
    }
}
