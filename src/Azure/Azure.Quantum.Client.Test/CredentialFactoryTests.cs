// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#nullable enable

using System;

using Azure.Identity;

using Microsoft.Azure.Quantum.Authentication;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Microsoft.Azure.Quantum.Test
{
    [TestClass]
    public class CredentialFactoryTests
    {
        private const string SUBSCRIPTION = "916dfd6d-030c-4bd9-b579-7bb6d1926e97";

        [DataTestMethod]
        [DataRow(CredentialType.Default, typeof(DefaultQuantumCredential))]
        [DataRow(CredentialType.Environment, typeof(EnvironmentCredential))]
        [DataRow(CredentialType.ManagedIdentity, typeof(ManagedIdentityCredential))]
        [DataRow(CredentialType.CLI, typeof(AzureCliCredential))]
        [DataRow(CredentialType.SharedToken, typeof(SharedTokenCacheCredential))]
        [DataRow(CredentialType.VisualStudio, typeof(VisualStudioCredential))]
        [DataRow(CredentialType.VisualStudioCode, typeof(VisualStudioCodeCredential))]
        [DataRow(CredentialType.Interactive, typeof(InteractiveBrowserCredential))]
        [DataRow(CredentialType.DeviceCode, typeof(DeviceCodeCredential))]
        public void TestCreateCredential(CredentialType credentialType, Type expectedType)
        {
            var actual = CredentialFactory.CreateCredential(credentialType);
            Assert.IsNotNull(actual);
            Assert.AreEqual(expectedType, actual.GetType());

            // Now test with a specific subscription id:
            actual = CredentialFactory.CreateCredential(credentialType, SUBSCRIPTION);
            Assert.IsNotNull(actual);
            Assert.AreEqual(expectedType, actual.GetType());
        }

        [TestMethod]
        public void TestInvalidCredentialType()
        {
            Assert.ThrowsException<ArgumentException>(() => CredentialFactory.CreateCredential((CredentialType)9999));
        }

        [TestMethod]
        public void TestGetTenantId()
        {
            var actual = CredentialFactory.GetTenantId(SUBSCRIPTION);
            Assert.IsNotNull(actual);
            Assert.IsFalse(string.IsNullOrWhiteSpace(actual));

            var actual2 = CredentialFactory.GetTenantId(SUBSCRIPTION);
            Assert.AreEqual(actual, actual2);
        }

        [DataTestMethod]
        [DataRow(null, null)]
        [DataRow("", null)]
        [DataRow("some random string", null)]
        [DataRow("string,with,random,values", null)]
        [DataRow("string=with,random=,key=values", null)]
        [DataRow("string=with,random=,authorization_uri=", null)]
        [DataRow("string=with,invalid=authorization_uri,authorization_uri=some-random-value", null)]
        [DataRow("string=with,invalid=authorization_uri,authorization_uri=http://foo.bar.com/some-random-value", null)]
        [DataRow("string=missing,tenant_id=authorization_uri,authorization_uri=\"http://foo.bar.com/", null)]
        [DataRow("authorization_uri=\"https://login.microsoftonline.com/tenantId\",key1=value1s,etc...", "tenantId")]
        public void TestExtractTenantIdFromBearer(string? bearer, string? expected)
        {
            var actual = CredentialFactory.ExtractTenantIdFromBearer(bearer);
            Assert.AreEqual(expected, actual);
        }
    }
}
