// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Qir.Runtime.Tools.Serialization;

namespace Microsoft.Quantum.Qir.Runtime.Tools.Driver
{
    internal static class ArgumentCppExtensions
    {
        public static string CliOptionDescription(this Parameter @this) =>
            $"Option to provide a value for the {@this.Name} parameter";

        public static string CliOptionName(this Parameter @this)
        {
            if (string.IsNullOrEmpty(@this.Name))
            {
                throw new InvalidOperationException($"Invalid parameter name '{@this.Name}'");
            }

            return @this.Name.Length == 1 ? $"-{@this.Name}" : $"--{@this.Name}";
        }

        public static string CliOptionVariableName(this Parameter @this) => $"{@this.Name}Cli";

        public static string CliOptionType(this Parameter @this) =>
            @this.Type switch
            {
                //DataType.BoolType => "char",
                DataType.Integer => "int64_t",
                DataType.Double => "double_t",
                DataType.BytePointer => "string",
                DataType.Collection => 
                    @this.ElementTypes.Count == 3 
                    ? "RangeTuple"
                    : throw new NotSupportedException("Arguments of type array or BigInt are not yet supported"),
                _ => throw new ArgumentException($"Invalid data type: {@this.Type}")
            };

        public static string InteropVariableName(this Parameter @this) => $"{@this.Name}Interop";

        public static string InteropType(this Parameter @this) =>
            @this.Type switch
            {
                DataType.Integer => "int64_t",
                DataType.Double => "double_t",
                DataType.BytePointer => "const char*",
                DataType.Collection =>
                    @this.ElementTypes.Count == 3
                    ? "InteropRange*"
                    : throw new NotSupportedException("Arguments of type array or BigInt are not yet supported"),
                _ => throw new ArgumentException($"Invalid data type: {@this.Type}")
            };

        public static string? CliOptionTypeToInteropTypeTranslator(this Parameter @this) =>
            @this.Type switch
            {
                DataType.Integer => null,
                DataType.Double => null,
                DataType.BytePointer => "TranslateStringToCharBuffer",
                DataType.Collection =>
                    @this.ElementTypes.Count == 3
                    ? "TranslateRangeTupleToInteropRangePointer"
                    : throw new NotSupportedException("Arguments of type array or BigInt are not yet supported"),
                _ => throw new ArgumentException($"Invalid data type: {@this.Type}")
            };

        public static string UniquePtrVariableName(this Parameter @this) => $"{@this.Name}UniquePtr";
    }
}
