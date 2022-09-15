// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Linq;
using LlvmBindings;
using LlvmBindings.Types;
using LlvmBindings.Values;
using Microsoft.CodeAnalysis;
using Microsoft.Quantum.Qir.Serialization;

namespace Microsoft.Quantum.Qir.Runtime.Tools
{
    internal static class EntryPointLoader
    {
        /// <summary>
        /// Loads the entry point operations found in the QIR bit-code module.<paramref name="module"/>.
        /// </summary>
        /// <param name="module">The bit-code module from which to load entry point operations from.</param>
        /// <returns>
        /// A list of entry point operation objects representing the QIR entry point operations.
        /// </returns>
        /// <exception cref="ArgumentException">Encounters invalid parameters for an entry point.</exception>
        public static IList<EntryPointOperation> LoadEntryPointOperations(BitcodeModule module)
        {
            return module.Functions
                .Where(f =>
                    f.Attributes.ContainsKey(LlvmBindings.Values.FunctionAttributeIndex.Function)
                    && f.Attributes[LlvmBindings.Values.FunctionAttributeIndex.Function].Any(a => a.Name == "EntryPoint"))
                .Select(ep => new EntryPointOperation()
                {
                    Name = ep.Name,
                    Parameters = ep.Parameters.Select(p => MakeParameter(p)).ToList()
                })
                .ToList();
        }

        private static Parameter MakeParameter(Argument parameter)
        {
            return new Parameter()
            {
                Name = parameter.Name,
                Type = MapNativeTypeToDataType(parameter),
                ArrayType = null
            };
        }

        private static DataType MapNativeTypeToDataType(Argument parameter)
        {
            DataType getSupportedPointerType(IPointerType pointerType)
            {
                var elementType = pointerType.ElementType;
                if (elementType is IStructType structType)
                {
                    return structType.Name switch
                    {
                        "Result" => DataType.ResultType,
                        _ => throw new ArgumentException(
                            $"Parameter \"{parameter.Name}\"'s type is an unsupported pointer type ({structType.Name}).")
                    };
                }

                throw new ArgumentException($"Parameter {parameter.Name} is not a pointer to a struct type.");
            }

            return parameter.NativeType.Kind switch
            {
                LlvmBindings.Types.TypeKind.Integer => DataType.IntegerType,
                LlvmBindings.Types.TypeKind.Float64 => DataType.DoubleType,
                LlvmBindings.Types.TypeKind.Pointer => getSupportedPointerType((IPointerType)parameter.NativeType),
                _ => throw new ArgumentException($"Parameter \"{parameter.Name}\"'s native type ({parameter.NativeType.Kind}) is not supported.")
            };
        }
    }
}
