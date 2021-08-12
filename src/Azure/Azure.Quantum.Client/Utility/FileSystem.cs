// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#nullable enable

namespace Microsoft.Azure.Quantum.Utility
{
    using System.IO;
    using System.Text.Json;
    using System.Threading;
    using System.Threading.Tasks;

    public class FileSystem : IFileSystem
    {
        public bool FileExists(string path)
        {
            return File.Exists(path);
        }

        public T GetFileContent<T>(string path)
        {
            using var reader = new StreamReader(path);
            return JsonSerializer.Deserialize<T>(reader.ReadToEnd());
        }

        public async Task<T> GetFileContentAsync<T>(string path, CancellationToken cancellationToken)
        {
            using FileStream stream = File.OpenRead(path);
            return await JsonSerializer.DeserializeAsync<T>(stream, null, cancellationToken);
        }
    }
}
