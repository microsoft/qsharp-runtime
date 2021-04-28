// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;
using System.IO;
using System.Text;

using Xunit;

using Microsoft.Quantum.Qir.Tools.Driver;
using Microsoft.Quantum.QsCompiler.BondSchemas.EntryPoint;

namespace Tests.Microsoft.Quantum.Qir.Tools
{
    public class QirDriverGeneratorTests
    {
        private static string TestArtifactsDirectory = Path.Combine("TestArtifacts", "FullStateDriverGenerator");
        private static string TestCasesDirectory = Path.Combine("TestCases", "FullStateDriverGenerator");
        private static IDictionary<string, EntryPointOperation> TestCases =
            new Dictionary<string, EntryPointOperation>
            {
                {
                    "UseNoArgs",
                    new EntryPointOperation{Name = "UseNoArgs"}
                },
                {
                    "UseResultArg",
                    new EntryPointOperation
                    {
                        Name = "UseResultArg",
                        Arguments = new List<Argument>{new Argument{ Name = "ResultArg", Type = DataType.ResultType}}
                    }
                }
            };

        [Theory]
        [InlineData("UseNoArgs")]
        [InlineData("UseResultArg")]
        public void GenerateFullStateSimulatorDriver(string testCase)
        {
            var entryPointOperation = TestCases[testCase];
            var driverGenerator = new QirFullStateDriverGenerator();
            var driverFileName = $"{testCase}.cpp";
            var verificationCppSourceCode = File.ReadAllText(Path.Combine(TestCasesDirectory, driverFileName));
            if (!Directory.Exists(TestArtifactsDirectory))
            {
                Directory.CreateDirectory(TestArtifactsDirectory);
            }

            var generatedStream = File.Create(Path.Combine(TestArtifactsDirectory, driverFileName));
            driverGenerator.GenerateAsync(entryPointOperation, generatedStream).Wait();
            var generatedStreamReader = new StreamReader(generatedStream, Encoding.UTF8);
            var generatedCppSourceCode = generatedStreamReader.ReadToEnd();
            // TODO: Compare strings.
            generatedStream.Close();

        }
    }
}
