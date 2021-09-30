// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Qir.Runtime.Tools.Serialization;

namespace Microsoft.Quantum.Qir.Runtime.Tools.Driver
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
}
