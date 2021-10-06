// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
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

        public static bool CliOptionRequiresCheckedTransformer(this Parameter @this) =>
            @this.Type == DataType.Enum || 
            (@this.Type == DataType.Collection && @this.ElementTypes.Count == 1 && @this.ElementTypes[0] == DataType.Enum);

        public static string CliOptionType(this DataType @this, IList<DataType>? elementTypes = null) =>
            @this switch
            {
                DataType.Integer => "int64_t",
                DataType.Double => "double_t",
                DataType.Enum => "uint8_t", // string value is mapped to uint8_t using CheckedTransformer
                DataType.BytePointer => "string",
                DataType.Collection => 
                    elementTypes?.Count == 3 ? "RangeTuple" :
                    elementTypes?.Count == 1 ? $"vector<{elementTypes[0].CliOptionType()}>" :
                    throw new NotSupportedException($"Invalid element types [{string.Join(", ", elementTypes)}] for collection"),
                _ => throw new ArgumentException($"Invalid data type: {@this}")
            };

        public static string IntermediateVariableName(this Parameter @this) => $"{@this.Name}Intermediate";

        public static string InteropVariableName(this Parameter @this) => $"{@this.Name}Interop";

        public static string InteropType(this Parameter @this) =>
            @this.Type switch
            {
                DataType.Integer => "int64_t",
                DataType.Double => "double_t",
                DataType.Enum => "uint8_t",
                DataType.BytePointer => "const char*",
                DataType.Collection =>
                    @this.ElementTypes.Count == 3 ? "InteropRange*" :
                    @this.ElementTypes.Count == 1 ? "InteropArray*" :
                    throw new NotSupportedException($"Invalid element types [{string.Join(", ", @this.ElementTypes)}] for collection"),
                _ => throw new ArgumentException($"Invalid data type: {@this.Type}")
            };

        public static string? CliOptionTypeToInteropTypeTranslator(this Parameter @this) =>
            @this.Type switch
            {
                DataType.Integer => null,
                DataType.Double => null,
                DataType.Enum => null, // done using CheckedTransformer instead
                DataType.BytePointer => "TranslateStringToCharBuffer",
                DataType.Collection =>
                    @this.ElementTypes.Count == 3 ? "TranslateRangeTupleToInteropRangePointer" :
                    @this.ElementTypes.Count == 1 ? "TranslateVector" :
                    throw new NotSupportedException($"Invalid element types [{string.Join(", ", @this.ElementTypes)}] for collection"),
                _ => throw new ArgumentException($"Invalid data type: {@this.Type}")
            };

        public static string UniquePtrVariableName(this Parameter @this) => $"{@this.Name}UniquePtr";
    }
}
