// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#nullable enable

namespace Microsoft.Azure.Quantum.Utility
{
    using System.Threading;
    using System.Threading.Tasks;

    public interface IFileSystem
    {
        bool FileExists(string path);

        T GetFileContent<T>(string path);

        Task<T> GetFileContentAsync<T>(string path, CancellationToken cancellationToken);
    }
}
