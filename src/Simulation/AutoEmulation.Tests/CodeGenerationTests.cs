using System;
using System.IO;
using Microsoft.Quantum.QsCompiler.AutoEmulation;
using Microsoft.Quantum.QsCompiler.CompilationBuilder;
using Xunit;
using System.Linq;
using System.Collections.Immutable;
using Microsoft.Quantum.QsCompiler.ReservedKeywords;

namespace Microsoft.Quantum.AutoEmulation.Testing
{
    public class CodeGenerationTests
    {
        [Fact]
        public void CanGenerateAutoEmulationCode()
        {
            TestOneSuccessfulFile("Success");
            TestOneSuccessfulFile("SuccessA");
            TestOneSuccessfulFile("SuccessC");
            TestOneSuccessfulFile("SuccessCA");
        }

        private void TestOneSuccessfulFile(string fileName)
        {
            var step = new RewriteStep();
            var path = CreateNewTemporaryPath();
            step.AssemblyConstants[AssemblyConstants.OutputPath] = path;

            var mgr = new CompilationUnitManager();
            var files = CreateFileManager("Emulation.qs", Path.Combine("TestFiles", $"{fileName}.qs"));
            mgr.AddOrUpdateSourceFilesAsync(files).Wait();
            var compilation = mgr.Build().BuiltCompilation;

            Assert.True(step.Transformation(compilation, out var transformed));
            Assert.Single(step.GeneratedDiagnostics);
            var generatedFileName = Path.Combine(path, "__AutoEmulation__.g.cs");
            Assert.True(File.Exists(generatedFileName));

            // uncomment, when creating files with expected content
            //File.Copy(generatedFileName, $"{fileName}.cs_", true);

            Assert.Equal(File.ReadAllText(Path.Combine("TestFiles", $"{fileName}.cs_")), File.ReadAllText(generatedFileName));

            Directory.Delete(path, true);
        }

        private ImmutableHashSet<FileContentManager> CreateFileManager(params string[] fileNames) =>
            CompilationUnitManager.InitializeFileManagers(
                fileNames.Select(fileName => {
                    var fileId = new Uri(Path.GetFullPath(fileName));
                    return (id: fileId, content: File.ReadAllText(fileName));
                }).ToDictionary(t => t.id, t => t.content)
            );

        private readonly System.Random random = new System.Random();
        private string CreateNewTemporaryPath() =>
            Directory.CreateDirectory(Path.Combine(Path.GetTempPath(), $"emulation-test-{random.Next(Int32.MaxValue)}")).FullName;
    }
}
