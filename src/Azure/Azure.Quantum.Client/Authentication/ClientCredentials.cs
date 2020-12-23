// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Rest;

namespace Microsoft.Azure.Quantum.Authentication
{
    /// <summary>
    /// Authorization client handler class.
    /// </summary>
    internal class ClientCredentials : ServiceClientCredentials
    {
        private const string AuthorizationHeaderName = "Authorization";
        private const string BearerScheme = "Bearer";

        private readonly IAccessTokenProvider accessTokenProvider;

        /// <summary>
        /// Initializes a new instance of the <see cref="ClientCredentials"/> class.
        /// </summary>
        /// <param name="accessTokenProvider">The access token provider.</param>
        public ClientCredentials(IAccessTokenProvider accessTokenProvider)
        {
            this.accessTokenProvider = accessTokenProvider;
        }

        public override async Task ProcessHttpRequestAsync(HttpRequestMessage request, CancellationToken cancellationToken)
        {
            if (request == null)
            {
                throw new ArgumentNullException("request");
            }

            if (!request.Headers.Contains(AuthorizationHeaderName))
            {
                string accessToken = await this.accessTokenProvider.GetAccessTokenAsync(cancellationToken);
                request.Headers.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue(BearerScheme, accessToken);
            }

            //request.Version = new Version(apiVersion);
            await base.ProcessHttpRequestAsync(request, cancellationToken);
        }
    }
}
