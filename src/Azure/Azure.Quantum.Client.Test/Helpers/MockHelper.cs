// <copyright file="MockHelper.cs" company="Microsoft Corporation">
// Copyright (c) Microsoft Corporation. All rights reserved.
// </copyright>

using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;
using Moq;
using Moq.Protected;

namespace Microsoft.Azure.Quantum.Test
{
    public static class MockHelper
    {
        internal static HttpRequestMessage RequestMessage { get; private set; }

        internal static HttpResponseMessage ResponseMessage { get; set; }

        public static HttpClient GetHttpClientMock()
        {
            Mock<HttpMessageHandler> mock = new Mock<HttpMessageHandler>();

            mock.Protected()
                .Setup<Task<HttpResponseMessage>>("SendAsync", ItExpr.IsAny<HttpRequestMessage>(), ItExpr.IsAny<CancellationToken>())
                .Returns((HttpRequestMessage request, CancellationToken token) =>
                {
                    RequestMessage = request;
                    return Task.FromResult(ResponseMessage);
                });

            return new HttpClient(mock.Object);
        }
    }
}
