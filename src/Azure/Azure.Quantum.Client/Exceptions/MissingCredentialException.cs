// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Azure.Quantum.Exceptions
{
    using System;

    /// <summary>
    /// The exception that is thrown when the user tries to create a Workspace instance but provides no credential.
    /// </summary>
    public class MissingCredentialException : AzureQuantumException
    {
        private const string MESSAGE =
            "You must provide a TokenCredential instance to connect to a Workspace. \n" +
            "For information on how to authenticate with Azure services, see: \n" +
            "https://docs.microsoft.com/en-us/dotnet/api/overview/azure/identity-readme";

        /// <summary>
        /// Initializes a new instance of the <see cref="MissingCredentialException"/> class with a default error message.
        /// </summary>
        public MissingCredentialException()
            : base(MESSAGE)
        {
        }
    }
}
