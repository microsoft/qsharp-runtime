// <copyright file="AuthorizationClientHandler.cs" company="Microsoft Corporation">
// Copyright (c) Microsoft Corporation. All rights reserved.
// </copyright>

using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;

namespace Microsoft.Azure.Quantum.Authentication
{
    /// <summary>
    /// Authorization client handler class.
    /// </summary>
    internal class AuthorizationClientHandler : HttpClientHandler
    {
        private const string AuthorizationHeaderName = "Authorization";
        private const string BearerScheme = "Bearer";

        private readonly IAccessTokenProvider accessTokenProvider;

        /// <summary>
        /// Initializes a new instance of the <see cref="AuthorizationClientHandler"/> class.
        /// </summary>
        /// <param name="accessTokenProvider">The access token provider.</param>
        public AuthorizationClientHandler(IAccessTokenProvider accessTokenProvider)
        {
            this.accessTokenProvider = accessTokenProvider;
        }

        /// <summary>
        /// Creates an instance of  <see cref="T:System.Net.Http.HttpResponseMessage" /> based on the information provided in the <see cref="T:System.Net.Http.HttpRequestMessage" /> as an operation that will not block.
        /// </summary>
        /// <param name="request">The HTTP request message.</param>
        /// <param name="cancellationToken">A cancellation token to cancel the operation.</param>
        /// <returns>
        /// The task object representing the asynchronous operation.
        /// </returns>
        protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
        {
            if (!request.Headers.Contains(AuthorizationHeaderName))
            {
                string accessToken = await this.accessTokenProvider.GetAccessTokenAsync(cancellationToken);
                request.Headers.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue(BearerScheme, accessToken);
            }

            return await base.SendAsync(request, cancellationToken);
        }
    }
}
