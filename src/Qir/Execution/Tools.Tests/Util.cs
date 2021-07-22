// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.IO;

namespace Tests.Microsoft.Quantum.Qir.Runtime.Tools
{
    internal static class Util
    {
        public static bool CompareFiles(FileInfo fileA, FileInfo fileB)
        {
            if (fileA.FullName == fileB.FullName)
            {
                return true;
            }

            using var fileStreamA = fileA.OpenRead();
            using var fileStreamB = fileB.OpenRead();
            return CompareStreams(fileStreamA, fileStreamB);
        }

        public static bool CompareStreams(Stream streamA, Stream streamB)
        {
            if (streamA.Length != streamB.Length)
            {
                return false;
            }

            (streamA.Position, streamB.Position) = (0, 0);
            (int byteA, int byteB) = (0, 0);
            while ((byteA == byteB) && (byteA != -1))
            {
                (byteA, byteB) = (streamA.ReadByte(), streamB.ReadByte());
            }

            return byteA == byteB;
        }

        public static FileInfo CreateBinaryFile(DirectoryInfo directory, string fileName, byte[] contents)
        {
            var fileInfo = new FileInfo(Path.Combine(directory.FullName, fileName));
            File.WriteAllBytes(fileInfo.FullName, contents);
            return fileInfo;
        }

        public static FileInfo CreateTextFile(DirectoryInfo directory, string fileName, string contents)
        {
            var fileInfo = new FileInfo(Path.Combine(directory.FullName, fileName));
            File.WriteAllText(fileInfo.FullName, contents);
            return fileInfo;
        }
    }
}
