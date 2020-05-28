// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Azure.Quantum.Utility
{
    internal static class Constants
    {
        internal const string DefaultBaseUri = "https://app-jobscheduler-prod.azurewebsites.net/";

        internal static class Aad
        {
            internal const string ApplicationId = "84ba0947-6c53-4dd2-9ca9-b3694761521b";

            // TODO: Confirm audience
            internal const string Audience = "https://quantum.microsoft.com/Jobs.ReadWrite";

            // Cache settings
            internal const string CacheFileName = "msal_cache.dat";

            // Mac Keychain settings
            internal const string KeyChainServiceName = "msal_service";
            internal const string KeyChainAccountName = "msal_account";
        }

        internal static class Storage
        {
            internal const string ContainerNamePrefix = "quantum-job-";
            internal const string InputBlobName = "inputData";
            internal const string MappingBlobName = "mappingData";
            internal const string OutputBlobName = "outputData";
            internal const int ExpiryIntervalInDays = 14;
        }
    }
}
