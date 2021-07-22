// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;
using System.IO;
using System.Text;

using Xunit;

using Microsoft.Quantum.Qir.Runtime.Tools.Driver;
using Microsoft.Quantum.Qir.Serialization;

namespace Tests.Microsoft.Quantum.Qir.Runtime.Tools
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
                    "UseBoolArg",
                    new EntryPointOperation
                    {
                        Name = "UseBoolArg",
                        Parameters = new List<Parameter>{new Parameter{ Name = "BoolArg", Type = DataType.BoolType}}
                    }
                },
                {
                    "UseBoolArrayArg",
                    new EntryPointOperation
                    {
                        Name = "UseBoolArrayArg",
                        Parameters = new List<Parameter>{new Parameter{ Name = "BoolArrayArg", Type = DataType.ArrayType, ArrayType = DataType.BoolType}}
                    }
                },
                {
                    "UseDoubleArg",
                    new EntryPointOperation
                    {
                        Name = "UseDoublArg",
                        Parameters = new List<Parameter>{new Parameter{ Name = "DoubleArg", Type = DataType.DoubleType}}
                    }
                },
                {
                    "UseDoubleArrayArg",
                    new EntryPointOperation
                    {
                        Name = "UseDoubleArrayArg",
                        Parameters = new List<Parameter>{new Parameter{ Name = "DoubleArrayArg", Type = DataType.ArrayType, ArrayType = DataType.DoubleType}}
                    }
                },
                {
                    "UseIntegerArg",
                    new EntryPointOperation
                    {
                        Name = "UseIntegerArg",
                        Parameters = new List<Parameter>{new Parameter{ Name = "IntegerArg", Type = DataType.IntegerType}}
                    }
                },
                {
                    "UseIntegerArrayArg",
                    new EntryPointOperation
                    {
                        Name = "UseIntegerArrayArg",
                        Parameters = new List<Parameter>{new Parameter{ Name = "IntegerArrayArg", Type = DataType.ArrayType, ArrayType = DataType.IntegerType}}
                    }
                },
                {
                    "UsePauliArg",
                    new EntryPointOperation
                    {
                        Name = "UsePauliArg",
                        Parameters = new List<Parameter>{new Parameter{ Name = "PauliArg", Type = DataType.PauliType}}
                    }
                },
                {
                    "UsePauliArrayArg",
                    new EntryPointOperation
                    {
                        Name = "UsePauliArrayArg",
                        Parameters = new List<Parameter>{new Parameter{ Name = "PauliArrayArg", Type = DataType.ArrayType, ArrayType = DataType.PauliType}}
                    }
                },
                {
                    "UseRangeArg",
                    new EntryPointOperation
                    {
                        Name = "UseRangeArg",
                        Parameters = new List<Parameter>{new Parameter{ Name = "RangeArg", Type = DataType.RangeType}}
                    }
                },
                {
                    "UseRangeArrayArg",
                    new EntryPointOperation
                    {
                        Name = "UseRangeArrayArg",
                        Parameters = new List<Parameter>{new Parameter{ Name = "RangeArrayArg", Type = DataType.ArrayType, ArrayType = DataType.RangeType}}
                    }
                },
                {
                    "UseResultArg",
                    new EntryPointOperation
                    {
                        Name = "UseResultArg",
                        Parameters = new List<Parameter>{new Parameter{ Name = "ResultArg", Type = DataType.ResultType}}
                    }
                },
                {
                    "UseResultArrayArg",
                    new EntryPointOperation
                    {
                        Name = "UseResultArrayArg",
                        Parameters = new List<Parameter>{new Parameter{ Name = "ResultArrayArg", Type = DataType.ArrayType, ArrayType = DataType.ResultType}}
                    }
                },
                {
                    "UseStringArg",
                    new EntryPointOperation
                    {
                        Name = "UseStringArg",
                        Parameters = new List<Parameter>{new Parameter{ Name = "StringArg", Type = DataType.StringType}}
                    }
                },
                {
                    "UseMiscArgs",
                    new EntryPointOperation
                    {
                        Name = "UseMiscArgs",
                        Parameters = new List<Parameter>{
                            new Parameter{ Name = "BoolArg", Type = DataType.BoolType},
                            new Parameter{ Name = "IntegerArrayArg", Position = 1, Type = DataType.ArrayType, ArrayType = DataType.IntegerType},
                            new Parameter{ Name = "RangeArg", Position = 2, Type = DataType.RangeType},
                            new Parameter{ Name = "StringArg", Position = 3, Type = DataType.StringType}
                        }
                    }
                }
            };

        private static string RemoveLineEndings(string str) =>
            str.Replace("\n", string.Empty).Replace("\r", string.Empty);

        [Theory]
        [InlineData("UseNoArgs")]
        [InlineData("UseBoolArg")]
        [InlineData("UseBoolArrayArg")]
        [InlineData("UseDoubleArg")]
        [InlineData("UseDoubleArrayArg")]
        [InlineData("UseIntegerArg")]
        [InlineData("UseIntegerArrayArg")]
        [InlineData("UsePauliArg")]
        [InlineData("UsePauliArrayArg")]
        [InlineData("UseRangeArg")]
        [InlineData("UseRangeArrayArg")]
        [InlineData("UseResultArg")]
        [InlineData("UseResultArrayArg")]
        [InlineData("UseStringArg")]
        [InlineData("UseMiscArgs")]
        public void GenerateFullStateSimulatorDriver(string testCase)
        {
            var entryPointOperation = TestCases[testCase];
            var driverGenerator = new QirFullStateDriverGenerator();
            var driverFileName = $"{testCase}.cpp";
            var verificationCppSourceCode = RemoveLineEndings(File.ReadAllText(Path.Combine(TestCasesDirectory, driverFileName)));
            Directory.CreateDirectory(TestArtifactsDirectory);
            var generatedStream = File.Create(Path.Combine(TestArtifactsDirectory, driverFileName));
            driverGenerator.GenerateAsync(entryPointOperation, generatedStream).Wait();
            var generatedStreamReader = new StreamReader(generatedStream, Encoding.UTF8);
            var generatedCppSourceCode = RemoveLineEndings(generatedStreamReader.ReadToEnd());
            Assert.Equal(verificationCppSourceCode, generatedCppSourceCode);
            generatedStream.Close();

        }
    }
}
