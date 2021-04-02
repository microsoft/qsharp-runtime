// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.IO;
using System.Text;

namespace Microsoft.Quantum.Qir
{
    internal static class Controller
    {
        internal static void Execute(
            FileInfo input,
            FileInfo output,
            FileInfo error)
        {
            var outputFileStream = output.Exists ? output.OpenWrite() : output.Create();
            outputFileStream.Write(new UTF8Encoding().GetBytes("output"));
            outputFileStream.Flush();
            outputFileStream.Close();
            var errorFileStream = error.Exists ? error.OpenWrite() : error.Create();
            errorFileStream.Write(new UTF8Encoding().GetBytes("error"));
            errorFileStream.Flush();
            errorFileStream.Close();
        }
    }
}
