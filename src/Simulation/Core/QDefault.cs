using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Runtime.Core
{
    internal static class QDefault
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

        internal static T OfType<T>() => (T)OfType(typeof(T));

        private static object OfType(Type type)
        {
            if (Values.TryGetValue(type, out var value))
            {
                return value;
            }
            if (type.IsGenericType && type.GetGenericTypeDefinition() == typeof(IQArray<>))
            {
                return Activator.CreateInstance(typeof(QArray<>).MakeGenericType(type.GenericTypeArguments));
            }
            if (type.IsGenericType && Tuples.Contains(type.GetGenericTypeDefinition()))
            {
                return Activator.CreateInstance(type, type.GenericTypeArguments.Select(OfType).ToArray());
            }
            if (!(type.BaseType is null)
                && type.BaseType.IsGenericType
                && type.BaseType.GetGenericTypeDefinition() == typeof(UDTBase<>))
            {
                return Activator.CreateInstance(type, type.BaseType.GenericTypeArguments.Select(OfType).ToArray());
            }
            if (type.IsValueType)
            {
                return Activator.CreateInstance(type);
            }
            throw new NotSupportedException("There is no default value for this type.");
        }
    }
}
