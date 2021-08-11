// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#nullable enable

namespace Microsoft.Azure.Quantum.Authentication
{
    using System.Text.Json.Serialization;

    /// <summary>
    /// Contract for the contents of the token file used in TokenFileCredential.
    /// </summary>
    public class TokenFileContent
    {
        /// <summary>
        /// The access token.
        /// </summary>
        [JsonPropertyName("access_token")]
        public string? AccessToken { get; set; }

        /// <summary>
        /// The expiry time of the token in milliseconds since epoch.
        /// </summary>
        [JsonPropertyName("expires_on")]
        public long ExpiresOn { get; set; }
    }
}
