// <copyright file="MockHelper.cs" company="Microsoft Corporation">
// Copyright (c) Microsoft Corporation. All rights reserved.
// </copyright>

using System.Collections.Generic;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;

using Microsoft.Azure.Quantum.Client;

using Moq;
using Moq.Protected;

namespace Microsoft.Azure.Quantum.Test
{
    public class MockHelper
    {
        internal List<HttpRequestMessage> RequestMessages { get; private set; } = new List<HttpRequestMessage>();

        internal HttpResponseMessage ResponseMessage { get; set; }

        public HttpClient GetHttpClientMock()
        {
            Mock<HttpMessageHandler> mock = new Mock<HttpMessageHandler>();

            mock.Protected()
                .Setup<Task<HttpResponseMessage>>("SendAsync", ItExpr.IsAny<HttpRequestMessage>(), ItExpr.IsAny<CancellationToken>())
                .Returns((HttpRequestMessage request, CancellationToken token) =>
                {
                    RequestMessages.Add(request);

                    if (request.Method == HttpMethod.Delete)
                    {
                        return Task.FromResult(new HttpResponseMessage(System.Net.HttpStatusCode.NoContent));
                    }

                    return Task.FromResult(ResponseMessage);
                });

            return new HttpClient(mock.Object);
        }

        public class MockQuantumClient : QuantumClient
        {
            public MockQuantumClient(MockHelper mock)
                : base(mock.GetHttpClientMock(), true)
            {
            }
        }
    }
}
