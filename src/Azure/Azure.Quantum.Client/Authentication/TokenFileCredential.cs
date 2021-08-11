// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#nullable enable

namespace Microsoft.Azure.Quantum.Authentication
{
    using System;
    using System.Text.Json;
    using System.Threading;
    using System.Threading.Tasks;

    using global::Azure.Core;
    using global::Azure.Identity;
    using Microsoft.Azure.Quantum.Utility;

    public class TokenFileCredential : TokenCredential
    {
        private const string TokenFileEnvironmentVariable = "AZUREQUANTUM_TOKEN_FILE";
        private readonly IFileSystem _fileSystem;
        private readonly string? _tokenFilePath;

        public TokenFileCredential()
            : this(new FileSystem())
        {
        }

        public TokenFileCredential(IFileSystem fileSystem)
        {
            _fileSystem = fileSystem;
            _tokenFilePath = Environment.GetEnvironmentVariable(TokenFileEnvironmentVariable);
        }

        public override AccessToken GetToken(TokenRequestContext requestContext, CancellationToken cancellationToken)
            => GetTokenImplAsync(false, requestContext, cancellationToken).GetAwaiter().GetResult();

        public override async ValueTask<AccessToken> GetTokenAsync(TokenRequestContext requestContext, CancellationToken cancellationToken)
            => await GetTokenImplAsync(true, requestContext, cancellationToken).ConfigureAwait(false);

        private async ValueTask<AccessToken> GetTokenImplAsync(bool async, TokenRequestContext requestContext, CancellationToken cancellationToken)
        {
            AccessToken token;

            if (string.IsNullOrWhiteSpace(_tokenFilePath))
            {
                throw new CredentialUnavailableException("Token file location not set.");
            }

            if (!_fileSystem.FileExists(_tokenFilePath))
            {
                throw new CredentialUnavailableException($"Token file at {_tokenFilePath} does not exist.");
            }

            try
            {
                token = await ParseTokenFile(async, _tokenFilePath, cancellationToken);
            }
            catch (JsonException)
            {
                throw new CredentialUnavailableException("Failed to parse token file: Invalid JSON.");
            }
            catch (MissingFieldException ex)
            {
                throw new CredentialUnavailableException($"Failed to parse token file: Missing expected value: '{ex.Message}'");
            }
            catch (Exception ex)
            {
                throw new CredentialUnavailableException($"Failed to parse token file: {ex.Message}");
            }

            if (token.ExpiresOn <= DateTimeOffset.UtcNow)
            {
                throw new CredentialUnavailableException($"Token already expired at {token.ExpiresOn:u}");
            }

            return token;
        }

        private async ValueTask<AccessToken> ParseTokenFile(bool async, string tokenFilePath, CancellationToken cancellationToken)
        {
            var data = async ? await _fileSystem.GetFileContentAsync<TokenFileContent>(tokenFilePath, cancellationToken) :
                _fileSystem.GetFileContent<TokenFileContent>(tokenFilePath);

            if (string.IsNullOrEmpty(data.AccessToken))
            {
                throw new MissingFieldException("access_token");
            }

            if (data.ExpiresOn == 0)
            {
                throw new MissingFieldException("expires_on");
            }

            DateTimeOffset expiresOn = DateTimeOffset.FromUnixTimeMilliseconds(data.ExpiresOn);
            return new AccessToken(data.AccessToken, expiresOn);
        }
    }
}