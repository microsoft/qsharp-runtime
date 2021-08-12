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

    /// <summary>
    /// Implements a custom TokenCredential to use a local file as the source for an AzureQuantum token.
    ///
    /// It will only use the local file if the AZUREQUANTUM_TOKEN_FILE environment variable is set, and references
    /// an existing json file that contains the access_token and expires_on timestamp in milliseconds.
    ///
    /// If the environment variable is not set, the file does not exist, or the token is invalid in any way(expired, for example),
    /// then the credential will throw CredentialUnavailableError, so that DefaultQuantumCredential can fallback to other methods.
    /// </summary>
    public class TokenFileCredential : TokenCredential
    {
        /// <summary>
        /// Environment variable name for the token file path.
        /// </summary>
        private const string TokenFileEnvironmentVariable = "AZUREQUANTUM_TOKEN_FILE";

        /// <summary>
        /// File system dependency injected so that unit testing is possible.
        /// </summary>
        private readonly IFileSystem _fileSystem;

        /// <summary>
        /// The path to the token file.
        /// </summary>
        private readonly string? _tokenFilePath;

        /// <summary>
        /// Initializes a new instance of the <see cref="TokenFileCredential"/> class.
        /// </summary>
        /// <param name="fileSystem">The file system.</param>
        public TokenFileCredential(IFileSystem? fileSystem = null)
        {
            _fileSystem = fileSystem ?? new FileSystem();
            _tokenFilePath = Environment.GetEnvironmentVariable(TokenFileEnvironmentVariable);
        }

        /// <summary>
        /// Attempts to acquire an <see cref="AccessToken"/> synchronously from a local token file.
        /// </summary>
        /// <param name="requestContext">The details of the authentication request.</param>
        /// <param name="cancellationToken">A <see cref="CancellationToken"/> controlling the request lifetime.</param>
        /// <returns>The <see cref="AccessToken"/> found in the token file.</returns>
        /// <exception cref="CredentialUnavailableException">When token is not found or valid.</exception>
        public override AccessToken GetToken(TokenRequestContext requestContext, CancellationToken cancellationToken)
            => GetTokenImplAsync(false, requestContext, cancellationToken).GetAwaiter().GetResult();

        /// <summary>
        /// Attempts to acquire an <see cref="AccessToken"/> asynchronously from a local token file.
        /// </summary>
        /// <param name="requestContext">The details of the authentication request.</param>
        /// <param name="cancellationToken">A <see cref="CancellationToken"/> controlling the request lifetime.</param>
        /// <returns>The <see cref="AccessToken"/> found in the token file.</returns>
        /// <exception cref="CredentialUnavailableException">When token is not found or valid.</exception>
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