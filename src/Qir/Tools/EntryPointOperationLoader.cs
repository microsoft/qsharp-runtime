// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Microsoft.Quantum.QIR;
using Microsoft.Quantum.Qir.Runtime.Tools.Serialization;
using Ubiquity.NET.Llvm;
using Ubiquity.NET.Llvm.Types;
using Ubiquity.NET.Llvm.Values;

namespace Microsoft.Quantum.Qir.Runtime.Tools
{
    public static class EntryPointOperationLoader
    {
        /// <summary>
        /// Loads the entry point operations for the qir at the given location.
        /// </summary>
        /// <param name="qirBitCode">The file info of a .NET DLL from which to load entry point operations from.</param>
        /// <returns>
        /// A list of entry point operation objects representing the QIR entry point operations.
        /// </returns>
        /// <exception cref="FileNotFoundException"><paramref name="qirBitCode"/> does not exist.</exception>
        /// <exception cref="ArgumentException"><paramref name="qirBitCode"/> does not contain a Q# syntax tree.</exception>
        /// <exception cref="ArgumentException">Encounters invalid parameters for an entry point.</exception>
        public static IList<EntryPointOperation> LoadEntryPointOperations(string qirBitCode)
        {
            var module = BitcodeModule.LoadFrom(qirBitCode, new Context());
            var entryPoints = module.Functions.Where(f =>
                f.Attributes.ContainsKey(FunctionAttributeIndex.Function) // TryGetValue for some reason does not seem to work properly
                && f.GetAttributesAtIndex(FunctionAttributeIndex.Function).Any(a => a.Name == AttributeNames.EntryPoint));

            return new List<EntryPointOperation>(entryPoints.Select(ep => new EntryPointOperation()
            {
                Name = ep.Name,
                Parameters = new List<Parameter>(ep.Parameters.Select(param => new Parameter()
                {
                    Name = param.Name,
                    Type = MapResolvedTypeToDataType(param.NativeType, out var elementTypes),
                    ElementTypes = elementTypes,
                })),
            }));
        }

        private static DataType MapResolvedTypeToDataType(ITypeRef rt, out List<DataType>? elementTypes)
        {
            elementTypes = null;
            if (rt.IsFloatingPoint)
            {
                // used for Double
                return DataType.Double;
            }
            else if (rt.IsInteger && rt.IntegerBitWidth == 8)
            {
                // used for Bool, Pauli, and Result
                return DataType.Enum;
            }
            else if (rt.IsInteger)
            {
                // used for Int
                return DataType.Integer;
            }
            else if (rt is IPointerType ptrType && ptrType.ElementType is IStructType structType)
            {
                // used for Range, Array, BigInt, (and Tuple -> N/A for entry points)
                if (structType.Members.Count == 2 && structType.Members[0].IsInteger && structType.Members[1] is IPointerType elementPtr)
                {
                    // used for Array and BigInt
                    elementTypes = new List<DataType>() { MapResolvedTypeToDataType(elementPtr.ElementType, out var _) };
                    return DataType.Collection;
                }
                else
                {
                    // used for Range
                    elementTypes = structType.Members.Select(t => MapResolvedTypeToDataType(t, out var _)).ToList();
                    return DataType.Collection;
                }
            }
            else if (rt.IsPointer)
            {
                // Callable and Qubit are N/A for entry points,
                // only one left is String
                return DataType.BytePointer;
            }
            else
            {
                throw new ArgumentException("unknown entry point type");
            }
        }
    }
}
