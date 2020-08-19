// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#nullable enable

using System;
using System.Collections.Concurrent;
using System.Diagnostics;

namespace Microsoft.Quantum.Simulation.Core
{    
    /// <summary>
    ///     Represents an operation whose
    ///     input and output Types are not resolved until it gets Applied at runtime.
    /// </summary>
    public partial interface ICallable : IApplyData
    {
        string FullName { get; }

        string Name { get; }

        OperationFunctor Variant { get; }

        QVoid Apply(object args);

        O Apply<O>(object args);

        ICallable Partial(object partialTuple);

        RuntimeMetadata? GetRuntimeMetadata(IApplyData args);
    }

    /// <summary>
    ///     This is a wrapper class that holds an Operation's Type and will
    ///     try to create an instance of it when Apply is called.
    ///    
    ///     During apply, it uses the input and output parameters to resolve
    ///     any generic parameters of the BaseOp using reflection.
    ///     
    ///     Notice GenericOperations are not expected to extend this class. They
    ///     should instead extend Operation and stay generic. This class will take
    ///     care of resolving the Generic types are runtime based on the Apply types.
    /// </summary>
    [DebuggerTypeProxy(typeof(GenericCallable.DebuggerProxy))]
    public class GenericCallable : AbstractCallable, IUnitary
    {
        private Lazy<GenericAdjoint> _adjoint;
        private Lazy<GenericControlled> _controlled;

        public GenericCallable(IOperationFactory m, Type baseOp) : base(m)
        {
            this.OperationType = baseOp;
            _adjoint = new Lazy<GenericAdjoint>(() => new GenericAdjoint(this));
            _controlled = new Lazy<GenericControlled>(() => new GenericControlled(this));
        }

        public override void __Init__() { }

        public Type OperationType { get; }

        public GenericAdjoint Adjoint => _adjoint.Value;

        public GenericControlled Controlled => _controlled.Value;

        ConcurrentDictionary<(Type, Type), ICallable> _cache = new ConcurrentDictionary<(Type, Type), ICallable>();

        // Finds an instance of Operation<'I, 'O> with no resolved Types, used only for debugging.
        internal ICallable FindCallable()
        {
            return FindCallable(typeof(MissingParameter), typeof(MissingParameter));
        }

        // Tries to get the instance Operation<'I, 'O> based on the type fo the Input/Output 
        // parameters. It tries to resolve from Cache first, if not, then it calls CreateOperation.
        public virtual ICallable FindCallable(Type I, Type O)
        {
            var key = (I, O);
            ICallable result = null;
            if (_cache.TryGetValue(key, out result))
            {
                return result;
            }

            var normal = I.Normalize();
            if (_cache.TryGetValue((normal, O), out result))
            {
                _cache[key] = result;
                return result;
            }

            result = CreateCallable(normal, O);
            _cache[key] = result;

            return result;
        }

        // Creates the corresponding closed Operation<'I, 'O> for the given I O.
        protected virtual ICallable CreateCallable(Type I, Type O)
        {
            var op = this.OperationType;
            if (OperationType.ContainsGenericParameters)
            {
                op = FindClosedType(I, O);
            }

            var get = this.__Factory__.GetType()
                .GetMethod("Get", new Type[0]);

            var result = get
                .MakeGenericMethod(typeof(ICallable), op)
                .Invoke(this.__Factory__, new object[] { })
                as ICallable;

            return result;
        }

        O Apply<O>(object args)
        {
            IgnorableAssert.Assert(args != null, "Calling Apply method on a generic with null input, thus Input type can't be determined.");
            if (args == null) return default(O);

            var op = FindCallable(args.GetType(), typeof(O));

            return (O)op.Apply<O>(args);
        }

        public GenericPartial Partial(object partialTuple) => new GenericPartial(this, partialTuple);


        public virtual string Name => FindCallable().Name;
        public virtual string FullName => FindCallable().FullName;
        public virtual OperationFunctor Variant => OperationFunctor.Body;
        
        O ICallable.Apply<O>(object args) => this.Apply<O>(args);
        QVoid ICallable.Apply(object args) => this.Apply<QVoid>(args);
        ICallable ICallable.Partial(object partialTuple) => this.Partial(partialTuple);

        IAdjointable IAdjointable.Adjoint => this.Adjoint;
        IAdjointable IAdjointable.Partial(object partialTuple) => this.Partial(partialTuple);

        IControllable IControllable.Controlled => this.Controlled;
        IControllable IControllable.Partial(object partialTuple) => this.Partial(partialTuple);

        IUnitary IUnitary.Adjoint => this.Adjoint;
        IUnitary IUnitary.Controlled => this.Controlled;
        IUnitary IUnitary.Partial(object partialTuple) => this.Partial(partialTuple);

        /// <summary>
        ///     Finds the ClosedType for the BaseOp based on the given Input (I) and
        ///     Output (O) Types that the Apply method is expecting.
        ///     
        ///  This method finds the ClosedType of the based (generic) operation...
        ///  For example, if the base operation is Some ['T] : Unitary [('T, long)]
        ///  and it is called with a.Apply((bool, long))
        ///  then it maps maps 'T == bool
        ///  and returns 
        ///  typeof(SomeOp [bool ])
        /// </summary>
        public virtual Type FindClosedType(Type I, Type O)
        {
            var typeArgs = new Type[this.OperationType.GetGenericArguments().Length];

            // Get the list of Parameters of the Invoke method of the Body of the operation:
            var expectedParameters = this.OperationType
                .GetProperty("__Body__").PropertyType
                .GetMethod("Invoke").GetParameters();

            // Tuple in...
            Debug.Assert(expectedParameters.Length == 1, "Expected a single argument Tuple when calling Apply");
            Resolve(expectedParameters[0].ParameterType, I, typeArgs);

            // Tuple out...
            var expectedReturn = this.OperationType
                .GetProperty("__Body__").PropertyType
                .GetMethod("Invoke").ReturnType;
            Resolve(expectedReturn, O, typeArgs);

            // Verify everything is resolved:
            ResolveTheUnresolved(typeArgs);

            return this.OperationType.MakeGenericType(typeArgs); ;
        }

        /// <summary>
        ///     Makes sure the Types that will be sent as parameters to the CreateInstance are exactly 
        ///     'I and 'O for Operation<'I, 'O>
        /// </summary>
        public static Type[] MatchOperationTypes(Type originalIn, Type originalOut, Type operationType)
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
                    break;
                }

                current = current.BaseType;
                Debug.Assert(current != null);
            }

            return new Type[] { inType, outType };
        }

        /// <summary>
        /// There are situations that the type parameters of a Generic operation can't be resolved, because 
        /// the input tuple does not use them directly, for example, in Bind<'T> the 'T is in the arguments 
        /// of the input operations which in turn are just passed in as ICallables, with no type info.
        /// In this scenario, we simply use object as 'T as we just pass it down.
        /// </summary>
        public virtual void ResolveTheUnresolved(Type[] typeArgs)
        {
            for(var i =0; i < typeArgs.Length; i++)
            {
                if (typeArgs[i] == null)
                {
                    typeArgs[i] = typeof(object);
                }
            }
        }

        /// <summary>
        /// Populates the generic Type Arguments based on the resolved type.
        /// Basically if the resolved type comes from a generic type, then whatever resolved values it 
        /// had are applied to original.
        /// This method is the one that computes what the Type the GenericParameter should take based on the input argument.
        /// It recursively checks if the Operations is expecting a
        /// ('T, long) and it receives a (bool, long) it maps 'T == bool.
        /// </summary>
        public virtual void Resolve(Type original, Type resolved, Type[] typeArgs)
        {
            if (original.IsGenericParameter)
            {
                typeArgs[original.GenericParameterPosition] = resolved.Normalize();
            }
            else if (original.IsGenericType)
            {
                var originalDefinition = original.GetGenericTypeDefinition();
                var originalGenericArgs = original.GetGenericArguments();
                var resolvedGenericArgs = new Type[0];
                var resolvedBase = resolved.BaseType;

                // The Types matches, for example original == ValueTuple<,,> and resolved is ValueTuple<,,>, we can do a Type for Type
                if (resolved.IsGenericType && resolved.GetGenericTypeDefinition() == originalDefinition)
                {
                    resolvedGenericArgs = resolved.GetGenericArguments();
                }
                else if (resolved.IsQArray() && originalDefinition.GetGenericTypeDefinition() == typeof(IQArray<>))
                {
                    resolvedGenericArgs = resolved.GetGenericArguments();
                }

                if (originalGenericArgs.Length == resolvedGenericArgs.Length)
                {
                    for (int i = 0; i < originalGenericArgs.Length; i++)
                    {
                        var a = originalGenericArgs[i];
                        var r = resolvedGenericArgs[i];

                        Resolve(a, r, typeArgs);
                    }
                }
                else if (resolvedGenericArgs.Length == 0)
                {
                    for (int i = 0; i < originalGenericArgs.Length; i++)
                    {
                        var a = originalGenericArgs[i];
                        Resolve(a, resolved, typeArgs);
                    }
                }
                else
                {
                    Debug.Assert(false, $"Number of generic parameters missmatch. Most probably the Type inferred will be wrong.");
                }
            }
        }

        internal class DebuggerProxy
        {
            private GenericCallable _op;

            public DebuggerProxy(GenericCallable op)
            {
                this._op = op;
            }

            public string Name => _op.Name;
            public string FullName => _op.FullName;
            public OperationFunctor Variant => _op.Variant;

            public string Signature => _op.QSharpType();
        }

        public virtual string QSharpType() => this.OperationType?.QSharpType();

        public override string ToString() => this.Name;
    }
}
