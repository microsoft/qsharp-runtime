// <copyright file="IAccessTokenProvider.cs" company="Microsoft Corporation">
// Copyright (c) Microsoft Corporation. All rights reserved.
// </copyright>

using System.Threading;
using System.Threading.Tasks;

namespace Microsoft.Azure.Quantum.Authentication
{
    /// <summary>
    /// Generic interface to retrieve access token. This is not exposed to the user.
    /// </summary>
    internal interface IAccessTokenProvider
    {
        /// <summary>
        /// Gets the access token.
        /// </summary>
        /// <param name="cancellationToken">The cancellation token.</param>
        /// <returns>Access token string</returns>
        Task<string> GetAccessTokenAsync(CancellationToken cancellationToken);
    }
}
