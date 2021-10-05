// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Quantum.Qir.Runtime.Tools.Serialization;

namespace Microsoft.Quantum.Qir.Runtime.Tools.Driver
{
    public class QirCppDriverGenerator : IQirDriverGenerator
    {
        private readonly IQirRuntimeInitializer RuntimeInitalizer;

        public QirCppDriverGenerator(IQirRuntimeInitializer runtimeInitializer)
        {
            RuntimeInitalizer = runtimeInitializer;
        }

        public async Task GenerateAsync(EntryPointOperation entryPointOperation, Stream stream)
        {
            var qirCppDriver = new QirCppDriver(entryPointOperation, RuntimeInitalizer);
            var cppSource = qirCppDriver.TransformText();
            await stream.WriteAsync(Encoding.UTF8.GetBytes(cppSource));
            await stream.FlushAsync();
            stream.Position = 0;
        }

        public string GetCommandLineArguments(ExecutionInformation executionInformation)
        {
            string ToArgument(Parameter param)
            {
                var prefix = param.Name.Length > 1 ? "--" : "-";
                var value = GetArgumentValueString(param, executionInformation.ArgumentValues[param.Name]);
                return $"{prefix}{param.Name} {value}";
            }

            var parameters = executionInformation.EntryPoint.Parameters.OrderBy(param => param.Position);
            return string.Join(" ", parameters.Select(ToArgument));
        }

        private static string GetArgumentValueString(Parameter argument, ArgumentValue argumentValue)
        {
            // Today, only the first argument value in the array will be used.
            return argument.Type switch
            {
                DataType.Double => GetDoubleValueString(argumentValue),
                DataType.Integer => GetIntegerValueString(argumentValue),
                DataType.Enum => GetEnumValueString(argumentValue),
                DataType.BytePointer => GetBytePointerValueString(argumentValue),
                DataType.Collection => GetCollectionValueString(argument.ElementTypes, argumentValue.Collection),
                _ => throw new NotSupportedException($"Unsupported data type {argument.Type}")
            };
        }

        private static string GetCollectionValueString(IList<DataType> itemTypes, IList<ArgumentValue> itemValues)
        {
            // used for Range, Array, BigInt, (Tuples are not valid entry points arguments)
            var isRange = itemValues.Count == 3 && itemValues.All(v => v.Type == DataType.Integer);
            var isArrayOrBigInt = itemValues.Count == 2 && itemValues[0].Type == DataType.Integer && itemValues[1].Type == DataType.BytePointer;

            if (isRange)
            {
                return string.Join(' ', itemValues.Select(item => GetIntegerValueString(item)));
            }
            else if (isArrayOrBigInt)
            {
                throw new NotSupportedException("Arguments of type array or BigInt are not yet supported");
            }
            else
            {
                throw new NotSupportedException($"Unsupported data type [{String.Join(", ", itemTypes)}] for entry point argument");
            }
        }

        private static string GetBytePointerValueString(ArgumentValue value)
        {
            // used for Strings (Qubit and Callables are not valid entry point arguments)
            if (value?.BytePointer == null)
            {
                throw new ArgumentNullException("Cannot convert null byte pointer value to string.");
            }

            var strContent = Encoding.UTF8.GetString(value.BytePointer.ToArray());
            return $"\"{strContent}\"";
        }

        private static string GetDoubleValueString(ArgumentValue value)
        {
            // used for Double
            if (value?.Double == null)
            {
                throw new ArgumentNullException("Cannot convert null double value to string.");
            }

            return value.Double.ToString().ToLower();
        }

        private static string GetIntegerValueString(ArgumentValue value)
        {
            // used for Int
            if (value?.Integer == null)
            {
                throw new ArgumentNullException("Cannot convert null integer value to string.");
            }

            return value.Integer.ToString().ToLower();
        }

        private static string GetEnumValueString(ArgumentValue value)
        {
            // used for Bool, Pauli, and Result
            if (value?.Enum == null)
            {
                throw new ArgumentNullException("Cannot convert null integer value to string.");
            }

            return ((int)value.Enum).ToString().ToLower();
        }
    }
}
