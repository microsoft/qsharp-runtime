// <copyright file="TokenCredentialProvider.cs" company="Microsoft Corporation">
// Copyright (c) Microsoft Corporation. All rights reserved.
// </copyright>

using System.Threading;
using System.Threading.Tasks;
using Azure.Core;
using Microsoft.Azure.Quantum.Utility;

namespace Microsoft.Azure.Quantum.Authentication
{
    /// <summary>
    /// A provider for TokenCredential
    /// </summary>
    /// <seealso cref="Microsoft.Azure.Quantum.Client.Security.IAccessTokenProvider" />
    internal class TokenCredentialProvider : IAccessTokenProvider
    {
        private readonly TokenCredential tokenCredential;
        private readonly string[] scopes;

        /// <summary>
        /// Initializes a new instance of the <see cref="TokenCredentialProvider"/> class.
        /// </summary>
        /// <param name="tokenCredential">The token credential.</param>
        public TokenCredentialProvider(TokenCredential tokenCredential)
        {
            this.tokenCredential = tokenCredential;
            this.scopes = new string[] { Constants.Aad.Audience };
        }

        /// <summary>
        /// Gets the access token.
        /// </summary>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>
        /// Access token string
        /// </returns>
        public async Task<string> GetAccessTokenAsync(CancellationToken cancellationToken)
        {
            AccessToken accessToken = await this.tokenCredential.GetTokenAsync(new TokenRequestContext(this.scopes), cancellationToken);
            return accessToken.Token;
        }
    }
}
