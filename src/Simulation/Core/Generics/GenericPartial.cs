// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using static Microsoft.Quantum.Simulation.Core.PartialMapper;

namespace Microsoft.Quantum.Simulation.Core
{
    /// <summary>
    ///     Represents the result of doing a partial application to an operation whose
    ///     input Type is not resolved until it gets Applied at runtime.
    /// </summary>
    [DebuggerTypeProxy(typeof(GenericPartial.DebuggerProxy))]
    public class GenericPartial : GenericCallable, IApplyData, IOperationWrapper
    {
        private Lazy<Qubit[]> __qubits = null;

        public GenericPartial(GenericCallable baseOp, object partialValues) : base(baseOp.Factory, null)
        {
            Debug.Assert(baseOp != null, "Received a null base operation");
            Debug.Assert(partialValues != null, "Received a null partial value");

            this.Values = partialValues;
            this.BaseOp = baseOp;
            this.__qubits = new Lazy<Qubit[]>(() => this.ExtractQubits()?.ToArray());
        }

        public GenericCallable BaseOp { get; }
        ICallable IOperationWrapper.BaseOperation => BaseOp;

        public override string Name => this.BaseOp.Name;
        public override string FullName => this.BaseOp.FullName;
        public override OperationFunctor Variant => this.BaseOp.Variant;

        public object Values { get; }

        IEnumerable<Qubit> IApplyData.Qubits => __qubits.Value;

        /// <summary>
        /// Extracts the Qubits capatured by the parameters of this Partial Application.
        /// If received a Mapper, then it Extracts the qubits of the result of calling the Mapper with no new qubits.
        /// If received a Partial Tuple, it Extracts the qubits from the Partial Tuple itself.
        /// In both cases, it uses a generic QubitsExtractor as we don't have the type info at compile time.
        /// </summary>
        public IEnumerable<Qubit> ExtractQubits()
        {
            if (this.Values != null)
            {
                IEnumerable<Qubit> captured = null;
                IEnumerable<Qubit> capturedParent = ((IApplyData)this.BaseOp)?.Qubits;

                if (this.Values.GetType().IsPartialMapper())
                {
                    var mapper = this.Values as Delegate;
                    var P = mapper.GetType().GenericTypeArguments[0];
                    var d = P.IsValueType ? Activator.CreateInstance(P) : null;
                    var data = mapper.DynamicInvoke(d);

                    captured = QubitsExtractor.Get(data.GetType())?.Extract(data);
                }
                else
                {
                    captured = QubitsExtractor.Get(this.Values.GetType())?.Extract(this.Values);
                }

                if (captured == null)
                {
                    return capturedParent;
                }
                else if (capturedParent == null)
                {
                    return captured;
                }
                else
                {
                    return Qubit.Concat(captured, capturedParent);
                }
            }
            else
            {
                return null;
            }
        }

        public static Type TupleType(Type[] fields)
        {
            var normalizedFields = new Type[fields.Length];
            for (var i = 0; i < fields.Length; i++)
            {
                normalizedFields[i] = fields[i].Normalize();
            }
            return TupleTypes[normalizedFields.Length].MakeGenericType(normalizedFields);
        }

        /// <summary>
        /// Combines the original partial values, with the args received as parameter to return 
        /// a fully populated instance of targetType
        /// </summary>
        public static IEnumerable<Type> Combine(Type[] partial, Stack<Type> args)
        {
            var nrUndefined = 0;
            foreach (Type next in partial)
            {
                if (next.IsPartiallyDefined() || next.IsMissing()) nrUndefined += 1;
            }

            foreach (Type next in partial)
            {
                if (next.IsFullyDefined())
                {
                    yield return next;
                }
                else if (next.IsPartiallyDefined())
                {
                    var inner = next.GetTupleFieldTypes();
                    var a = PopNextArgs(TupleType, nrUndefined, args);
                    if (a.IsTuple())
                    {
                        var innerArgs = a.GetTupleFieldTypes();
                        var combined = Combine(inner, BuildStack(innerArgs));
                        yield return TupleType(combined.ToArray());
                    }
                    else
                    {
                        var innerStack = new Stack<Type>(1);
                        innerStack.Push(a);
                        var combined = Combine(inner, innerStack);
                        yield return TupleType(combined.ToArray());
                    }
                }
                else
                {
                    Debug.Assert(next.IsMissing());
                    var a = PopNextArgs(TupleType, nrUndefined, args);
                    yield return a;
                }
            }
        }

        public Type IdentifyBaseArgsType(Type P)
        {
            // Instead of a partial type, we receive a partial mapper:
            var t = this.Values.GetType();
            if (t.IsPartialMapper())
            {
                return t.GenericTypeArguments[1];
            }

            var args = P.GetTupleFieldTypes();
            var arg1 = t.GetTupleFieldTypes();
            var arg2 = new Stack<Type>(args.Reverse());
            var combined = Combine(arg1, arg2).ToArray();

            Type filledArgs = null;
            if (combined.Length == 0) filledArgs = typeof(QVoid);
            else if (combined.Length == 1) filledArgs = combined[0];
            else filledArgs = TupleType(combined);
            return filledArgs;
        }

        public Type IdentifyPartialArgsType(Type P)
        {
            // Instead of a partial type, we receive a partial mapper:
            var t = this.Values.GetType();
            if (t.IsPartialMapper())
            {
                return t.GenericTypeArguments[0];
            }

            return P;
        }

        /// <summary>
        /// The Types of the PartialApplicaiton need to match the one from the actual base operation and sometimes they might 
        /// mismatch due to upcasting from compiler...
        /// Also return the base PartialApplication type, either a PartialOperation<> or a PartialFunction<>, depending if the base
        /// operationType is a Q# operation or function.
        /// </summary>
        public static (Type, Type[]) PartialApplicationTypes(Type partialType, Type originalIn, Type originalOut, Type operationType)
        {
            var inType = originalIn;
            var outType = originalOut;

            // Find the Operation<,> definition:
            var current = operationType;
            while (current != null)
            {
                if (current.IsGenericType && current.GetGenericTypeDefinition() == typeof(Operation<,>))
                {
                    inType = current.GenericTypeArguments[0];
                    outType = current.GenericTypeArguments[1];
                    return (typeof(OperationPartial<,,>), new Type[] { partialType, inType, outType });
                }
                else if (current.IsGenericType && current.GetGenericTypeDefinition() == typeof(Function<,>))
                {
                    inType = current.GenericTypeArguments[0];
                    outType = current.GenericTypeArguments[1];
                    return (typeof(FunctionPartial<,,>), new Type[] { partialType, inType, outType });
                }

                current = current.BaseType;
                Debug.Assert(current != null);
            }

            throw new InvalidOperationException("Trying to create a PartialApplication of something that is neither Function or Operation");
        }

        protected override ICallable CreateCallable(Type P, Type O)
        {
            var baseArgsType = IdentifyBaseArgsType(P);
            var partialType = IdentifyPartialArgsType(P);
            var outType = O.Normalize();
            var op = this.BaseOp.FindCallable(baseArgsType, outType);

            var (partialOperationType, typeArgs) = PartialApplicationTypes(partialType, baseArgsType, outType, op.GetType());
            var partialOpType = partialOperationType.MakeGenericType(typeArgs);
            var partialValues = this.Values.GetType().IsPartialMapper()
                ? PartialMapper.CastTuple(typeof(Func<,>).MakeGenericType(new Type[] { typeArgs[0], typeArgs[1] }), this.Values)
                : this.Values;

            var result = (ICallable)Activator.CreateInstance(partialOpType, op, partialValues);
            return result;
        }

        new internal class DebuggerProxy
        {
            private GenericPartial _op;

            public DebuggerProxy(GenericPartial op)
            {
                this._op = op;
            }

            public string Name => _op.Name;
            public string FullName => _op.FullName;
            public OperationFunctor Variant => _op.Variant;

            public GenericCallable Base => _op.BaseOp;

            public string PartialTuple
            {
                get
                {
                    if (_op.Values.GetType().IsPartialMapper())
                    {
                        return "<mapper>";
                    }

                    return _op.Values.ToString();
                }
            }
        }

        public override string ToString() => $"{this.BaseOp}{{_}}";
    }
}
