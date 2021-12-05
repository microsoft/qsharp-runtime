// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Azure.Quantum.Utility
{
    using System.IO;
    using System.IO.Compression;
    using System.Threading.Tasks;

    internal class Compression
    {
        public static async Task Compress(Stream data, Stream compressedData)
        {
            using (var auxStream = new MemoryStream())
            using (var zipStream = new GZipStream(auxStream, CompressionMode.Compress))
            {
                await data.CopyToAsync(zipStream);
                await zipStream.FlushAsync();
                auxStream.Position = 0;
                await auxStream.CopyToAsync(compressedData);
                await compressedData.FlushAsync();
            }

            compressedData.Position = 0;
        }
    }
}
