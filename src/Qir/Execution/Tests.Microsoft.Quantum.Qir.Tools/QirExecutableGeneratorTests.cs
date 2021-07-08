// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Quantum.Qir.Tools.Executable;
using Moq;
using Xunit;

namespace Tests.Microsoft.Quantum.Qir.Tools
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
        private IList<string> linkLibraries;

        public QirExecutableGeneratorTests()
        {
            clangClientMock = new Mock<IClangClient>();
            executableGenerator = new QirExecutableGenerator(clangClientMock.Object, null);

            // Set up files.
            var prefix = Guid.NewGuid().ToString();
            binDirectory = new DirectoryInfo($"{prefix}-bin");
            binDirectory.Create();
            libraryDirectory = new DirectoryInfo($"{prefix}-library");
            libraryDirectory.Create();
            libraryFiles = new List<FileInfo>()
            {
                Util.CreateBinaryFile(libraryDirectory, "lib1", new byte[]{0x01, 0x23, 0x45, 0x67}),
                Util.CreateBinaryFile(libraryDirectory, "lib2", new byte[]{0x89, 0xAB, 0xCD, 0xEF}),
            };
            includeDirectory = new DirectoryInfo($"{prefix}-include");
            includeDirectory.Create();
            sourceDirectory = new DirectoryInfo($"{prefix}-source");
            sourceDirectory.Create();
            sourceFiles = new List<FileInfo>()
            {
                Util.CreateTextFile(sourceDirectory, "src1.cpp", "src1 contents"),
                Util.CreateBinaryFile(sourceDirectory, "src2.bc", new byte[]{0xFE, 0xDC, 0xBA, 0x98}),
            };
            linkLibraries = new List<string> { "lib1", "lib2" };
        }

        public void Dispose()
        {
            sourceDirectory.Delete(true);
            includeDirectory.Delete(true);
            libraryDirectory.Delete(true);
            binDirectory.Delete(true);
        }

        [Fact]
        public async Task TestGenerateExecutable()
        {
            var executableFile = new FileInfo(Path.Combine(binDirectory.FullName, "executableFile"));
            await executableGenerator.GenerateExecutableAsync(executableFile, sourceDirectory, new[] { libraryDirectory }, new[] { includeDirectory }, linkLibraries);

            // Verify invocation of clang.
            clangClientMock.Verify(obj => obj.CreateExecutableAsync(
                It.Is<string[]>(s => s.OrderBy(val => val).SequenceEqual(sourceFiles.OrderBy(val => val.FullName).Select(fileInfo => fileInfo.FullName))),
                It.Is<string[]>(s => s.OrderBy(val => val).SequenceEqual(linkLibraries.OrderBy(val => val))),
                new[] { libraryDirectory.FullName },
                new[] { includeDirectory.FullName },
                executableFile.FullName));

            // Verify files were copied.
            Assert.True(FilesWereCopied(libraryFiles.ToArray(), binDirectory));
        }

        private static bool FilesWereCopied(FileInfo[] files, DirectoryInfo destinationDirectory)
        {
            var destinationDirectoryFiles = destinationDirectory.GetFiles();

            // N.B. Runtime is (number of FileInfo objects passed in) * (number of files in destination directory).
            foreach (var file in files)
            {
                // Make sure that the file was copied and that the contents is the same.
                var copiedFile = destinationDirectoryFiles.FirstOrDefault(fileInfo => fileInfo.Name == file.Name);
                if (copiedFile == null)
                {
                    return false;
                }

                if (!Util.CompareFiles(file, copiedFile))
                {
                    return false;
                }

            }

            return true;
        }
    }
}
