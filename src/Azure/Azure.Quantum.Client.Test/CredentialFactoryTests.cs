// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;

using Azure.Identity;

using Microsoft.Azure.Quantum.Authentication;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Microsoft.Azure.Quantum.Test
{
    [TestClass]
    public class CredentialFactoryTests
    {
        [DataTestMethod]
        [DataRow(CredentialType.Default, typeof(DefaultAzureCredential))]
        [DataRow(CredentialType.Environment, typeof(EnvironmentCredential))]
        [DataRow(CredentialType.ManagedIdentity, typeof(ManagedIdentityCredential))]
        [DataRow(CredentialType.CLI, typeof(AzureCliCredential))]
        [DataRow(CredentialType.SharedToken, typeof(SharedTokenCacheCredential))]
        [DataRow(CredentialType.VisualStudio, typeof(VisualStudioCredential))]
        [DataRow(CredentialType.VisualStudioCode, typeof(VisualStudioCodeCredential))]
        [DataRow(CredentialType.Interactive, typeof(InteractiveBrowserCredential))]
        public void TestCreateCredential(CredentialType credentialType, Type expectedType)
        {
            var actual = CredentialFactory.CreateCredential(credentialType);

            Assert.IsNotNull(actual);
            Assert.AreEqual(expectedType, actual.GetType());
        }

        [TestMethod]
        public void TestInvalidCredentialType()
        {
            Assert.ThrowsException<ArgumentException>(() => CredentialFactory.CreateCredential((CredentialType)9999));
        }
    }
}
