#nullable enable

using System;
using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;
using System.Linq;

namespace Microsoft.Quantum.Simulation.Core
{
    /// <summary>
    /// Creates default values of Q# types.
    /// </summary>
    public static class Default
    {
        /// <summary>
        /// A dictionary from basic types to their default values.
        /// </summary>
        private static readonly IReadOnlyDictionary<Type, object> BasicValues = new Dictionary<Type, object>
        {
            [typeof(QRange)] = QRange.Empty,
            [typeof(QVoid)] = QVoid.Instance,
            [typeof(Result)] = Result.Zero,
            [typeof(string)] = ""
        };

        /// <summary>
        /// A list of all generic tuple types.
        /// </summary>
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

        /// <summary>
        /// Returns the default value of the Q# type. May return null when null is the default value of the type, or if
        /// the type is not a valid Q# type.
        /// </summary>
        [return: MaybeNull]
        public static T OfType<T>() => OfType(typeof(T)) is T value ? value : default;

        /// <summary>
        /// Returns the default value of the Q# type. May return null when null is the default value of the type, or if
        /// the type is not a valid Q# type.
        /// </summary>
        private static object? OfType(Type type) => OfAnyType(type).FirstOrDefault(value => !(value is null));

        /// <summary>
        /// Enumerates the default values of different kinds of types. Yields null if the given type is not the right
        /// kind, and yields a non-null value if a default value is found.
        /// </summary>
        private static IEnumerable<object?> OfAnyType(Type type)
        {
            yield return BasicValues.GetValueOrDefault(type);
            yield return OfArrayType(type);
            yield return OfTupleType(type);
            yield return OfUserDefinedType(type);
        }

        /// <summary>
        /// If the given type is a Q# array type, returns the default array of that type, or null otherwise.
        /// </summary>
        private static object? OfArrayType(Type type) =>
            type.IsGenericType && type.GetGenericTypeDefinition() == typeof(IQArray<>)
                ? Activator.CreateInstance(typeof(QArray<>).MakeGenericType(type.GenericTypeArguments))
                : null;

        /// <summary>
        /// If the given type is a Q# tuple type, returns the default tuple of that type, or null otherwise.
        /// </summary>
        private static object? OfTupleType(Type type) =>
            type.IsGenericType && Tuples.Contains(type.GetGenericTypeDefinition())
                ? Activator.CreateInstance(type, type.GenericTypeArguments.Select(OfType).ToArray())
                : null;

        /// <summary>
        /// If the given type is a Q# user-defined type, returns the default value of that type, or null otherwise.
        /// </summary>
        private static object? OfUserDefinedType(Type type) =>
            !(type.BaseType is null)
            && type.BaseType.IsGenericType
            && type.BaseType.GetGenericTypeDefinition() == typeof(UDTBase<>)
                ? Activator.CreateInstance(type, type.BaseType.GenericTypeArguments.Select(OfType).ToArray())
                : null;
    }
}
