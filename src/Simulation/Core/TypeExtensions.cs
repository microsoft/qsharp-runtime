// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#nullable enable

using System;
using System.Collections;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;

namespace Microsoft.Quantum.Simulation.Core
{
    public static class TypeExtensions
    {
        public static bool IsQArray(this Type t)
        {
            return (t.IsGenericType && (t.GetGenericTypeDefinition() == typeof(IQArray<>) || t.GetGenericTypeDefinition() == typeof(QArray<>)));
        }

        public static bool IsUdt(this Type t)
        {
            return (t.BaseType.IsGenericType && typeof(UDTBase<>).IsAssignableFrom(t.BaseType.GetGenericTypeDefinition()));
        }

        public static bool IsQTuple(this Type t)
        {
            return (t.IsGenericType && t.GetGenericTypeDefinition() == typeof(QTuple<>));
        }

        public static bool IsPartialMapper(this Type t)
        {
            return (t.IsGenericType && t.GetGenericTypeDefinition() == typeof(Func<,>));
        }

        public static bool IsTuple(this Type t)
        {
            return (t.Name.StartsWith(typeof(ValueTuple).Name));
        }

        public static bool IsUnitary(this Type t)
        {
            return (typeof(IUnitary).IsAssignableFrom(t));
        }

        public static bool IsAdjointable(this Type t)
        {
            return (typeof(IAdjointable).IsAssignableFrom(t));
        }

        public static bool IsControllable(this Type t)
        {
            return (t.Name.StartsWith(typeof(IControllable).Name));
        }

        public static bool IsCallable(this Type t)
        {
            return (t.Name.StartsWith(typeof(ICallable).Name));
        }

        public static bool IsQubit(this Type t)
        {
            return (typeof(Qubit).IsAssignableFrom(t));
        }

        public static bool IsResult(this Type t)
        {
            return (typeof(Result).IsAssignableFrom(t));
        }

        // returns true if arg does not contain any field of type MissingParameter (recursive)
        public static bool IsFullyDefined(this Type arg)
        {
            if (arg.IsTuple())
            {
                var fields = arg.GetTupleFieldTypes();
                var isDefined = true;
                for (var i = 0; i < fields.Length; i++)
                {
                    isDefined = isDefined && IsFullyDefined(fields[i]);
                }
                return isDefined;
            }
            else
            {
                return !IsMissing(arg);
            }
        }

        // returns true if arg contain a field of type MissingParameter (recursive)
        public static bool IsPartiallyDefined(this Type arg)
        {
            return !(IsMissing(arg) || IsFullyDefined(arg));
        }

        // returns true if arg is a MissingParameter
        public static bool IsMissing(this Type arg)
        {
            return arg == typeof(MissingParameter); // needs to cover MissingParameter as well as any arg of type Type
        }

        /// <summary>
        /// It will return the Native implementation Type that should be
        /// used at runtime for the given Type.
        /// 
        /// Native implementations are identified by a nested type
        /// that is a subclass of the given Type.
        /// 
        /// If there are not Native implementations, this method returns null
        /// </summary>
        public static Type GetNativeImplementation(this Type t)
        {
            Type MakeConcrete(Type c)
            {
                if (c.IsGenericType && t.IsGenericType && c.GetGenericArguments().Length == t.GetGenericArguments().Length)
                {
                    return c.MakeGenericType(t.GenericTypeArguments);
                }

                return c;
            }

            return t
                .GetNestedTypes()
                .Select(MakeConcrete)
                .FirstOrDefault(op => op.IsSubclassOf(t));
        }

        /// <summary>
        /// Returns a list of length one containing arg, if arg is not a tuple, and a list of the field types of arg, if arg is a tuple.
        /// </summary>
        public static Type[] GetTupleFieldTypes(this Type arg)
        {
            if (arg.IsTuple())
            {
                var fields = arg.GetFields().OrderBy(f => f.Name).ToArray();
                var types = new Type[fields.Length];
                for (var i = 0; i < fields.Length; i++)
                {
                    types[i] = fields[i].FieldType;
                }
                return types;
            }
            else
            {
                return new Type[] { arg };
            }
        }

        /// <summary>
        /// Given an <see cref="object"/>, retrieve its non-qubit fields as a string.
        /// Returns null if no non-qubit fields found.
        /// </summary>
        public static string? GetNonQubitArgumentsAsString(this object o)
        {
            var t = o.GetType();

            // If object is a Qubit, QVoid, or array of Qubits, ignore it (i.e. return null)
            if (o is Qubit || o is QVoid || o is IEnumerable<Qubit>) return null;

            // If object is an ICallable, return its name
            if (o is ICallable op)
            {
                return op.Name;
            }

            // If object is a string, enclose it in quotations
            if (o is string s)
            {
                return (s != null) ? $"\"{s}\"" : null;
            }

            // If object is a list, recursively extract its inner arguments and
            // concatenate them into a list string
            if (typeof(IEnumerable).IsAssignableFrom(t))
            {
                var elements = ((IEnumerable)o).Cast<object>()
                    .Select(x => x.GetNonQubitArgumentsAsString())
                    .WhereNotNull();
                return (elements.Any()) ? $"[{string.Join(", ", elements)}]" : null;
            }

            // If object is a tuple, recursively extract its inner arguments and
            // concatenate them into a tuple string
            if (t.IsTuple())
            {
                var items = t.GetFields()
                    .Select(f => f.GetValue(o).GetNonQubitArgumentsAsString())
                    .WhereNotNull();
                return (items.Any()) ? $"({string.Join(", ", items)})" : null;
            }

            // If object is an IApplyData, recursively extract arguments
            if (o is IApplyData data)
            {
                if (data.Value != data)
                {
                    return data.Value?.GetNonQubitArgumentsAsString();
                }
            }

            // Otherwise, return argument as a string
            return (o != null) ? o.ToString() : null;
        }

        private static ConcurrentDictionary<Type, Type> _normalTypesCache = new ConcurrentDictionary<Type, Type>();

        /// <summary>
        /// Makes sure that Generic types are all the same to avoid cast errors
        /// </summary>
        public static Type Normalize(this Type t)
        {
            if (t == null)
            {
                return null;
            }

            Type result = null;
            if (_normalTypesCache.TryGetValue(t, out result))
            {
                return result;
            }
            else if (t.IsUnitary())
            {
                result = typeof(IUnitary);
            }
            else if (t.IsAdjointable())
            {
                result = typeof(IAdjointable);
            }
            else if (t.IsControllable())
            {
                result = typeof(IControllable);
            }
            else if (t.IsCallable())
            {
                result = typeof(ICallable);
            }
            else if (t.IsQubit())
            {
                result = typeof(Qubit);
            }
            else if (t.IsResult())
            {
                result = typeof(Result);
            }
            else if (t.IsTuple())
            {
                var originalFields = t.GetFields().OrderBy(f => f.Name).ToArray();
                var normalFields = new Type[originalFields.Length];
                var changed = false;

                for (var i = 0; i < originalFields.Length; i++)
                {
                    normalFields[i] = Normalize(originalFields[i].FieldType);
                    changed = (normalFields[i] != originalFields[i].FieldType) ? true : changed;
                }

                if (changed)
                {
                    result = t.GetGenericTypeDefinition().MakeGenericType(normalFields);
                }
                else
                {
                    result = t;
                }
            }
            else
            {
                result = t;
            }

            _normalTypesCache[t] = result;
            return result;
        }


        public static string OperationVariants(this Type t, object op)
        {
            if (t == null)
            {
                return "";
            }
            else if (t.IsGenericType)
            {
                var typeDef = t.GetGenericTypeDefinition();
                if (typeDef == typeof(Unitary<>))
                {
                    return " : Adjoint, Controlled";
                }
                else if (typeDef == typeof(Adjointable<>))
                {
                    return " : Adjoint";
                }
                else if (typeDef == typeof(Controllable<>))
                {
                    return " : Controlled";
                }
                else if (typeDef == typeof(OperationPartial<,,>) || typeDef == typeof(AdjointedOperation<,>) || typeDef == typeof(ControlledOperation<,>))
                {
                    Debug.Assert(op != null);
                    var baseop = t.GetProperty("BaseOp").GetValue(op);
                    return OperationVariants(baseop.GetType(), baseop);
                }
                else if (typeDef == typeof(Operation<,>))
                {
                    return "";
                }
            }
            else if (typeof(GenericAdjoint).IsAssignableFrom(t) || typeof(GenericControlled).IsAssignableFrom(t) || typeof(GenericPartial).IsAssignableFrom(t))
            {
                var baseop = t.GetProperty("BaseOp").GetValue(op);
                return OperationVariants(baseop.GetType(), baseop);
            }
            else if (typeof(GenericCallable).IsAssignableFrom(t))
            {
                var generic = op as GenericCallable;
                return OperationVariants(generic.OperationType, op);
            }

            return OperationVariants(t.BaseType, op);
        }

        public static bool TryQSharpOperationType(Type t, out string typeName)
        {
            if (t == null)
            {
                typeName = null;
                return false;
            }
            else if (t.IsGenericType)
            {
                var typeDef = t.GetGenericTypeDefinition();
                if (typeDef == typeof(Unitary<>))
                {
                    var inType = t.GenericTypeArguments[0].QSharpType();
                    var outType = typeof(QVoid).QSharpType();

                    typeName = $"{inType} => {outType} : Adjoint, Controlled";
                    return true;
                }
                if (typeDef == typeof(Adjointable<>))
                {
                    var inType = t.GenericTypeArguments[0].QSharpType();
                    var outType = typeof(QVoid).QSharpType();

                    typeName = $"{inType} => {outType} : Adjoint";
                    return true;
                }
                if (typeDef == typeof(Controllable<>))
                {
                    var inType = t.GenericTypeArguments[0].QSharpType();
                    var outType = typeof(QVoid).QSharpType();

                    typeName = $"{inType} => {outType} : Controlled";
                    return true;
                }
                if (typeDef == typeof(Operation<,>))
                {
                    var inType = t.GenericTypeArguments[0].QSharpType();
                    var outType = t.GenericTypeArguments[1].QSharpType();

                    typeName = $"{inType} => {outType}";
                    return true;
                }
            }

            return TryQSharpOperationType(t.BaseType, out typeName);
        }

        public static string QSharpType(this Type t)
        {
            if (t == typeof(QVoid))
            {
                return "()";
            }
            else if (t == typeof(long))
            {
                return "Int";
            }
            else if (t == typeof(Double))
            {
                return "Double";
            }
            else if (t == typeof(MissingParameter))
            {
                return "_";
            }
            else if (t == typeof(IAdjointable))
            {
                return "Adjointable";
            }
            else if (t == typeof(IControllable))
            {
                return "Controllable";
            }
            else if (t == typeof(IUnitary))
            {
                return "Unitary";
            }
            else if (t == typeof(ICallable))
            {
                return "Callable";
            }
            else if (t.IsQubit())
            {
                return "Qubit";
            }
            else if (t.IsQArray())
            {
                return $"{t.GenericTypeArguments[0].QSharpType()}[]";
            }
            else if (t.IsTuple())
            {
                var fields = t.GetFields().OrderBy(f => f.Name).Select(f => f.FieldType.QSharpType());
                return $"({string.Join(",", fields)})";
            }
            else
            {
                string result;
                if (TryQSharpOperationType(t, out result))
                {
                    return result;
                }
            }


            return t.Name;
        }

        public static ICallable UnwrapCallable(this ICallable op)
        {
            ICallable res = op;
            while (res as IOperationWrapper != null)
            {
                res = (res as IOperationWrapper).BaseOperation;
            }
            return res;
        }
    }
}
