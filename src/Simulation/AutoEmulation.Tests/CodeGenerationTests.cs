using System;
using System.Collections.Immutable;
using System.IO;
using System.Linq;
using Microsoft.Quantum.QsCompiler.AutoEmulation;
using Microsoft.Quantum.QsCompiler.CompilationBuilder;
using Microsoft.Quantum.QsCompiler.ReservedKeywords;
using Microsoft.Quantum.QsCompiler.SyntaxTree;
using Xunit;

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

        [Fact]
        public void CanFailForVariousReasons()
        {
            TestOneFailingFile("FailAlternativeDoesNotExist");
            TestOneFailingFile("FailDifferentSignatures");
            TestOneFailingFile("FailDifferentSpecializationKinds");
            TestOneFailingFile("FailNoNamespace");
        }

        private void TestOneSuccessfulFile(string fileName)
        {
            var step = new RewriteStep();
            var path = CreateNewTemporaryPath();
            step.AssemblyConstants[AssemblyConstants.OutputPath] = path;

            var compilation = CreateCompilation("Emulation.qs", Path.Combine("TestFiles", $"{fileName}.qs"));

            Assert.True(step.Transformation(compilation, out var transformed));
            var generatedFileName = Path.Combine(path, "__AutoEmulation__.g.cs");
            Assert.True(File.Exists(generatedFileName));

            // uncomment, when creating files with expected content
            //File.Copy(generatedFileName, $"{fileName}.cs_", true);

            Assert.Equal(File.ReadAllText(Path.Combine("TestFiles", $"{fileName}.cs_")), File.ReadAllText(generatedFileName));

            Directory.Delete(path, true);
        }

        private void TestOneFailingFile(string fileName)
        {
            var step = new RewriteStep();
            var path = CreateNewTemporaryPath();
            step.AssemblyConstants[AssemblyConstants.OutputPath] = path;

            var compilation = CreateCompilation("Emulation.qs", Path.Combine("TestFiles", $"{fileName}.qs"));

            Assert.False(step.Transformation(compilation, out var transformed));
            Assert.Equal(2, step.GeneratedDiagnostics.Count());
            Assert.Equal(CodeAnalysis.DiagnosticSeverity.Error, step.GeneratedDiagnostics.Last().Severity);
        }

        private QsCompilation CreateCompilation(params string[] fileNames)
        {
            var mgr = new CompilationUnitManager();
            var files = CreateFileManager(fileNames);
            mgr.AddOrUpdateSourceFilesAsync(files).Wait();
            return mgr.Build().BuiltCompilation;
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
