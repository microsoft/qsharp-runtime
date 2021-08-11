using System;
using System.IO;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Azure.Core;
using Azure.Identity;
using Microsoft.Azure.Quantum.Utility;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Microsoft.Azure.Quantum.Authentication.Test
{
    public class FileSystemTestImpl : IFileSystem
    {
        private readonly string _fileContent;

        public FileSystemTestImpl(string content = null)
        {
            _fileContent = content;
        }

        public bool FileExists(string path)
        {
            return _fileContent != null;
        }

        public T GetFileContent<T>(string path)
        {
            return JsonSerializer.Deserialize<T>(_fileContent);
        }

        public async Task<T> GetFileContentAsync<T>(string path, CancellationToken cancellationToken)
        {
            using var stream = new MemoryStream(Encoding.UTF8.GetBytes(_fileContent));
            return await JsonSerializer.DeserializeAsync<T>(stream, null, cancellationToken);
        }
    }

    [TestClass]
    public class TokenFileCredentialTests
    {
        private const string _azureQuantumScope = "https://quantum.microsoft.com/.default";
        private const string _tokenFilePath = "/fake/filepath";

        [TestInitialize]
        public void TestInitialize()
        {
            Environment.SetEnvironmentVariable("AZUREQUANTUM_TOKEN_FILE", _tokenFilePath);
        }

        [TestCleanup]
        public void TestCleanup()
        {
            Environment.SetEnvironmentVariable("AZUREQUANTUM_TOKEN_FILE", null);
        }

        [TestMethod]
        public void Test_WhenFileNotSet_Throws_CredentialUnavailableException()
        {
            Environment.SetEnvironmentVariable("AZUREQUANTUM_TOKEN_FILE", null);
            var credential = new TokenFileCredential();

            var exception = Assert.ThrowsException<CredentialUnavailableException>(() =>
                credential.GetToken(new TokenRequestContext(new string[] { _azureQuantumScope }), CancellationToken.None));

            Assert.AreEqual("Token file location not set.", exception.Message);
        }

        [TestMethod]
        public void Test_WhenFileNotExists_Throws_CredentialUnavailableException()
        {
            var credential = new TokenFileCredential();
            var exception = Assert.ThrowsException<CredentialUnavailableException>(() =>
                credential.GetToken(new TokenRequestContext(new string[] { _azureQuantumScope }), CancellationToken.None));

            Assert.AreEqual($"Token file at {_tokenFilePath} does not exist.", exception.Message);
        }

        [TestMethod]
        public void Test_WhenInvalidJson_Throws_CredentialUnavailableException()
        {
            string notJson = "invalid json";
            var credential = new TokenFileCredential(new FileSystemTestImpl(notJson));
            var exception = Assert.ThrowsException<CredentialUnavailableException>(() =>
                credential.GetToken(new TokenRequestContext(new string[] { _azureQuantumScope }), CancellationToken.None));

            Assert.AreEqual("Failed to parse token file: Invalid JSON.", exception.Message);
        }

        [TestMethod]
        public void Test_WhenExpiredToken_Throws_CredentialUnavailableException()
        {
            string content = @"{
              ""access_token"": ""fake_token"",
              ""expires_on"": 1628543125086
            }";

            var credential = new TokenFileCredential(new FileSystemTestImpl(content));
            var exception = Assert.ThrowsException<CredentialUnavailableException>(() =>
                credential.GetToken(new TokenRequestContext(new string[] { _azureQuantumScope }), CancellationToken.None));

            Assert.AreEqual("Token already expired at 2021-08-09 21:05:25Z", exception.Message);
        }

        [TestMethod]
        public void Test_WhenMissingAccessTokenField_Throws_CredentialUnavailableException()
        {
            string content = @"{
              ""expires_on"": 1628543125086
            }";

            var credential = new TokenFileCredential(new FileSystemTestImpl(content));
            var exception = Assert.ThrowsException<CredentialUnavailableException>(() =>
                credential.GetToken(new TokenRequestContext(new string[] { _azureQuantumScope }), CancellationToken.None));

            Assert.AreEqual("Failed to parse token file: Missing expected value: 'access_token'", exception.Message);
        }

        [TestMethod]
        public void Test_WhenMissingExpiresOnField_Throws_CredentialUnavailableException()
        {
            string content = @"{
              ""access_token"": ""fake_token""
            }";

            var credential = new TokenFileCredential(new FileSystemTestImpl(content));
            var exception = Assert.ThrowsException<CredentialUnavailableException>(() =>
                credential.GetToken(new TokenRequestContext(new string[] { _azureQuantumScope }), CancellationToken.None));

            Assert.AreEqual("Failed to parse token file: Missing expected value: 'expires_on'", exception.Message);
        }

        [TestMethod]
        public async Task Test_WhenTokenIsValid_Returns_AccessToken()
        {
            var expiresOn = DateTimeOffset.UtcNow.AddHours(1);
            string content = $@"{{
              ""access_token"": ""fake_token"",
              ""expires_on"": {expiresOn.ToUnixTimeMilliseconds()}
            }}";

            var credential = new TokenFileCredential(new FileSystemTestImpl(content));
            var token = await credential.GetTokenAsync(new TokenRequestContext(new string[] { _azureQuantumScope }), CancellationToken.None);

            Assert.AreEqual("fake_token", token.Token);
            Assert.AreEqual(expiresOn.ToUnixTimeMilliseconds(), token.ExpiresOn.ToUnixTimeMilliseconds());
        }
    }
}
