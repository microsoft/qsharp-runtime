// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Quantum.QsCompiler.BondSchemas.Execution;

#nullable enable

namespace Microsoft.Quantum.Qir.Tools.Driver
{
    internal static class QirCppInterop
    {
        public static string? CliOptionTransformerMapName(DataType? dataType) =>
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

        public static string CliOptionType(DataType? dataType) =>
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

        public static string? CliOptionTypeToInteropTypeTranslator(DataType? dataType) =>
            dataType switch
            {
                DataType.BoolType => null,
                DataType.IntegerType => null,
                DataType.DoubleType => null,
                DataType.PauliType => "TranslatePauliToChar",
                DataType.RangeType => "TranslateRangeTupleToInteropRangePointer",
                DataType.ResultType => null,
                DataType.StringType => "TranslateStringToCharBuffer",
                DataType.ArrayType => throw new NotSupportedException($"{DataType.ArrayType} does not match to a specific CLI option variable type"),
                _ => throw new ArgumentException($"Invalid data type: {dataType}")
            };

        public static string? CliOptionVariableDefaultValue(DataType? dataType) =>
            dataType switch
            {
                DataType.BoolType => "InteropFalseAsChar",
                DataType.IntegerType => "0",
                DataType.DoubleType => "0.0",
                DataType.PauliType => "PauliId::PauliId_I",
                DataType.RangeType => null,
                DataType.ResultType => "InteropResultZeroAsChar",
                DataType.StringType => null,
                DataType.ArrayType => null,
                _ => throw new ArgumentException($"Invalid data type: {dataType}")
            };

        public static string InteropType(DataType? dataType) =>
            dataType switch
            {
                DataType.BoolType => "char",
                DataType.IntegerType => "int64_t",
                DataType.DoubleType => "double_t",
                DataType.PauliType => "char",
                DataType.RangeType => "InteropRange*",
                DataType.ResultType => "char",
                DataType.StringType => "const char*",
                DataType.ArrayType => "InteropArray*",
                _ => throw new ArgumentException($"Invalid data type: {dataType}")
            };
    }

    internal static class ArgumentCppExtensions
    {
        public static string CliOptionDescription(this Parameter @this) =>
            $"Option to provide a value for the {@this.Name} parameter";

        public static string CliOptionName(this Parameter @this)
        {
            if (String.IsNullOrEmpty(@this.Name))
            {
                throw new InvalidOperationException($"Invalid parameter name '{@this.Name}'");
            }

            return @this.Name.Length == 1 ? $"-{@this.Name}" : $"--{@this.Name}";
        }

        public static string? CliOptionTransformerMapName(this Parameter @this) =>
            @this.Type switch
            {
                DataType.ArrayType => QirCppInterop.CliOptionTransformerMapName(@this.ArrayType),
                _ => QirCppInterop.CliOptionTransformerMapName(@this.Type)
            };

        public static string CliOptionType(this Parameter @this) =>
            @this.Type switch
            {
                DataType.ArrayType => $"vector<{QirCppInterop.CliOptionType(@this.ArrayType)}>",
                _ => QirCppInterop.CliOptionType(@this.Type)
            };

        public static string CliOptionVariableName(this Parameter @this) => $"{@this.Name}Cli";

        public static string? CliOptionVariableDefaultValue(this Parameter @this) => 
            QirCppInterop.CliOptionVariableDefaultValue(@this.Type);

        public static string IntermediateVariableName(this Parameter @this) => $"{@this.Name}Intermediate";

        public static string InteropVariableName(this Parameter @this) => $"{@this.Name}Interop";

        public static string InteropType(this Parameter @this) => QirCppInterop.InteropType(@this.Type);
    }

    internal static class EntryPointOperationCppExtension
    {
        public static bool ContainsArgumentType(this EntryPointOperation @this, DataType type) =>
            @this.Parameters.Where(arg => arg.Type == type).Any();

        public static bool ContainsArrayType(this EntryPointOperation @this, DataType type) =>
            @this.Parameters.Where(arg => arg.ArrayType == type).Any();
    }
}
