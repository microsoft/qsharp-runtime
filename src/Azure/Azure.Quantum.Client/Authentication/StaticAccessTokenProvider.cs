// <copyright file="StaticAccessTokenProvider.cs" company="Microsoft Corporation">
// Copyright (c) Microsoft Corporation. All rights reserved.
// </copyright>

using System.Threading;
using System.Threading.Tasks;
using Microsoft.Azure.Quantum.Utility;

namespace Microsoft.Azure.Quantum.Authentication
{
    /// <summary>
    /// This class accepts an access token string and provides it.
    /// </summary>
    /// <seealso cref="Microsoft.Azure.Quantum.Client.Security.IAccessTokenProvider" />
    internal class StaticAccessTokenProvider : IAccessTokenProvider
    {
        private readonly string accessToken;

        /// <summary>
        /// Initializes a new instance of the <see cref="StaticAccessTokenProvider"/> class.
        /// </summary>
        public StaticAccessTokenProvider(string accessToken)
        {
            Ensure.NotNullOrWhiteSpace(accessToken, nameof(accessToken));

            this.accessToken = accessToken;
        }

        /// <summary>
        /// Returns the static access token.
        /// </summary>
        /// <param name="cancellationToken">The cancellation token.</param>
        public Task<string> GetAccessTokenAsync(CancellationToken cancellationToken)
        {
            return Task.FromResult(this.accessToken);
        }
    }
}
