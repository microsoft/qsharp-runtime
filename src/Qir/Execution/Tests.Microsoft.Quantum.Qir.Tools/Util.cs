// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.IO;

namespace Tests.Microsoft.Quantum.Qir.Tools
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
            var filePath = Path.Combine(directory.FullName, fileName);
            var fileInfo = new FileInfo(filePath);
            using var fileStream = fileInfo.OpenWrite();
            fileStream.Write(contents);
            return fileInfo;
        }

        public static FileInfo CreateTextFile(DirectoryInfo directory, string fileName, string contents)
        {
            var filePath = Path.Combine(directory.FullName, fileName);
            var fileInfo = new FileInfo(filePath);
            using var fileStream = fileInfo.OpenWrite();
            using var streamWriter = new StreamWriter(fileStream);
            streamWriter.Write(contents);
            return fileInfo;
        }
    }
}
