// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#nullable enable

namespace Microsoft.Azure.Quantum.Authentication
{
    using System.Text.Json.Serialization;

    public class TokenFileContent
    {
        [JsonPropertyName("access_token")]
        public string? AccessToken { get; set; }

        [JsonPropertyName("expires_on")]
        public long ExpiresOn { get; set; }
    }
}
