// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Reflection;

namespace Microsoft.Quantum.Simulation.Core
{

    public class MissingParameter
    {
        public MissingParameter(Type type) // non-generic missing parameter
        {
            this.Type = type;
        }

        private MissingParameter() { } // generic missing parameter

        public Type Type { get; }

        public override string ToString()
        {
            return "_";
        }

        public static MissingParameter _ = new MissingParameter();
    }

    /// <summary>
    /// This class creates a function that maps the partial Type resulting from
    /// a partial application to the original Type expected by the operation.
    /// </summary>
    public static class PartialMapper
    {
        /// <summary>
        /// To easily get the correct ValueTuple type based on the number of items it needs:
        /// </summary>
        public static readonly Type[] TupleTypes = new Type[]
        {
            typeof(ValueTuple),
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
        /// Because C# can't automatically cast from (IUnitary, long) to (ICallable, long), sigh...
        /// we do the work for it here...
        /// </summary>
        static public object CastTuple(Type targetType, object value)
        {

            if (targetType == typeof(QVoid))
            {
                return QVoid.Instance;
            }

            if (value == null)
            {
                return null;
            }

            var valueType = value.GetType();

            if (targetType.IsAssignableFrom(valueType))
            {
                return value;
            }

            if (valueType.BaseType.IsQTuple())
            {
                return CastTuple(targetType, valueType.BaseType.GetProperty("Data").GetValue(value));
            }

            // See bug #779
            if (targetType == typeof(Double))
            {
                return Double.Parse(value.ToString());
            }
            else if (targetType == typeof(Int64))
            {
                return Int64.Parse(value.ToString());
            }
            else if (targetType.IsTuple() && valueType.IsTuple())
            {
                var targetFields = targetType.GetFields().OrderBy(f => f.Name).ToArray();
                var valueFields = valueType.GetFields().OrderBy(f => f.Name).ToArray();
                var values = new object[targetFields.Length];

                Debug.Assert(targetFields.Length == valueFields.Length, $"Trying to cast tuples of different length. Expected {targetFields.Length}, but got {valueFields.Length}");

                for (var i = 0; i < targetFields.Length; i++)
                {
                    values[i] = CastTuple(targetFields[i].FieldType, valueFields[i].GetValue(value));
                }

                return Activator.CreateInstance(targetType, values);
            }
            else if (targetType.IsQArray() && valueType.IsQArray())
            {
                Debug.Assert(targetType.GenericTypeArguments[0].IsAssignableFrom(valueType.GenericTypeArguments[0]), "Trying to cast Arrays of different types.");
                return Activator.CreateInstance(targetType, value);
            }
            else if (targetType.IsPartialMapper() && valueType.IsPartialMapper())
            {
                var tp = targetType.GenericTypeArguments[0];
                var ti = targetType.GenericTypeArguments[1];
                var vp = valueType.GenericTypeArguments[0];
                var vi = valueType.GenericTypeArguments[1];

                var gen = typeof(PartialMapper).GetMethod(nameof(CastPartialMapper), BindingFlags.NonPublic | BindingFlags.Static);
                var m = gen.MakeGenericMethod(tp, ti, vp, vi);
                return m.Invoke(null, new object[] { value });
            }
            else
            {
                IgnorableAssert.Assert(targetType.IsInstanceOfType(value) || (value == null && targetType.IsValueType == false),
                     $"Invalid resolved value. Expected {targetType} but got {valueType}");
                return value;
            }
        }

        private static Func<TP, TI> CastPartialMapper<TP, TI, VP, VI> (Func<VP, VI> original)
        {
            return new Func<TP, TI>((p) =>
            {
                var vp = (VP)CastTuple(typeof(VP), p);
                return (TI)CastTuple(typeof(TI), original.Invoke(vp));
            });
        }


        /// <summary>
        /// Verifies that the object received as argument is congruent
        /// with the Type that is expected to be applied to.
        /// </summary>
        private static bool IsValidValue(Type targetType, object partialValues) // decides whether partialValues are compatible with targetType
        {
            if (targetType == null) return true; // targetType is a generic type
            else if (partialValues == null)
            {
                return targetType.IsValueType == false;
            }
            else if (partialValues.GetType() == typeof(MissingParameter))
            {
                return true;
            }
            else if (targetType.IsTuple())
            {
                if (partialValues == null) return false;
                if (!partialValues.GetType().IsTuple()) return false;

                var partialValuesFields = partialValues.GetType().GetFields().OrderBy(f => f.Name).ToArray();
                var targetTypeFields = targetType.GetFields().OrderBy(f => f.Name).ToArray();
                if (partialValuesFields.Length == targetTypeFields.Length)
                {
                    var isAssignable = true;
                    for (var i = 0; i < targetTypeFields.Length; i++)
                    {
                        isAssignable = isAssignable && (IsValidValue(targetTypeFields[i].FieldType, partialValuesFields[i].GetValue(partialValues)));
                    }
                    return isAssignable;
                }
                else return false;
            }
            else
            {
                return targetType.IsAssignableFrom(partialValues.GetType());
            }
        }

        public static Stack<A> BuildStack<A> (A[] content)
        {
            return new Stack<A>(content.Reverse());
        }

        public static object BuildTuple(object[] fields)
        {
            var fieldTypes = new Type[fields.Length];
            for (var i = 0; i < fieldTypes.Length; i++)
            {
                fieldTypes[i] = fields[i] == null ? typeof(object) : fields[i].GetType();
            }

            var tupleType = TupleTypes[fields.Length].MakeGenericType(fieldTypes);
            return Activator.CreateInstance(tupleType,fields); 
        }

        // returns a list of length 1 with the object inside if object is not a tuple
        public static object[] GetTupleValues(object arg)
        {
            if (arg == null) return new object[] { arg };

            var targetType = arg.GetType();
            if (targetType.IsTuple())
            {
                var fields = targetType.GetFields().OrderBy(f => f.Name).ToArray();
                var values = new object[fields.Length];
                for (var i = 0; i < fields.Length; i++)
                {
                    values[i] = fields[i].GetValue(arg);
                }
                return values;
            }
            else
            {
                return new object[] { arg };
            }
        }

        internal static A PopNextArgs<A>(Func<A[],A> build, int nrUndefined, Stack<A> args)
        {
            IgnorableAssert.Assert(args.Count != 0, "shape mismatch in partial tuple");
            if (nrUndefined != 1 || args.Count == 1) return args.Pop();
            else 
            {
                var content = new A[args.Count];
                for (var i = 0; i < content.Length; i++)
                {
                    content[i] = args.Pop();
                }
                return build(content);
            }
        }

        /// <summary>
        /// Combines the original partial values, with the args received as parameter to return 
        /// a fully populated instance of targetType
        /// </summary>
        public static IEnumerable<object> Combine(object[] partial, Stack<object> args)
        {
            var nrUndefined = 0;
            foreach (object next in partial)
            {
                if (next != null)
                {
                    if (next.GetType().IsPartiallyDefined() || next.GetType().IsMissing()) nrUndefined += 1;
                }
            }

            foreach (object next in partial) 
            {
                if (next == null)
                {
                    yield return null;
                }
                else if (next.GetType().IsFullyDefined())
                {
                    yield return next;
                }
                else if (next.GetType().IsPartiallyDefined())
                {
                    var inner = GetTupleValues(next);
                    var a = PopNextArgs(BuildTuple, nrUndefined, args);
                    if (a.GetType().IsTuple())
                    {
                        var innerArgs = GetTupleValues(a);
                        var combined = Combine(inner, BuildStack(innerArgs));
                        yield return BuildTuple(combined.ToArray());
                    }
                    else
                    {
                        var innerStack = new Stack<object>(1);
                        innerStack.Push(a);
                        var combined = Combine(inner, innerStack);
                        yield return BuildTuple(combined.ToArray());
                    }
                }
                else
                {
                    Debug.Assert(next.GetType().IsMissing());
                    var a = PopNextArgs(BuildTuple, nrUndefined, args);
                    Debug.Assert(IsValidValue(((MissingParameter)next).Type, a));
                    yield return a;
                }
            }
        }

        /// <summary>
        /// Creates a Func that maps a tuple P as tuple I based on the values on partial.
        /// Partial itself must be a tuple congruent with I, that is, partial must be a Tuple
        /// with the same number and same Type of fields, except for some of them whose value is
        /// Missing (AbstractOperation._)
        /// </summary>
        public static Func<P, I> Create<P, I>(object partial)
        {
            Debug.Assert(IsValidValue(typeof(I), partial));
            var arg1 = GetTupleValues(partial);

            return new Func<P, I>((argTuple) =>
            {
                var args = GetTupleValues(argTuple); 
                var arg2 = new Stack<object>(args.Reverse());
                var combined = Combine(arg1, arg2).ToArray();

                object filledArgs = null;
                if (combined.Length == 0) filledArgs = QVoid.Instance;
                else if (combined.Length == 1) filledArgs = combined[0];
                else filledArgs = BuildTuple(combined);
                return (I)CastTuple(typeof(I), filledArgs);
            });
        }
    }
}
