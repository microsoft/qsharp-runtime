#nullable enable

using System;
using System.Collections.Generic;
using System.Linq;

namespace Microsoft.Quantum.Simulation.Core
{
    public static class Default
    {
        private static readonly IReadOnlyDictionary<Type, object> Values = new Dictionary<Type, object>
        {
            [typeof(QRange)] = QRange.Empty,
            [typeof(QVoid)] = QVoid.Instance,
            [typeof(Result)] = Result.Zero,
            [typeof(string)] = ""
        };

        private static readonly IReadOnlyList<Type> Tuples = new List<Type>
        {
            typeof(ValueTuple<>),
            typeof(ValueTuple<,>),
            typeof(ValueTuple<,,>),
            typeof(ValueTuple<,,,>),
            typeof(ValueTuple<,,,,>),
            typeof(ValueTuple<,,,,,>),
            typeof(ValueTuple<,,,,,,>),
            typeof(ValueTuple<,,,,,,,>)
        };

        public static T OfType<T>() => (T)OfType(typeof(T));

        private static object OfType(Type type) =>
            OfAnyType(type).FirstOrDefault(value => !(value is null))
            ?? throw new NotSupportedException("There is no default value for this type.");

        private static IEnumerable<object?> OfAnyType(Type type)
        {
            yield return Values.GetValueOrDefault(type);
            yield return OfArrayType(type);
            yield return OfTupleType(type);
            yield return OfUserDefinedType(type);
            yield return OfValueType(type);
        }

        private static object? OfArrayType(Type type) =>
            type.IsGenericType && type.GetGenericTypeDefinition() == typeof(IQArray<>)
                ? Activator.CreateInstance(typeof(QArray<>).MakeGenericType(type.GenericTypeArguments))
                : null;

        private static object? OfTupleType(Type type) =>
            type.IsGenericType && Tuples.Contains(type.GetGenericTypeDefinition())
                ? Activator.CreateInstance(type, type.GenericTypeArguments.Select(OfType).ToArray())
                : null;

        private static object? OfUserDefinedType(Type type) =>
            !(type.BaseType is null)
            && type.BaseType.IsGenericType
            && type.BaseType.GetGenericTypeDefinition() == typeof(UDTBase<>)
                ? Activator.CreateInstance(type, type.BaseType.GenericTypeArguments.Select(OfType).ToArray())
                : null;

        private static object? OfValueType(Type type) => type.IsValueType ? Activator.CreateInstance(type) : null;
    }
}
