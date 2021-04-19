// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Quantum.Qir.Executable;
using Microsoft.Quantum.Qir.Utility;
using Moq;
using Xunit;

namespace Tests.QirController
{
    public class QirExecutableGeneratorTests : IDisposable
    {
        private readonly Mock<IClangClient> clangClientMock;
        private readonly QirExecutableGenerator executableGenerator;
        private readonly DirectoryInfo sourceDirectory;
        private readonly DirectoryInfo includeDirectory;
        private readonly DirectoryInfo libraryDirectory;
        private readonly DirectoryInfo binDirectory;
        private readonly IList<FileInfo> libraryFiles;
        private readonly IList<FileInfo> sourceFiles;

        public QirExecutableGeneratorTests()
        {
            clangClientMock = new Mock<IClangClient>();
            executableGenerator = new QirExecutableGenerator(clangClientMock.Object, Mock.Of<ILogger>());

            // Set up files.
            var prefix = Guid.NewGuid().ToString();
            binDirectory = new DirectoryInfo($"{prefix}-bin");
            binDirectory.Create();
            libraryDirectory = new DirectoryInfo($"{prefix}-library");
            libraryDirectory.Create();
            libraryFiles = new List<FileInfo>()
            {
                CreateFile("lib1", libraryDirectory, "lib1 contents"),
                CreateFile("lib2", libraryDirectory, "lib2 contents"),
            };
            includeDirectory = new DirectoryInfo($"{prefix}-include");
            includeDirectory.Create();
            sourceDirectory = new DirectoryInfo($"{prefix}-source");
            sourceDirectory.Create();
            sourceFiles = new List<FileInfo>()
            {
                CreateFile("src1.cpp", sourceDirectory, "src1 contents"),
                CreateFile("src2.bc", sourceDirectory, "src2 contents"),
            };
        }

        public void Dispose()
        {
            Util.DeleteDirectory(sourceDirectory);
            Util.DeleteDirectory(includeDirectory);
            Util.DeleteDirectory(libraryDirectory);
            Util.DeleteDirectory(binDirectory);
        }

        [Fact]
        public async Task TestGenerateExecutable()
        {
            string[] expectedLibraries = {
                "Microsoft.Quantum.Qir.Runtime",
                "Microsoft.Quantum.Qir.QSharp.Foundation",
                "Microsoft.Quantum.Qir.QSharp.Core"
            };

            var executableFile = new FileInfo(Path.Combine(binDirectory.FullName, "executableFile"));
            await executableGenerator.GenerateExecutableAsync(executableFile, sourceDirectory, libraryDirectory, includeDirectory);

            // Verify invocation of clang.
            clangClientMock.Verify(obj => obj.CreateExecutableAsync(
                It.Is<string[]>(s => s.SequenceEqual(sourceFiles.Select(fileInfo => fileInfo.FullName))),
                It.Is<string[]>(s => s.SequenceEqual(expectedLibraries)),
                libraryDirectory.FullName,
                includeDirectory.FullName,
                executableFile.FullName));

            // Verify files were copied.
            Assert.True(FilesWereCopied(libraryFiles.ToArray(), binDirectory));
        }

        private static FileInfo CreateFile(string fileName, DirectoryInfo directory, string contents)
        {
            var filePath = Path.Combine(directory.FullName, fileName);
            var fileInfo = new FileInfo(filePath);
            using var fileStream = fileInfo.OpenWrite();
            using var streamWriter = new StreamWriter(fileStream);
            streamWriter.Write(contents);
            return fileInfo;
        }

        private static bool FilesWereCopied(FileInfo[] files, DirectoryInfo destinationDirectory)
        {
            var destinationDirectoryFiles = destinationDirectory.GetFiles();
            foreach (var file in files)
            {
                var copiedFile = destinationDirectoryFiles.FirstOrDefault(fileInfo => fileInfo.Name == file.Name);
                if (copiedFile == null)
                {
                    return false;
                }

                using var originalFileReader = file.OpenText();
                var originalFileContents = originalFileReader.ReadToEnd();
                using var copiedFileReader = copiedFile.OpenText();
                var copiedFileContents = copiedFileReader.ReadToEnd();
                if (originalFileContents != copiedFileContents)
                {
                    return false;
                }
            }

            return true;
        }
    }
}
