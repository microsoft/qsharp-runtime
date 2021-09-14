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
                    "UseNoArgsDebug",
                    new EntryPointOperation{Name = "UseNoArgsDebug"}
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
                        Name = "UseDoubleArg",
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
        [InlineData("UseNoArgs", false)]
        [InlineData("UseNoArgsDebug", true)]
        [InlineData("UseBoolArg", false)]
        [InlineData("UseBoolArrayArg", false)]
        [InlineData("UseDoubleArg", false)]
        [InlineData("UseDoubleArrayArg", false)]
        [InlineData("UseIntegerArg", false)]
        [InlineData("UseIntegerArrayArg", false)]
        [InlineData("UsePauliArg", false)]
        [InlineData("UsePauliArrayArg", false)]
        [InlineData("UseRangeArg", false)]
        [InlineData("UseRangeArrayArg", false)]
        [InlineData("UseResultArg", false)]
        [InlineData("UseResultArrayArg", false)]
        [InlineData("UseStringArg", false)]
        [InlineData("UseMiscArgs", false)]
        public void GenerateFullStateSimulatorDriver(string testCase, bool debug)
        {
            var entryPointOperation = TestCases[testCase];
            var driverGenerator = new QirFullStateDriverGenerator(debug);
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

        [Theory]
        [MemberData(nameof(GenerateCommandLineArgumentsData))]
        public void GenerateCommandLineArguments(string expected, ExecutionInformation info)
        {
            var generator = new QirFullStateDriverGenerator(false);
            Assert.Equal(expected, generator.GetCommandLineArguments(info));
        }

        public static IEnumerable<object[]> GenerateCommandLineArgumentsData()
        {
            static object[] TestCase(
                string expected, List<Parameter> parameters, Dictionary<string, ArgumentValue> arguments) =>
                new object[]
                {
                    expected,
                    new ExecutionInformation
                    {
                        EntryPoint = new EntryPointOperation { Parameters = parameters },
                        ArgumentValues = arguments
                    }
                };

            yield return TestCase(
                "--foo 5",
                new List<Parameter> { new Parameter { Name = "foo", Position = 0, Type = DataType.IntegerType } },
                new Dictionary<string, ArgumentValue> { ["foo"] = new ArgumentValue { Type = DataType.IntegerType, Integer = 5 } });

            yield return TestCase(
                "-n 5",
                new List<Parameter> { new Parameter { Name = "n", Position = 0, Type = DataType.IntegerType } },
                new Dictionary<string, ArgumentValue> { ["n"] = new ArgumentValue { Type = DataType.IntegerType, Integer = 5 } });

            yield return TestCase(
                "--foo 5 --bar \"abc\"",
                new List<Parameter>
                {
                    new Parameter { Name = "bar", Position = 1, Type = DataType.StringType },
                    new Parameter { Name = "foo", Position = 0, Type = DataType.IntegerType }
                },
                new Dictionary<string, ArgumentValue>
                {
                    ["bar"] = new ArgumentValue { Type = DataType.StringType, String = "abc" },
                    ["foo"] = new ArgumentValue { Type = DataType.IntegerType, Integer = 5 }
                });
        }
    }
}
