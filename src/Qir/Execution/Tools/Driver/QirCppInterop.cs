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

    internal static class ArgumentCppExtensions
    {
        public static string CliOptionDescription(this Argument @this) =>
            $"Option to provide a value for the {@this.Name} parameter";

        public static string CliOptionName(this Argument @this)
        {
            if (String.IsNullOrEmpty(@this.Name))
            {
                throw new InvalidOperationException($"Invalid argument name '{@this.Name}'");
            }

            return @this.Name.Length == 1 ? $"-{@this.Name}" : $"--{@this.Name}";
        }

        public static string CliOptionVariableName(this Argument @this) => $"{@this.Name}Cli";

        public static string? CliOptionVariableDefaultValue(this Argument @this) => 
            QirCppInterop.CliOptionVariableDefaultValue(@this.Type);

        public static string CliOptionVariableType(this Argument @this) =>
            @this.Type switch
            {
                DataType.ArrayType => $"vector<{QirCppInterop.CliOptionVariableType(@this.ArrayType)}>",
                _ => QirCppInterop.CliOptionVariableType(@this.Type)
            };

        public static string IntermediateVariableName(this Argument @this) => $"{@this.Name}Intermediate";

        public static string InteropVariableName(this Argument @this) => $"{@this.Name}Interop";

        public static string InteropType(this Argument @this) => QirCppInterop.InteropType(@this.Type);

        public static string? TransformerMapName(this Argument @this) =>
            @this.Type switch
            {
                DataType.ArrayType => QirCppInterop.TransformerMapName(@this.ArrayType),
                _ => QirCppInterop.TransformerMapName(@this.Type)
            };
    }

    internal static class EntryPointOperationCppExtension
    {
        public static bool ContainsArgumentType(this EntryPointOperation @this, DataType type) =>
            @this.Arguments.Where(arg => arg.Type == type).Any();

        public static bool ContainsArrayType(this EntryPointOperation @this, DataType type) =>
            @this.Arguments.Where(arg => arg.ArrayType == type).Any();
    }
}
