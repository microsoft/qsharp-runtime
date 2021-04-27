// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Quantum.QsCompiler.BondSchemas.EntryPoint;

#nullable enable

namespace Microsoft.Quantum.Qir.Tools.Driver
{
    internal static class QirCppInterop
    {
        public static string? CliOptionVariableDefaultValue(DataType? dataType) =>
            dataType switch
            {
                DataType.BoolType => "0x0",
                DataType.IntegerType => "0",
                DataType.DoubleType => "0.0",
                DataType.PauliType => "PauliId::PauliId_I",
                DataType.RangeType => null,
                DataType.ResultType => "0x0",
                DataType.StringType => null,
                DataType.ArrayType => null,
                _ => throw new ArgumentException($"Invalid data type: {dataType}")
            };

        public static string CliOptionVariableType(DataType? dataType) =>
            dataType switch
            {
                DataType.BoolType => "char",
                DataType.IntegerType => "int64_t",
                DataType.DoubleType => "double_t",
                DataType.PauliType => "PauliId",
                DataType.RangeType => "RangeTuple",
                DataType.ResultType => "char",
                DataType.StringType => "string",
                DataType.ArrayType => throw new NotSupportedException($"{DataType.ArrayType} does not match to a specific CLI option variable type"),
                _ => throw new ArgumentException($"Invalid data type: {dataType}")
            };

        public static string InteropType(DataType dataType) =>
            dataType switch
            {
                DataType.BoolType => "char",
                DataType.IntegerType => "int64_t",
                DataType.DoubleType => "double",
                DataType.PauliType => "char",
                DataType.RangeType => "InteropRange*",
                DataType.ResultType => "char",
                DataType.StringType => "const char*",
                DataType.ArrayType => "InteropArray*",
                _ => throw new ArgumentException($"Invalid data type: {dataType}")
            };

        public static string? TransformerMapName(DataType? dataType) =>
            dataType switch
            {
                DataType.BoolType => "BoolAsCharMap",
                DataType.IntegerType => null,
                DataType.DoubleType => null,
                DataType.PauliType => "PauliMap",
                DataType.RangeType => null,
                DataType.ResultType => "ResultAsCharMap",
                DataType.StringType => null,
                DataType.ArrayType => null,
                _ => throw new ArgumentException($"Invalid data type: {dataType}")
            };
    }
    internal class CppArgument
    {
        private readonly Argument Argument;

        public CppArgument(Argument argument)
        {
            Argument = argument;
        }

        public DataType? ArrayType => Argument.ArrayType;

        public string CliOptionDescription() =>
            $"Option to provide a value for the {Argument.Name} parameter";

        public string CliOptionName()
        {
            if (String.IsNullOrEmpty(Argument.Name))
            {
                throw new InvalidOperationException($"Invalid argument name '{Argument.Name}'");
            }

            return Argument.Name.Length == 1 ? $"-{Argument.Name}" : $"--{Argument.Name}";
        }

        public string CliOptionVariableName() => $"{Argument.Name}Cli";

        public string? CliOptionVariableDefaultValue() => QirCppInterop.CliOptionVariableDefaultValue(Argument.Type);

        public string CliOptionVariableType() =>
            Argument.Type switch
            {
                DataType.ArrayType => $"vector<{QirCppInterop.CliOptionVariableType(Argument.ArrayType)}>",
                _ => QirCppInterop.CliOptionVariableType(Argument.Type)
            };

        public string IntermediateVariableName() => $"{Argument.Name}Intermediate";

        public string InteropVariableName() => $"{Argument.Name}Interop";

        public string InteropType() => QirCppInterop.InteropType(Argument.Type);

        public string? TransformerMapName() =>
            Argument.Type switch
            {
                DataType.ArrayType => QirCppInterop.TransformerMapName(Argument.ArrayType),
                _ => QirCppInterop.TransformerMapName(Argument.Type)
            };

        public DataType Type => Argument.Type;
    }

    internal class CppEntryPointOperation
    {
        public List<CppArgument> Arguments;

        private readonly EntryPointOperation EntryPoint;

        public CppEntryPointOperation(EntryPointOperation entryPointOperation)
        {
            EntryPoint = entryPointOperation;
            Arguments = entryPointOperation.Arguments.Select(arg => new CppArgument(arg)).ToList();
        }

        public bool ContainsArgumentType(DataType type) => Arguments.Where(arg => arg.Type == type).Any();

        public bool ContainsArrayType(DataType type) => Arguments.Where(arg => arg.ArrayType == type).Any();

        public string Name => EntryPoint.Name;
    }
}
