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
        [DataRow(CredentialTypes.Default, typeof(DefaultAzureCredential))]
        [DataRow(CredentialTypes.Environment, typeof(EnvironmentCredential))]
        [DataRow(CredentialTypes.ManagedIdentity, typeof(ManagedIdentityCredential))]
        [DataRow(CredentialTypes.CLI, typeof(AzureCliCredential))]
        [DataRow(CredentialTypes.SharedToken, typeof(SharedTokenCacheCredential))]
        [DataRow(CredentialTypes.VisualStudio, typeof(VisualStudioCredential))]
        [DataRow(CredentialTypes.VisualStudioCode, typeof(VisualStudioCodeCredential))]
        [DataRow(CredentialTypes.Interactive, typeof(InteractiveBrowserCredential))]
        public void TestCreateCredential(CredentialTypes credentialType, Type expectedType)
        {
            var actual = CredentialFactory.CreateCredential(credentialType);

            Assert.IsNotNull(actual);
            Assert.AreEqual(expectedType, actual.GetType());
        }

        [TestMethod]
        public void TestInvalidCredentialType()
        {
            Assert.ThrowsException<ArgumentException>(() => CredentialFactory.CreateCredential((CredentialTypes)9999));
        }
    }
}
